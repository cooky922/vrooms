PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS units (
    unitID INTEGER PRIMARY KEY AUTOINCREMENT,
    plateNumber TEXT NOT NULL UNIQUE,
    unitBrand TEXT NOT NULL,
    unitModel TEXT NOT NULL,
    unitColor TEXT NOT NULL,
    unitYear INTEGER NOT NULL,
    unitPicture TEXT DEFAULT NULL,
    unitStatus TEXT NOT NULL DEFAULT 'Available' CHECK(unitStatus IN ('Available', 'Rented', 'Maintenance')),
    dailyRate REAL NOT NULL CHECK (dailyRate > 0),
    dateAdded TEXT NOT NULL DEFAULT CURRENT_DATE
);
CREATE INDEX IF NOT EXISTS idx_unitStatus ON units(unitStatus);
CREATE INDEX IF NOT EXISTS idx_plateNumber ON units(plateNumber);

CREATE TABLE IF NOT EXISTS customers (
    customerID INTEGER PRIMARY KEY AUTOINCREMENT,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    phoneNumber TEXT NOT NULL UNIQUE,
    emailAddress TEXT NOT NULL UNIQUE,
    homeAddress TEXT NOT NULL,
    profilePicture TEXT DEFAULT NULL,
    driverLicenseID TEXT NOT NULL UNIQUE,
    driverLicenseIDPicture TEXT NOT NULL,
    driverLicenseExpiryDate TEXT NOT NULL,
    customerStatus TEXT NOT NULL DEFAULT 'Active' CHECK(customerStatus IN ('Active', 'Blacklisted')),
    dateRegistered TEXT NOT NULL DEFAULT CURRENT_DATE
);
CREATE INDEX IF NOT EXISTS idx_customerStatus ON customers(customerStatus);

CREATE TABLE IF NOT EXISTS rents (
    rentID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER NOT NULL,
    unitID INTEGER NOT NULL,
    rentStatus TEXT NOT NULL DEFAULT 'Ongoing' CHECK(rentStatus IN ('Ongoing', 'Closed')),
    rentDateTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expectedReturnDateTime TEXT NOT NULL,
    actualReturnDateTime TEXT DEFAULT NULL,
    rentFee REAL NOT NULL DEFAULT 0.0,
    
    FOREIGN KEY (customerID) REFERENCES customers(customerID) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (unitID) REFERENCES units(unitID) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_rental_dates CHECK (
        rentDateTime <= expectedReturnDateTime AND 
        julianday(expectedReturnDateTime) <= julianday(rentDateTime) + 7
    )
);
CREATE INDEX IF NOT EXISTS idx_rent_customer ON rents(customerID);
CREATE INDEX IF NOT EXISTS idx_rent_unit ON rents(unitID);
CREATE INDEX IF NOT EXISTS idx_rentStatus ON rents(rentStatus);

CREATE TABLE IF NOT EXISTS liabilities (
    liabilityID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER NOT NULL,
    liabilityDescription TEXT NOT NULL,
    liabilityFee REAL NOT NULL CHECK (liabilityFee > 0),
    liabilityStatus TEXT NOT NULL DEFAULT 'Pending' CHECK(liabilityStatus IN ('Pending', 'Settled')),
    issuedDateTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customerID) REFERENCES customers(customerID) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_liability_customer ON liabilities(customerID);
CREATE INDEX IF NOT EXISTS idx_liabilityStatus ON liabilities(liabilityStatus);

CREATE TABLE IF NOT EXISTS payments (
    paymentID INTEGER PRIMARY KEY AUTOINCREMENT,
    customerID INTEGER NOT NULL,
    liabilityID INTEGER DEFAULT NULL,
    paidAmount REAL NOT NULL CHECK (paidAmount > 0),
    paymentDateTime TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customerID) REFERENCES customers(customerID) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (liabilityID) REFERENCES liabilities(liabilityID) ON DELETE RESTRICT ON UPDATE RESTRICT
);
CREATE INDEX IF NOT EXISTS idx_payment_customer ON payments(customerID);
CREATE INDEX IF NOT EXISTS idx_payment_liability ON payments(liabilityID);