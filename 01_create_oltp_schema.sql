-- Users table
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Admins table
CREATE TABLE Admins (
    admin_id INT PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL
);

-- Bike_Categories
CREATE TABLE Bike_Categories (
    category_id INT PRIMARY KEY,
    category_name TEXT NOT NULL
);

-- Bikes
CREATE TABLE Bikes (
    bike_id INT PRIMARY KEY,
    model TEXT NOT NULL,
    brand TEXT NOT NULL,
    category_id INT REFERENCES Bike_Categories(category_id),
    price_per_hour DECIMAL(6,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

-- Rental locations
CREATE TABLE Locations (
    location_id INT PRIMARY KEY,
    address TEXT NOT NULL,
    city TEXT NOT NULL
);

-- Rentals
CREATE TABLE Rentals (
    rental_id INT PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    bike_id INT REFERENCES Bikes(bike_id),
    location_id INT REFERENCES Locations(location_id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    total_cost DECIMAL(10,2)
);

-- Payment_Methods
CREATE TABLE Payment_Methods (
    method_id INT PRIMARY KEY,
    method_name TEXT NOT NULL
);

-- Payments
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    rental_id INT REFERENCES Rentals(rental_id),
    method_id INT REFERENCES Payment_Methods(method_id),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL
);
