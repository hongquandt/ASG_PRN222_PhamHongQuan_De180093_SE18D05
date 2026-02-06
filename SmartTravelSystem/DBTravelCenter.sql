-- =============================================
-- Smart Travel System - Database Creation Script
-- Database: DBTravelCenter
-- =============================================

-- Create database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DBTravelCenter')
BEGIN
    CREATE DATABASE DBTravelCenter;
END
GO

USE DBTravelCenter;
GO

-- =============================================
-- Drop existing tables if they exist (for clean setup)
-- =============================================
IF OBJECT_ID('Booking', 'U') IS NOT NULL
    DROP TABLE Booking;
GO

IF OBJECT_ID('Customer', 'U') IS NOT NULL
    DROP TABLE Customer;
GO

IF OBJECT_ID('Trip', 'U') IS NOT NULL
    DROP TABLE Trip;
GO

-- =============================================
-- Create Trip Table
-- =============================================
CREATE TABLE Trip (
    TripID INT IDENTITY(1,1) PRIMARY KEY,
    Code VARCHAR(30) NOT NULL UNIQUE,
    Destination NVARCHAR(200) NOT NULL,
    Price DECIMAL(12,2) NOT NULL CHECK (Price >= 0),
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Available','Booked'))
);
GO

-- =============================================
-- Create Customer Table (with Password and Role)
-- =============================================
CREATE TABLE Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Code VARCHAR(30) NOT NULL UNIQUE,
    FullName NVARCHAR(150) NOT NULL,
    Email VARCHAR(200) UNIQUE,
    Age INT CHECK (Age >= 0),
    Password NVARCHAR(100) NOT NULL,
    Role NVARCHAR(20) NOT NULL DEFAULT 'User' CHECK (Role IN ('Admin', 'User'))
);
GO

-- =============================================
-- Create Booking Table
-- =============================================
CREATE TABLE Booking (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NOT NULL,
    CustomerID INT NOT NULL,
    BookingDate DATE NOT NULL DEFAULT (GETDATE()),
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('Pending','Confirmed','Cancelled')),
    FOREIGN KEY (TripID) REFERENCES Trip(TripID),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);
GO

-- =============================================
-- Insert Sample Data - Trips
-- =============================================
INSERT INTO Trip (Code, Destination, Price, Status) VALUES
('TRP-PAR-01', N'Paris', 2150.00, 'Available'),
('TRP-TYO-02', N'Tokyo', 1890.00, 'Available'),
('TRP-NYC-03', N'New York', 1590.00, 'Booked'),
('TRP-PAR-04', N'Paris', 1990.00, 'Available'),
('TRP-LON-05', N'London', 1750.00, 'Available'),
('TRP-ROM-06', N'Rome', 1650.00, 'Available'),
('TRP-SYD-07', N'Sydney', 2800.00, 'Available'),
('TRP-DXB-08', N'Dubai', 2200.00, 'Available');
GO

-- =============================================
-- Insert Sample Data - Customers
-- =============================================
-- Admin account
INSERT INTO Customer (Code, FullName, Email, Age, Password, Role) VALUES
('CUS-001', N'Nguyen Van A', 'a.nguyen@example.com', 28, '123456', 'Admin');

-- Regular user accounts
INSERT INTO Customer (Code, FullName, Email, Age, Password, Role) VALUES
('CUS-002', N'Tran Thi B', 'b.tran@example.com', 24, 'password1', 'User'),
('CUS-003', N'Le Van C', 'c.le@example.com', 31, 'abc@123', 'User'),
('CUS-004', N'Pham Thi D', 'd.pham@example.com', 26, 'pass123', 'User'),
('CUS-005', N'Hoang Van E', 'e.hoang@example.com', 35, 'mypass', 'User');
GO

-- =============================================
-- Insert Sample Data - Bookings
-- =============================================
INSERT INTO Booking (TripID, CustomerID, BookingDate, Status) VALUES
(1, 1, '2026-01-15', 'Pending'),
(2, 2, '2026-01-20', 'Confirmed'),
(3, 3, '2026-01-25', 'Cancelled'),
(4, 2, '2026-02-01', 'Pending'),
(5, 4, '2026-02-03', 'Confirmed'),
(6, 5, '2026-02-04', 'Pending');
GO

-- =============================================
-- Verify Data
-- =============================================
PRINT '==========================================';
PRINT 'Database Setup Complete!';
PRINT '==========================================';
PRINT '';

PRINT 'Trip Table:';
SELECT TripID, Code, Destination, Price, Status FROM Trip;
PRINT '';

PRINT 'Customer Table:';
SELECT CustomerID, Code, FullName, Email, Role FROM Customer;
PRINT '';

PRINT 'Booking Table:';
SELECT BookingID, TripID, CustomerID, BookingDate, Status FROM Booking;
PRINT '';

PRINT '==========================================';
PRINT 'Login Credentials:';
PRINT '==========================================';
PRINT 'Admin Account:';
PRINT '  Code: CUS-001';
PRINT '  Password: 123456';
PRINT '';
PRINT 'User Accounts:';
PRINT '  Code: CUS-002, Password: password1';
PRINT '  Code: CUS-003, Password: abc@123';
PRINT '  Code: CUS-004, Password: pass123';
PRINT '  Code: CUS-005, Password: mypass';
PRINT '==========================================';
GO
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Customer') AND name = 'Role')
BEGIN
    ALTER TABLE Customer
    ADD Role NVARCHAR(20) NOT NULL DEFAULT 'User';
END
GO

-- Update existing customers to have roles
-- Set first customer as Admin
UPDATE Customer
SET Role = 'Admin'
WHERE Code = 'CUS-001';

-- Ensure other customers are Users
UPDATE Customer
SET Role = 'User'
WHERE Code != 'CUS-001' AND (Role IS NULL OR Role = '');
GO

-- Display updated customers
SELECT CustomerID, Code, FullName, Email, Age, Role
FROM Customer;
GO
