-- Migration: Add Email and OTP columns to Users table
USE NHPCalendar;
GO

-- Add Email column (nullable for existing users)
ALTER TABLE Users
ADD Email NVARCHAR(255) NULL;
GO

-- Add unique constraint on Email (allows NULL)
CREATE UNIQUE NONCLUSTERED INDEX UQ_Users_Email 
ON Users(Email) 
WHERE Email IS NOT NULL;
GO

-- Add OTP columns
ALTER TABLE Users
ADD OTPCode NVARCHAR(6) NULL,
    OTPExpiry DATETIMEOFFSET NULL;
GO

PRINT 'Email and OTP columns added successfully!';
