-- Create Database if not exists
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'NHPCalendar')
BEGIN
    CREATE DATABASE NHPCalendar;
END
GO

USE NHPCalendar;
GO

-- Create Roles Table
CREATE TABLE Roles (
    RoleID INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL UNIQUE
);

-- Create Users Table
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    Password NVARCHAR(255) NOT NULL,
    FullName NVARCHAR(100),
    RoleID INT NOT NULL,
    TwoFactorSecret NVARCHAR(100),
    Is2FAEnabled BIT DEFAULT 0,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);

-- Create Events Table
CREATE TABLE Events (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    Title NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    UserID INT NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Insert Default Roles
INSERT INTO Roles (RoleName) VALUES (N'Admin'), (N'Nhân viên'), (N'Khách hàng');
