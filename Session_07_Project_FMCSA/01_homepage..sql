

/*
Practice 7 - 01_homepage.sql

CTE version calculates the shared as-of date inside each date-based query.

 Page A - Homepage overview

The homepage has 8 main outputs:
    1. total carriers
    2. total inspections
    3. data freshness
    4. latest crashes in the last 8 weeks
    5. fatal / injury / tow crash counts
    6. weekly crash date range and crash count
    7. crash map points
    8. carrier search by DOT, MC, company, phone, address, email, VIN, plate, insurer, or officer

The homepage uses these clean tables:
    - dim_carrier
    - fact_inspection
    - fact_crash
    - fact_insp_vehicle
    - dim_insurance
    - fact_authority

All queries in this file are SELECT queries.
They read data only and do not change any table.
*/

USE usaTrucking;
GO

-- 4M+ Carriers
-- Counts total carriers on file.
SELECT
    '4M+ Carriers' AS homepage_metric,
    COUNT(*) AS carrier_count
FROM dbo.dim_carrier;

-- 3M+ Inspections
-- Counts total inspections on file.
SELECT
    '3M+ Inspections' AS homepage_metric,
    COUNT(*) AS inspection_count
FROM dbo.fact_inspection;

-- Data freshness = Live
-- Shows the latest shared data date and labels the data as Live.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash

    ) AS all_dates
)
SELECT
    'Data freshness' AS homepage_metric,
    asof AS latest_data_date,
    'Live' AS freshness_label
FROM asof_date;

-- Latest Crashes - last 8 weeks
-- Counts crashes from the last 56 days.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash

    ) AS all_dates
)
SELECT
    'Latest Crashes - last 8 weeks' AS homepage_metric,
    COUNT(*) AS crash_count,
    DATEADD(day, -56, a.asof) AS start_date,
    a.asof AS end_date
FROM dbo.fact_crash AS c
CROSS JOIN asof_date AS a
WHERE c.crash_date >= DATEADD(day, -56, a.asof)
  AND c.crash_date <= a.asof
GROUP BY a.asof;

-- Fatal / Injury / Tow counts
-- Splits last-8-week crashes by severity.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash

    ) AS all_dates
)
SELECT
    'Fatal / Injury / Tow counts' AS homepage_metric,
    SUM(CASE WHEN c.fatal > 0 THEN 1 ELSE 0 END) AS fatal_crashes,
    SUM(CASE WHEN c.injury > 0 THEN 1 ELSE 0 END) AS injury_crashes,
    SUM(CASE WHEN c.tow = 1 THEN 1 ELSE 0 END) AS tow_crashes
FROM dbo.fact_crash AS c
CROSS JOIN asof_date AS a
WHERE c.crash_date >= DATEADD(day, -56, a.asof)
  AND c.crash_date <= a.asof;

-- Date range + N crashes
-- Shows recent weekly crash buckets with start date, end date, and crash count.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash

    ) AS all_dates
)
SELECT TOP (8)
    DATEPART(year, c.crash_date) AS crash_year,
    DATEPART(week, c.crash_date) AS crash_week,
    MIN(c.crash_date) AS week_start_date,
    MAX(c.crash_date) AS week_end_date,
    COUNT(*) AS crash_count
FROM dbo.fact_crash AS c
CROSS JOIN asof_date AS a
WHERE c.crash_date >= DATEADD(week, -8, a.asof)
  AND c.crash_date <= a.asof
GROUP BY
    DATEPART(year, c.crash_date),
    DATEPART(week, c.crash_date)
ORDER BY
    week_start_date DESC;

-- Crash map points
-- The PDF mentions lat/long, but this FMCSA Crash File provides state/city/location.
-- Latitude and longitude are included as blank placeholder fields.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash
    ) AS all_dates
)
SELECT TOP (500)
    c.crash_id,
    c.dot,
    c.crash_date,
    c.state,
    c.city,
    c.location,
    c.latitude,
    c.longitude,
    c.fatal,
    c.injury,
    c.tow
FROM dbo.fact_crash AS c
CROSS JOIN asof_date AS a
WHERE c.crash_date >= DATEADD(day, -56, a.asof)
  AND c.crash_date <= a.asof
  AND latitude IS NOT NULL
  AND longitude IS NOT NULL
ORDER BY c.crash_date DESC;

-- Search by DOT/MC/Company/Phone/Address/Email/VIN/Plate/Insurer/Officer
-- Change this one value to test different searches.
DECLARE @search varchar(100) = 'FEDEX';

-- Search part 1: carrier fields
-- Covers DOT, company name, DBA, phone, address, email, and officer.
SELECT TOP (100)
    c.dot,
    c.name,
    c.dba,
    c.phone,
    c.email,
    c.officer,
    c.physical_street,
    c.physical_city,
    c.physical_state,
    c.physical_zip
FROM dbo.dim_carrier AS c
WHERE
       CAST(c.dot AS varchar(20)) = @search
    OR c.name LIKE '%' + @search + '%'
    OR c.dba LIKE '%' + @search + '%'
    OR c.phone LIKE '%' + @search + '%'
    OR c.email LIKE '%' + @search + '%'
    OR c.officer LIKE '%' + @search + '%'
    OR c.physical_street LIKE '%' + @search + '%'
    OR c.physical_city LIKE '%' + @search + '%'
    OR c.physical_state LIKE '%' + @search + '%'
    OR c.physical_zip LIKE '%' + @search + '%'
ORDER BY c.name;

-- Search part 2: MC / docket fields
-- Covers MC/docket search from authority history.
SELECT TOP (100)
    c.dot,
    c.name,
    c.dba,
    a.docket_number,
    a.auth_type,
    a.status,
    a.grant_date
FROM dbo.fact_authority AS a
JOIN dbo.dim_carrier AS c
    ON a.dot = c.dot
WHERE a.docket_number LIKE '%' + @search + '%'
ORDER BY c.name;

-- Search part 3: VIN / plate fields
-- Covers VIN and license plate search from inspection vehicle table.
SELECT DISTINCT TOP (100)
    c.dot,
    c.name,
    c.dba,
    v.vin,
    v.license_plate,
    v.unit_type
FROM dbo.fact_insp_vehicle AS v
JOIN dbo.dim_carrier AS c
    ON v.dot = c.dot
WHERE
       v.vin LIKE '%' + @search + '%'
    OR v.license_plate LIKE '%' + @search + '%'
ORDER BY c.name;

-- Search part 4: insurer fields
-- Covers insurer search from insurance table.
SELECT DISTINCT TOP (100)
    c.dot,
    c.name,
    c.dba,
    i.insurer_name,
    i.status,
    i.effective_date,
    i.cancel_effective_date
FROM dbo.dim_insurance AS i
JOIN dbo.dim_carrier AS c
    ON i.dot = c.dot
WHERE i.insurer_name LIKE '%' + @search + '%'
ORDER BY c.name;
