-- ========================================
-- ETL Process: Load OLTP (bike_oltp) → OLAP (bike_olap) via dblink
-- ========================================

CREATE EXTENSION IF NOT EXISTS dblink;

-- 1. dim_bike_category
INSERT INTO dim_bike_category (name, description)
SELECT name, description
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT DISTINCT category_name, category_name || '' bikes''
    FROM bike_categories
') AS t(name TEXT, description TEXT)
WHERE NOT EXISTS (
    SELECT 1 FROM dim_bike_category d WHERE d.name = t.name
);

-- 2. dim_payment_method
INSERT INTO dim_payment_method (method_name)
SELECT method_name
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT DISTINCT method_name FROM payment_methods
') AS t(method_name TEXT)
WHERE NOT EXISTS (
    SELECT 1 FROM dim_payment_method d WHERE d.method_name = t.method_name
);

-- 3. dim_location
INSERT INTO dim_location (city, address)
SELECT city, address
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT DISTINCT city, address FROM locations
') AS t(city TEXT, address TEXT)
WHERE NOT EXISTS (
    SELECT 1 FROM dim_location d WHERE d.city = t.city AND d.address = t.address
);

-- 4. dim_user (simplified SCD Type 2)
INSERT INTO dim_user (user_id, name, address, effective_from, effective_to, current_flag)
SELECT user_id, full_name, 'unknown', CURRENT_DATE, NULL, TRUE
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT DISTINCT user_id, full_name FROM users
') AS t(user_id INT, full_name TEXT)
WHERE NOT EXISTS (
    SELECT 1 FROM dim_user d WHERE d.user_id = t.user_id AND d.current_flag = TRUE
);

-- 5. dim_date (from rentals)
INSERT INTO dim_date (date_key, day, month, quarter, year, day_of_week)
SELECT dt, EXTRACT(DAY FROM dt)::INT, EXTRACT(MONTH FROM dt)::INT,
       EXTRACT(QUARTER FROM dt)::INT, EXTRACT(YEAR FROM dt)::INT, EXTRACT(DOW FROM dt)::INT
FROM (
    SELECT DISTINCT DATE(start_time) AS dt
    FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
        SELECT start_time FROM rentals
    ') AS t(start_time TIMESTAMP)
) sub
WHERE NOT EXISTS (SELECT 1 FROM dim_date d WHERE d.date_key = sub.dt);

-- 5.1 dim_date (from payments)
INSERT INTO dim_date (date_key, day, month, quarter, year, day_of_week)
SELECT dt, EXTRACT(DAY FROM dt)::INT, EXTRACT(MONTH FROM dt)::INT,
       EXTRACT(QUARTER FROM dt)::INT, EXTRACT(YEAR FROM dt)::INT, EXTRACT(DOW FROM dt)::INT
FROM (
    SELECT DISTINCT DATE(paid_at) AS dt
    FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
        SELECT paid_at FROM payments
    ') AS t(paid_at TIMESTAMP)
) sub
WHERE NOT EXISTS (SELECT 1 FROM dim_date d WHERE d.date_key = sub.dt);

-- 6. dim_bike
INSERT INTO dim_bike (bike_id, model, category_sk)
SELECT b_id, model, dbc.category_sk
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT b.bike_id, b.model, bc.category_name
    FROM bikes b
    JOIN bike_categories bc ON bc.category_id = b.category_id
') AS t(b_id INT, model TEXT, category_name TEXT)
JOIN dim_bike_category dbc ON dbc.name = t.category_name
WHERE NOT EXISTS (
    SELECT 1 FROM dim_bike d WHERE d.bike_id = t.b_id
);

-- 7. fact_rentals
INSERT INTO fact_rentals (date_key, user_sk, bike_sk, location_sk, duration_minutes, total_amount)
SELECT
    DATE(r.start_time),
    du.user_sk,
    db.bike_sk,
    dl.location_sk,
    EXTRACT(EPOCH FROM (r.end_time - r.start_time)) / 60,
    r.total_cost
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT rental_id, user_id, bike_id, location_id, start_time, end_time, total_cost
    FROM rentals
') AS r(rental_id INT, user_id INT, bike_id INT, location_id INT, start_time TIMESTAMP, end_time TIMESTAMP, total_cost NUMERIC)
JOIN dim_user du ON du.user_id = r.user_id AND du.current_flag = TRUE
JOIN dim_bike db ON db.bike_id = r.bike_id
JOIN dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT location_id, city, address FROM locations
') AS l(location_id INT, city TEXT, address TEXT)
    ON l.location_id = r.location_id
JOIN dim_location dl ON dl.city = l.city AND dl.address = l.address
WHERE NOT EXISTS (
    SELECT 1 FROM fact_rentals f
    WHERE f.date_key = DATE(r.start_time)
      AND f.user_sk = du.user_sk
      AND f.bike_sk = db.bike_sk
);

-- 8. fact_payments
INSERT INTO fact_payments (date_key, user_sk, method_sk, amount)
SELECT
    DATE(p.paid_at),
    du.user_sk,
    dpm.method_sk,
    p.amount
FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT payment_id, rental_id, method_id, paid_at, amount
    FROM payments
') AS p(payment_id INT, rental_id INT, method_id INT, paid_at TIMESTAMP, amount NUMERIC)
JOIN dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT rental_id, user_id FROM rentals
') AS r(rental_id INT, user_id INT)
  ON p.rental_id = r.rental_id
JOIN dim_user du ON du.user_id = r.user_id AND du.current_flag = TRUE
JOIN dim_payment_method dpm
  ON dpm.method_name = (
    SELECT method_name FROM dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
        SELECT method_name FROM payment_methods WHERE method_id = ' || p.method_id
    ) AS t(method_name TEXT)
)
WHERE NOT EXISTS (
    SELECT 1 FROM fact_payments f
    WHERE f.date_key = DATE(p.paid_at)
      AND f.user_sk = du.user_sk
      AND f.amount = p.amount
);

-- 9. bridge_rental_payment
INSERT INTO bridge_rental_payment (rental_sk, payment_sk)
SELECT fr.rental_sk, fp.payment_sk
FROM fact_rentals fr
JOIN dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT rental_id, start_time, total_cost
    FROM rentals
') AS r(rental_id INT, start_time TIMESTAMP, total_cost NUMERIC)
  ON DATE(r.start_time) = fr.date_key AND fr.total_amount = r.total_cost
JOIN dblink('host=localhost dbname=bike_oltp user=postgres password=10051980', '
    SELECT payment_id, rental_id, paid_at, amount
    FROM payments
') AS p(payment_id INT, rental_id INT, paid_at TIMESTAMP, amount NUMERIC)
  ON p.rental_id = r.rental_id
JOIN fact_payments fp
  ON DATE(p.paid_at) = fp.date_key AND p.amount = fp.amount
WHERE NOT EXISTS (
    SELECT 1 FROM bridge_rental_payment brp
    WHERE brp.rental_sk = fr.rental_sk AND brp.payment_sk = fp.payment_sk
);
