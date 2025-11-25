-- Set Exercise 7
--===Create log table first===
CREATE TABLE CW1.TrailAuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TrailID INT NOT NULL,
    UserID INT NOT NULL,
    ActionType VARCHAR(10) NOT NULL,
    ActionTimestamp DATETIME2 DEFAULT GETDATE(),
    Username VARCHAR(50) NOT NULL
);
GO

--===Create the trigger===
CREATE TRIGGER CW1.TrailInsertAudit
ON CW1.Trail
AFTER INSERT
AS
BEGIN
    INSERT INTO CW1.TrailAuditLog (TrailID, UserID, ActionType, Username)
    SELECT 
        i.TrailID, 
        i.UserID, 
        'INSERT',
        u.Username
    FROM inserted i
    JOIN CW1.[User] u ON i.UserID = u.UserID;
END;
GO

--===Insert a new trail to test the trigger===
INSERT INTO CW1.Trail (TrailName, LocationID, Difficulty, Length, ElevationGain, EstTimeMin, EstTimeMax, RouteType, Description, UserID)
VALUES ('Test Trail', 1, 'Moderate', 7.5, 200, 120, 150, 'Loop', 'Test description', 3);

--===Check the audit log===
SELECT * FROM CW1.TrailAuditLog;