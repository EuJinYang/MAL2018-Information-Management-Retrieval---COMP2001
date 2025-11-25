-- Set Exercise 4
--===Create Database===
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TrailDB')
BEGIN
    CREATE DATABASE TrailDB;
END
GO

--===Create CW1 Schema===
USE TrailDB;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CW1')
BEGIN
    EXEC('CREATE SCHEMA CW1');
END
GO

--===Create USER Table===
CREATE TABLE CW1.[User] (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    [Password] VARCHAR(100) NOT NULL
);

--===Create TRAIL Table===
CREATE TABLE CW1.Trail (
    TrailID INT IDENTITY(1,1) PRIMARY KEY,
    TrailName NVARCHAR(100) NOT NULL,
    LocationID INT NOT NULL,
    Difficulty VARCHAR(20) NOT NULL CHECK (Difficulty IN ('Easy', 'Moderate', 'Hard')),
    Length DECIMAL(5,2) NOT NULL,
    ElevationGain INT NULL,
    EstTimeMin INT NOT NULL,
    EstTimeMax INT NOT NULL,
    RouteType VARCHAR(20) NOT NULL CHECK (RouteType IN ('Loop', 'Out & back', 'Point-to-point')),
    Description NVARCHAR(MAX) NULL,
    UserID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES CW1.[User](UserID)
);

--===Create FEATURE Table===
CREATE TABLE CW1.Feature (
    FeatureID INT IDENTITY(1,1) PRIMARY KEY,
    FeatureName NVARCHAR(50) NOT NULL
);

--===Create TRAIL_FEATURE Table (Link Entity)===
CREATE TABLE CW1.Trail_Feature (
    TrailID INT NOT NULL,
    FeatureID INT NOT NULL,
    PRIMARY KEY (TrailID, FeatureID),
    FOREIGN KEY (TrailID) REFERENCES CW1.Trail(TrailID) ON DELETE CASCADE,
    FOREIGN KEY (FeatureID) REFERENCES CW1.Feature(FeatureID)
);


--===Insert Users Sample Data (from the assessment)===
INSERT INTO CW1.[User] (UserID, Username, Email, [Password]) VALUES
(1, 'Ada Lovelace', 'grace@plymouth.ac.uk', 'ISAD123!'),
(2, 'Tim Berners-Lee', 'tim@plymouth.ac.uk', 'COMP2001!'),
(3, 'Ada Lovelace', 'ada@plymouth.ac.uk', 'insecurePassword');

--===Insert Trails Sample Data===
INSERT INTO CW1.Trail (TrailName, LocationID, Difficulty, Length, ElevationGain, EstTimeMin, EstTimeMax, RouteType, Description, UserID) VALUES
('Plymbridge Circular', 1, 'Easy', 5.2, 120, 90, 120, 'Loop', 'Beautiful woodland walk along the river.', 1),
('Waterfront Walk', 1, 'Easy', 3.5, 50, 60, 75, 'Out & back', 'Scenic coastal path with harbor views.', 2);

--===Insert Features Sample Data===
INSERT INTO CW1.Feature (FeatureName) VALUES
('Dog Friendly'),
('Forest'),
('River Views'),
('Historic Site'),
('Picnic Area'),
('Parking Available');

--===Link Trails to Features Sample Data===
INSERT INTO CW1.Trail_Feature (TrailID, FeatureID) VALUES
(1, 2), (1, 3), (1, 5),  -- Plymbridge: Forest, River Views, Picnic Area
(2, 3), (2, 6);          -- Waterfront: River Views, Parking Available

--===Verify Sample Data===
SELECT * FROM CW1.[User];
SELECT * FROM CW1.Trail;
SELECT * FROM CW1.Feature;
SELECT * FROM CW1.Trail_Feature;
GO



-- Set Exercise 5
--===Create View===
CREATE VIEW CW1.TrailDetails AS
SELECT 
    t.TrailID,
    t.TrailName,
    t.Difficulty,
    t.Length,
    t.ElevationGain,
    t.EstTimeMin,
    t.EstTimeMax,
    t.RouteType,
    t.Description,
    u.Username AS TrailOwner,
    STRING_AGG(f.FeatureName, ', ') AS Features
FROM CW1.Trail t
JOIN CW1.[User] u ON t.UserID = u.UserID
LEFT JOIN CW1.Trail_Feature tf ON t.TrailID = tf.TrailID
LEFT JOIN CW1.Feature f ON tf.FeatureID = f.FeatureID
GROUP BY 
    t.TrailID, t.TrailName, t.Difficulty, t.Length, t.ElevationGain,
    t.EstTimeMin, t.EstTimeMax, t.RouteType, t.Description, u.Username;

