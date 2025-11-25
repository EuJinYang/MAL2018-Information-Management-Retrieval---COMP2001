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