-- Optional backup
CREATE TABLE Pass_in_trip_backup AS
SELECT * FROM Pass_in_trip;

/*
START STAGE 1 Query
*/
-- Change the column type to DATE
ALTER TABLE Pass_in_trip
  MODIFY COLUMN trip_date DATE;

-- Normalize values (strip time portion)
UPDATE Pass_in_trip
SET trip_date = DATE(trip_date);

-- Verify the changes by selecting all columns
SELECT *
FROM Pass_in_trip;

/*
END STAGE 1 Query
*/

-- Show rows for a specific date (example: 2024-02-23)
SELECT *
FROM Pass_in_trip
WHERE trip_date = '2024-02-23';

-- Count how many rows were affected (non-null dates)
SELECT COUNT(*) AS rows_with_date
FROM Pass_in_trip;

-- Check for any remaining time components (should return 0 after conversion)
SELECT COUNT(*) AS rows_with_time_component
FROM Pass_in_trip
WHERE TIME(trip_date) <> '00:00:00';