--===Test the View===
SELECT * FROM CW1.TrailDetails;



-- Set Exercise 6
--===CREATE===
CREATE PROCEDURE CW1.CreateTrail
    @TrailName NVARCHAR(100),
    @LocationID INT,
    @Difficulty VARCHAR(20),
    @Length DECIMAL(5,2),
    @ElevationGain INT,
    @EstTimeMin INT,
    @EstTimeMax INT,
    @RouteType VARCHAR(20),
    @Description NVARCHAR(500),
    @UserID INT,
    @NewTrailID INT OUTPUT
AS
BEGIN
    INSERT INTO CW1.Trail (TrailName, LocationID, Difficulty, Length, ElevationGain, EstTimeMin, EstTimeMax, RouteType, Description, UserID)
    VALUES (@TrailName, @LocationID, @Difficulty, @Length, @ElevationGain, @EstTimeMin, @EstTimeMax, @RouteType, @Description, @UserID);
    
    SET @NewTrailID = SCOPE_IDENTITY();
END;
GO

--===READ (Get by ID)===
CREATE PROCEDURE CW1.GetTrailByID
    @TrailID INT
AS
BEGIN
    SELECT * FROM CW1.Trail WHERE TrailID = @TrailID;
END;
GO

--===READ (Get all)===
CREATE PROCEDURE CW1.GetAllTrails
AS
BEGIN
    SELECT * FROM CW1.Trail;
END;
GO

--===UPDATE===
CREATE PROCEDURE CW1.UpdateTrail
    @TrailID INT,
    @TrailName NVARCHAR(100),
    @Difficulty VARCHAR(20),
    @Length DECIMAL(5,2),
    @ElevationGain INT,
    @EstTimeMin INT,
    @EstTimeMax INT,
    @RouteType VARCHAR(20),
    @Description NVARCHAR(500)
AS
BEGIN
    UPDATE CW1.Trail 
    SET TrailName = @TrailName,
        Difficulty = @Difficulty,
        Length = @Length,
        ElevationGain = @ElevationGain,
        EstTimeMin = @EstTimeMin,
        EstTimeMax = @EstTimeMax,
        RouteType = @RouteType,
        Description = @Description
    WHERE TrailID = @TrailID;
END;
GO

--===DELETE===
CREATE PROCEDURE CW1.DeleteTrail
    @TrailID INT
AS
BEGIN
    DELETE FROM CW1.Trail WHERE TrailID = @TrailID;
END;
GO

--===TEST 1: GET ALL TRAILS (Before creating new ones)===
EXEC CW1.GetAllTrails;
GO

--===TEST 2: CREATE NEW TRAIL===
DECLARE @NewTrailID INT;

EXEC CW1.CreateTrail 
    @TrailName = 'Drakes Trail Circular',
    @LocationID = 1,
    @Difficulty = 'Moderate',
    @Length = 8.5,
    @ElevationGain = 250,
    @EstTimeMin = 120,
    @EstTimeMax = 180,
    @RouteType = 'Loop',
    @Description = 'Challenging circular route with stunning valley views',
    @UserID = 2,
    @NewTrailID = @NewTrailID OUTPUT;

PRINT 'New Trail Created with ID: ' + CAST(@NewTrailID AS VARCHAR(10));
SELECT @NewTrailID AS NewTrailID;
GO

--===TEST 3: GET ALL TRAILS (After creation)===
EXEC CW1.GetAllTrails;
GO

--===TEST 4: GET SPECIFIC TRAIL BY ID===
EXEC CW1.GetTrailByID @TrailID = 3;  -- Use the ID from your new trail
GO

--===TEST 5: UPDATE TRAIL===
--First show the trail before update
PRINT 'BEFORE UPDATE:';
EXEC CW1.GetTrailByID @TrailID = 3;

--Perform the update
EXEC CW1.UpdateTrail 
    @TrailID = 3,
    @TrailName = 'Drakes Trail Circular - Extended',
    @Difficulty = 'Hard',
    @Length = 10.2,
    @ElevationGain = 350,
    @EstTimeMin = 150,
    @EstTimeMax = 210,
    @RouteType = 'Loop',
    @Description = 'Extended challenging circular route with stunning valley views and additional woodland section';

--Show the trail after update
PRINT 'AFTER UPDATE:';
EXEC CW1.GetTrailByID @TrailID = 3;
GO

--===TEST 6: DELETE TRAIL===
--Show all trails before deletion
PRINT 'BEFORE DELETE:';
EXEC CW1.GetAllTrails;

--Delete the trail
EXEC CW1.DeleteTrail @TrailID = 3;

--Show all trails after deletion
PRINT 'AFTER DELETE:';
EXEC CW1.GetAllTrails;
GO



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