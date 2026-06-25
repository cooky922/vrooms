PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS units (
    unitID INTEGER PRIMARY KEY AUTOINCREMENT,
    plateNumber TEXT NOT NULL UNIQUE,
    unitModel TEXT NOT NULL,
    unitPicture TEXT DEFAULT NULL,
    unitStatus TEXT NOT NULL CHECK(unitStatus IN ('Available', 'Rented', 'Maintenance')),
    dailyRate REAL NOT NULL CHECK (dailyRate > 0),
    registrationDate TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_unitStatus ON units(unitStatus);
CREATE INDEX IF NOT EXISTS idx_plateNumber ON units(plateNumber);

CREATE TABLE IF NOT EXISTS customers (
    customerID INTEGER PRIMARY KEY AUTOINCREMENT,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    phoneNumber TEXT NOT NULL UNIQUE,
    homeAddress TEXT NOT NULL,
    driverLicenseID TEXT NOT NULL UNIQUE,
    driverLicenseIDPicture TEXT NOT NULL,
    customerStatus TEXT NOT NULL CHECK(customerStatus IN ('Active', 'Suspended', 'Blacklisted')),
    registrationDate TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_customerStatus ON customers(customerStatus);

CREATE TABLE IF NOT EXISTS rents (
    rentID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER NOT NULL,
    unitID INTEGER NOT NULL,
    rentStatus TEXT NOT NULL CHECK(rentStatus IN ('Cancelled', 'Ongoing', 'Flagged', 'Closed')),
    rentDateTime TEXT NOT NULL,
    expectedReturnDate TEXT NOT NULL,
    actualReturnDateTime TEXT DEFAULT NULL,
    rentBaseCost REAL NOT NULL,

    FOREIGN KEY (customerID) REFERENCES customers(customerID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (unitID) REFERENCES units(unitID) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_rental_dates CHECK (rentDateTime <= expectedReturnDate)
);
CREATE INDEX IF NOT EXISTS idx_rent_customer ON rents(customerID);
CREATE INDEX IF NOT EXISTS idx_rent_unit ON rents(unitID);
CREATE INDEX IF NOT EXISTS idx_rentStatus ON rents(rentStatus);

CREATE TABLE IF NOT EXISTS payments (
    paymentID INTEGER PRIMARY KEY AUTOINCREMENT,
    rentID INTEGER NOT NULL,
    amountPaid REAL NOT NULL,
    paymentDateTime TEXT NOT NULL,
    paymentType TEXT NOT NULL CHECK(paymentType IN ('Base Fee', 'Liability Fee')),
    FOREIGN KEY (rentID) REFERENCES rents(rentID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_payment_rent ON payments(rentID);

CREATE TABLE IF NOT EXISTS liabilities (
    liabilityID INTEGER PRIMARY KEY AUTOINCREMENT,
    rentID INTEGER NOT NULL,
    liabilityType TEXT NOT NULL CHECK(liabilityType IN ('Overdue', 'Damage', 'Equipment Loss', 'Other')),
    liabilityFee REAL NOT NULL,
    liabilityStatus TEXT NOT NULL CHECK(liabilityStatus IN ('Active', 'Cleared')),
    FOREIGN KEY (rentID) REFERENCES rents(rentID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_liability_rent ON liabilities(rentID);
CREATE INDEX IF NOT EXISTS idx_liabilityStatus ON liabilities(liabilityStatus);