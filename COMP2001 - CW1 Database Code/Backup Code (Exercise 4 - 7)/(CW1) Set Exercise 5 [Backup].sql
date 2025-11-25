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