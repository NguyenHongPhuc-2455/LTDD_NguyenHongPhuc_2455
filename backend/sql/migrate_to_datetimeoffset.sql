-- Migration: Convert DATETIME to DATETIMEOFFSET for Vietnam timezone support
-- Run this in SQL Server Management Studio

USE NHPCalendar;
GO

-- Step 1: Add new DATETIMEOFFSET columns
ALTER TABLE Events
ADD StartTimeOffset DATETIMEOFFSET NULL,
    EndTimeOffset DATETIMEOFFSET NULL;
GO

-- Step 2: Migrate existing data
-- Convert existing DATETIME to DATETIMEOFFSET with Vietnam timezone (+07:00)
UPDATE Events
SET StartTimeOffset = TODATETIMEOFFSET(StartTime, '+07:00'),
    EndTimeOffset = TODATETIMEOFFSET(EndTime, '+07:00');
GO

-- Step 3: Drop old columns
ALTER TABLE Events
DROP COLUMN StartTime, EndTime;
GO

-- Step 4: Rename new columns to original names
EXEC sp_rename 'Events.StartTimeOffset', 'StartTime', 'COLUMN';
EXEC sp_rename 'Events.EndTimeOffset', 'EndTime', 'COLUMN';
GO

-- Step 5: Make columns NOT NULL
ALTER TABLE Events
ALTER COLUMN StartTime DATETIMEOFFSET NOT NULL;

ALTER TABLE Events
ALTER COLUMN EndTime DATETIMEOFFSET NOT NULL;
GO

PRINT 'Migration completed successfully!';
PRINT 'StartTime and EndTime are now DATETIMEOFFSET with Vietnam timezone (+07:00)';
