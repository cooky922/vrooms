PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS customers (
    customer_id             TEXT PRIMARY KEY,
    first_name              TEXT NOT NULL,
    last_name               TEXT NOT NULL,
    registration_date       TEXT NOT NULL,
    driver_license_id       TEXT NOT NULL UNIQUE,
    driver_license_picture  TEXT,
    home_address            TEXT,
    contact_number          TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS units (
    plate_number      TEXT PRIMARY KEY,
    unit_model        TEXT NOT NULL,
    unit_status       TEXT NOT NULL DEFAULT 'Available',
    daily_rate        REAL NOT NULL,
    unit_picture      TEXT,
    registration_date TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS rents (
    rental_id               TEXT PRIMARY KEY,
    customer_id             TEXT NOT NULL,
    plate_number            TEXT NOT NULL,
    rental_status           TEXT NOT NULL DEFAULT 'Active',
    reserve_date            TEXT NOT NULL,
    rental_date_time        TEXT NOT NULL,
    expected_return_date    TEXT NOT NULL,
    actual_return_date_time TEXT,
    rental_base_cost        REAL NOT NULL,
    FOREIGN KEY (customer_id)  REFERENCES customers(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (plate_number) REFERENCES units(plate_number)    ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id        TEXT NOT NULL,
    rental_id         TEXT NOT NULL,
    payment_type      TEXT NOT NULL,
    payment_date_time TEXT NOT NULL,
    amount_paid       REAL NOT NULL,
    PRIMARY KEY (payment_id, rental_id),
    FOREIGN KEY (rental_id) REFERENCES rents(rental_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS liabilities (
    liability_id     TEXT NOT NULL,
    rental_id        TEXT NOT NULL,
    liability_status TEXT NOT NULL DEFAULT 'Pending',
    liability_type   TEXT NOT NULL,
    liability_fee    REAL NOT NULL DEFAULT 0.0,
    PRIMARY KEY (liability_id, rental_id),
    FOREIGN KEY (rental_id) REFERENCES rents(rental_id) ON DELETE CASCADE ON UPDATE CASCADE
);