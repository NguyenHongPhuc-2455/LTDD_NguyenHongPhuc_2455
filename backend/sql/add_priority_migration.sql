-- Migration: Add Priority Support to Calendar System
-- Run this script on your NHPCalendar database

USE NHPCalendar;
GO

-- Create Priorities Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Priorities')
BEGIN
    CREATE TABLE Priorities (
        PriorityID INT PRIMARY KEY IDENTITY(1,1),
        LevelName NVARCHAR(50) NOT NULL UNIQUE,
        ColorCode VARCHAR(7) NOT NULL,
        Weight INT NOT NULL
    );

    -- Insert Default Priority Levels
    INSERT INTO Priorities (LevelName, ColorCode, Weight) VALUES
        (N'Low', '#4CAF50', 1),        -- Green
        (N'Medium', '#FFC107', 2),     -- Yellow
        (N'High', '#FF9800', 3),       -- Orange
        (N'Urgent', '#F44336', 4);     -- Red

    PRINT 'Priorities table created and default levels inserted.';
END
ELSE
BEGIN
    PRINT 'Priorities table already exists.';
END
GO

-- Add PriorityID to Events Table
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Events') 
               AND name = 'PriorityID')
BEGIN
    -- Add the column (nullable first)
    ALTER TABLE Events
    ADD PriorityID INT NULL;

    -- Set default priority to "Medium" (ID = 2) for existing events
    UPDATE Events
    SET PriorityID = 2
    WHERE PriorityID IS NULL;

    -- Make it non-nullable
    ALTER TABLE Events
    ALTER COLUMN PriorityID INT NOT NULL;

    -- Add foreign key constraint
    ALTER TABLE Events
    ADD CONSTRAINT FK_Events_Priority 
    FOREIGN KEY (PriorityID) REFERENCES Priorities(PriorityID);

    PRINT 'PriorityID column added to Events table with foreign key.';
END
ELSE
BEGIN
    PRINT 'PriorityID column already exists in Events table.';
END
GO

PRINT 'Migration completed successfully!';
