-- Quick Fix: Add PriorityID column to Events table
USE NHPCalendar;
GO

-- Check if PriorityID column exists, if not, add it
IF NOT EXISTS (SELECT * FROM sys.columns 
               WHERE object_id = OBJECT_ID('Events') 
               AND name = 'PriorityID')
BEGIN
    PRINT 'Adding PriorityID column...';
    
    -- Add the column (nullable first)
    ALTER TABLE Events
    ADD PriorityID INT NULL;

    -- Set default priority to "Medium" (ID = 2) for all events
    UPDATE Events
    SET PriorityID = 2;

    -- Make it non-nullable
    ALTER TABLE Events
    ALTER COLUMN PriorityID INT NOT NULL;

    -- Add foreign key constraint
    ALTER TABLE Events
    ADD CONSTRAINT FK_Events_Priority 
    FOREIGN KEY (PriorityID) REFERENCES Priorities(PriorityID);

    PRINT 'PriorityID column added successfully!';
END
ELSE
BEGIN
    PRINT 'PriorityID column already exists.';
END
GO
