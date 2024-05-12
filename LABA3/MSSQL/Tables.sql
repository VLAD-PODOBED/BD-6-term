CREATE TABLE CarModels (
    carId INT IDENTITY(1,1) PRIMARY KEY,
    model NVARCHAR(100),
    company NVARCHAR(100),
    class NVARCHAR(50),
    cost DECIMAL(10, 2),
    hierarchyCars HIERARCHYID,
	Level AS hierarchyCars.GetLevel() PERSISTED
);

CREATE TABLE Addresses (
    addressId INT IDENTITY(1,1) PRIMARY KEY,
    country NVARCHAR(100),
    city NVARCHAR(100),
    place NVARCHAR(100)
);

CREATE TABLE Users (
    userId INT IDENTITY(1,1) PRIMARY KEY,
    userName NVARCHAR(100) UNIQUE,
    password NVARCHAR(100),
    phone NVARCHAR(20),
    driversLicenseId NVARCHAR(100),
    passportId NVARCHAR(100)
);

CREATE TABLE Rentals (
    rentalId INT IDENTITY(1,1) PRIMARY KEY,
    carId INT FOREIGN KEY REFERENCES CarModels(carId),
    userId INT FOREIGN KEY REFERENCES Users(userId),
    dateStart DATETIME,
    dateEnd DATETIME,
    cost DECIMAL(10, 2)
);

CREATE TABLE CarStaff (
    carId INT FOREIGN KEY REFERENCES CarModels(carId),
    addressId INT FOREIGN KEY REFERENCES Addresses(addressId),
    status NVARCHAR(50)
);

CREATE INDEX idx_users_username ON Users(userName);
CREATE INDEX idx_users_drivers_license_id ON Users(driversLicenseId);
CREATE INDEX idx_users_passport_id ON Users(passportId);

CREATE INDEX idx_rentals_user_id ON Rentals(userId);

CREATE INDEX idx_carstaff_car_id ON CarStaff(carId);
CREATE INDEX idx_carstaff_address_id ON CarStaff(addressId);