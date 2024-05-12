-- Tables

CREATE TABLE CarModels (
    carId INT IDENTITY(1,1) PRIMARY KEY,
    model VARCHAR(100),
    company VARCHAR(100),
    class VARCHAR(50),
    cost DECIMAL(10, 2)
);

CREATE TABLE Addresses (
    addressId INT IDENTITY(1,1) PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100),
    place VARCHAR(100)
);

CREATE TABLE Users (
    userId INT IDENTITY(1,1) PRIMARY KEY,
    userName VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    phone VARCHAR(20),
    driversLicenseId VARCHAR(100),
    passportId VARCHAR(100)
);

CREATE TABLE Rental (
    rentalId INT IDENTITY(1,1) PRIMARY KEY,
    carId INT FOREIGN KEY REFERENCES CarModels(carId),
    userId INT FOREIGN KEY REFERENCES Users(userId),
    dateStart DATETIME,
    dateEnd DATETIME,
    cost DECIMAL(10, 2)
);
ALTER TABLE Rental
ADD success VARCHAR(3) DEFAULT 'yes';


CREATE TABLE CarStaff (
    carId INT FOREIGN KEY REFERENCES CarModels(carId),
    addressId INT FOREIGN KEY REFERENCES Addresses(addressId),
    status VARCHAR(50)
);

-- Data insertion for CarModels
-- Note: Adjust values as required, these are just examples

INSERT INTO CarModels (model, company, class, cost) VALUES
('Chevrolet Cruze213', 'Chevrolet', 'Sedan', 23000.00),
('Audi B34', 'Audi', 'Sedan', 38000.00),
('Chevrolet Cruze213', 'Chevrolet', 'Sedan', 23000.00),
('Audi B342', 'Audi', 'Sedan', 38000.00),
('Chevrolet 2', 'Chevrolet', 'Sedan', 23000.00),
('BMW M6', 'BMW', 'Sedan', 38000.00),
('Chevrolet 22', 'Chevrolet', 'Sedan', 23000.00),
('BMW M6', 'BMW', 'Sedan', 38000.00),
('Chevrolet 257', 'Chevrolet', 'Sedan', 23000.00),
('BMW 12', 'BMW', 'Sedan', 38000.00),
('Chevrolet 25736', 'Chevrolet', 'Sedan', 23000.00),
('BMW 57', 'BMW', 'Sedan', 38000.00)

-- Add more values as needed for other car models

-- Data insertion for Addresses
-- Note: Adjust values as required, these are just examples

INSERT INTO Addresses (country, city, place) VALUES
('Canada', 'Toronto', '789 Maple Ave'),
('Australia', 'Sydney', '456 George St')
-- Add more values as needed for other addresses

-- Data insertion for Users
DECLARE @i INT = 1;
WHILE @i <= 30
BEGIN
    INSERT INTO Users (userName, password, phone, driversLicenseId, passportId)
    VALUES (CONCAT('user', @i), CONCAT('password', @i), '+1234567890', CONCAT('DL', @i), CONCAT('PASS', @i));
    SET @i = @i + 1;
END

-- Data insertion for Rental and CarStaff are similarly done with loop and random functions
-- Example for Rental (modify logic for randomness and date functions as required)

DECLARE @j INT = 1;
WHILE @j <= 30
BEGIN
    DECLARE @startDate DATETIME = DATEADD(DAY, -CAST(RAND()*30 AS INT), GETDATE());
    DECLARE @endDate DATETIME = DATEADD(DAY, CAST(RAND()*10 AS INT), @startDate);
    DECLARE @carId INT = CAST(RAND()*13 AS INT) + 1;
    DECLARE @userId INT = CAST(RAND()*27 AS INT) + 1;
    INSERT INTO Rental (carId, userId, dateStart, dateEnd, cost)
    VALUES (@carId, @userId, @startDate, @endDate, ROUND(RAND()*(1000-100)+100, 2));
    SET @j = @j + 1;
END

select * from CarModels;

-- Data insertion for CarStaff
DECLARE @k INT = 1;
WHILE @k <= 25
BEGIN
    DECLARE @carId INT = (SELECT TOP 1 carId FROM CarModels ORDER BY NEWID());
    DECLARE @addressId INT = (SELECT TOP 1 addressId FROM Addresses ORDER BY NEWID());
    INSERT INTO CarStaff (carId, addressId, status) VALUES (@carId, @addressId, 'Available');
    SET @k = @k + 1;
END
