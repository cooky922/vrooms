PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS units (
    plateNumber TEXT PRIMARY KEY,
    unitModel TEXT NOT NULL,
    unitPicture TEXT DEFAULT NULL,
    unitStatus TEXT NOT NULL CHECK(unitStatus IN ('Available', 'Rented', 'Maintenance')),
    dailyRate REAL NOT NULL CHECK (dailyRate > 0),
    registrationDate TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_unitStatus ON units(unitStatus);

CREATE TABLE IF NOT EXISTS customers (
    customerID INTEGER PRIMARY KEY AUTOINCREMENT,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    contactNumber TEXT NOT NULL UNIQUE,
    homeAddress TEXT NOT NULL,
    driverLicenseID TEXT NOT NULL UNIQUE,
    driverLicenseIDPicture TEXT NOT NULL,
    customerStatus TEXT NOT NULL CHECK(customerStatus IN ('Active', 'Suspended', 'Blacklisted')),
    registrationDate TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_customerStatus ON customers(customerStatus);

CREATE TABLE IF NOT EXISTS rents (
    rentalID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER NOT NULL,
    unitPlateNumber TEXT NOT NULL,
    rentalStatus TEXT NOT NULL CHECK(rentalStatus IN ('Cancelled', 'Active', 'Returned with Liabilities', 'Completed')),
    rentalDateTime TEXT NOT NULL,
    expectedReturnDateTime TEXT NOT NULL,
    actualReturnDateTime TEXT DEFAULT NULL,
    rentalBaseCost REAL NOT NULL,
    
    FOREIGN KEY (customerID) REFERENCES customers(customerID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (unitPlateNumber) REFERENCES units(plateNumber) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_rental_dates CHECK (rentalDateTime <= expectedReturnDateTime)
);
CREATE INDEX IF NOT EXISTS idx_rental_customer ON rents(customerID);
CREATE INDEX IF NOT EXISTS idx_rental_unit ON rents(unitPlateNumber);
CREATE INDEX IF NOT EXISTS idx_rentalStatus ON rents(rentalStatus);

CREATE TABLE IF NOT EXISTS payments (
    paymentID INTEGER PRIMARY KEY AUTOINCREMENT,
    rentalID INTEGER NOT NULL,
    amountPaid REAL NOT NULL,
    paymentDateTime TEXT NOT NULL,
    paymentType TEXT NOT NULL CHECK(paymentType IN ('Base Fee', 'Liability Fee')),
    FOREIGN KEY (rentalID) REFERENCES rents(rentalID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_payment_rental ON payments(rentalID);

CREATE TABLE IF NOT EXISTS liabilities (
    liabilityID INTEGER PRIMARY KEY AUTOINCREMENT,
    rentalID INTEGER NOT NULL,
    liabilityType TEXT NOT NULL CHECK(liabilityType IN ('Overdue', 'Damage', 'Equipment Loss', 'Other')),
    liabilityFee REAL NOT NULL,
    liabilityStatus TEXT NOT NULL CHECK(liabilityStatus IN ('Active', 'Cleared')),
    FOREIGN KEY (rentalID) REFERENCES rents(rentalID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_liability_rental ON liabilities(rentalID);
CREATE INDEX IF NOT EXISTS idx_liabilityStatus ON liabilities(liabilityStatus);