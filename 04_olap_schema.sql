-- ===============================
-- OLAP Snowflake Schema
-- Bike Online Rental App
-- ===============================

-- Measurements

DROP TABLE IF EXISTS dim_date CASCADE;
CREATE TABLE dim_date (
    date_key DATE PRIMARY KEY,
    day INT,
    month INT,
    quarter INT,
    year INT,
    day_of_week INT
);

DROP TABLE IF EXISTS dim_user CASCADE;
CREATE TABLE dim_user (
    user_sk SERIAL PRIMARY KEY,
    user_id INT,
    name VARCHAR,
    address VARCHAR,
    effective_from DATE,
    effective_to DATE,
    current_flag BOOLEAN
);

DROP TABLE IF EXISTS dim_bike_category CASCADE;
CREATE TABLE dim_bike_category (
    category_sk SERIAL PRIMARY KEY,
    name VARCHAR,
    description VARCHAR
);

DROP TABLE IF EXISTS dim_bike CASCADE;
CREATE TABLE dim_bike (
    bike_sk SERIAL PRIMARY KEY,
    bike_id INT,
    model VARCHAR,
    category_sk INT REFERENCES dim_bike_category(category_sk)
);

DROP TABLE IF EXISTS dim_payment_method CASCADE;
CREATE TABLE dim_payment_method (
    method_sk SERIAL PRIMARY KEY,
    method_name VARCHAR
);

DROP TABLE IF EXISTS dim_location CASCADE;
CREATE TABLE dim_location (
    location_sk SERIAL PRIMARY KEY,
    city VARCHAR,
    address VARCHAR
);

-- Facts

DROP TABLE IF EXISTS fact_rentals CASCADE;
CREATE TABLE fact_rentals (
    rental_sk SERIAL PRIMARY KEY,
    date_key DATE REFERENCES dim_date(date_key),
    user_sk INT REFERENCES dim_user(user_sk),
    bike_sk INT REFERENCES dim_bike(bike_sk),
    location_sk INT REFERENCES dim_location(location_sk),
    duration_minutes INT,
    total_amount DECIMAL
);

DROP TABLE IF EXISTS fact_payments CASCADE;
CREATE TABLE fact_payments (
    payment_sk SERIAL PRIMARY KEY,
    date_key DATE REFERENCES dim_date(date_key),
    user_sk INT REFERENCES dim_user(user_sk),
    method_sk INT REFERENCES dim_payment_method(method_sk),
    amount DECIMAL
);

-- Bridge-table

DROP TABLE IF EXISTS bridge_rental_payment CASCADE;
CREATE TABLE bridge_rental_payment (
    rental_sk INT REFERENCES fact_rentals(rental_sk),
    payment_sk INT REFERENCES fact_payments(payment_sk),
    PRIMARY KEY (rental_sk, payment_sk)
);
