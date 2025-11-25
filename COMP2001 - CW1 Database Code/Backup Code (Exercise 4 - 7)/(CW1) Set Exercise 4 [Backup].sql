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