-- install the scheme if necessary
-- SET search_path TO public;

-- 1. Users
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM users) THEN
    COPY users(user_id, full_name, email, phone, password, created_at)
    FROM '02_initial_data/users.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;

-- 2. Bike Categories
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM bike_categories) THEN
    COPY bike_categories(category_id, category_name)
    FROM '02_initial_data/bike_categories.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;

-- 3. Bikes
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM bikes) THEN
    COPY bikes(bike_id, model, brand, category_id, price_per_hour, is_available)
    FROM '02_initial_data/bikes.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;

-- 4. Locations
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM locations) THEN
    COPY locations(location_id, address, city)
    FROM '02_initial_data/locations.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;

-- 5. Payment Methods
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM payment_methods) THEN
    COPY payment_methods(method_id, method_name)
    FROM '02_initial_data/payment_methods.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;

-- 6. Rentals
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM rentals) THEN
    COPY rentals(rental_id, user_id, bike_id, location_id, start_time, end_time, total_cost)
    FROM '02_initial_data/rentals.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;

-- 7. Payments
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM payments) THEN
    COPY payments(payment_id, rental_id, method_id, paid_at, amount)
    FROM '02_initial_data/payments.csv' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
  END IF;
END $$;
