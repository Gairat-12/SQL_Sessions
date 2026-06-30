/*
Practice 7 - 02_stats.sql

    Page B - Stats: industry statistics

The stats page has these main outputs:
    1. active carriers
    2. crashes in the last 8 weeks
    3. entity types
    4. operation types
    5. new carrier registrations by quarter
    6. fleet size distribution
    7. popular truck makes
    8. popular trailer makes
    9. cargo types
    10. crashes by state
    11. top violation categories last 12 m
    12. hazmat carriers by state
    13. top insurance providers

The stats page uses these clean tables:
    - dim_carrier
    - fact_authority
    - fact_crash
    - fact_insp_vehicle
    - fact_inspection
    - fact_violation
    - dim_insurance
*/

USE usaTrucking;
GO

-- 2.2M Active Carriers
-- Counts carriers marked active in the Company Census file.
SELECT
    'Active Carriers' AS stats_metric,
    COUNT(*) AS active_carrier_count
FROM dbo.dim_carrier
WHERE status_code = 'A';

-- 14.8K Crashes (8 weeks)
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
    'Crashes - last 8 weeks' AS stats_metric,
    COUNT(*) AS crash_count,
    DATEADD(day, -56, a.asof) AS start_date,
    a.asof AS end_date
FROM dbo.fact_crash AS c
CROSS JOIN asof_date AS a
WHERE c.crash_date >= DATEADD(day, -56, a.asof)
  AND c.crash_date <= a.asof
GROUP BY a.asof;

-- Entity Types
-- Counts carriers by entity type.
SELECT
    entity_type,
    COUNT(*) AS carrier_count
FROM dbo.dim_carrier
WHERE entity_type IS NOT NULL
GROUP BY entity_type
ORDER BY carrier_count DESC;

-- Operation Types
-- Counts carriers by operation classification.
SELECT
    operation,
    COUNT(*) AS carrier_count
FROM dbo.dim_carrier
WHERE operation IS NOT NULL
GROUP BY operation
ORDER BY carrier_count DESC;

    -- With FMCSA codes:
SELECT
    CASE
        WHEN operation = 'A' THEN 'Interstate'
        WHEN operation = 'B' THEN 'Intrastate Hazmat'
        WHEN operation = 'C' THEN 'Intrastate Non-Hazmat'
        ELSE 'Unknown'
    END AS operation_type,
    COUNT(*) AS carrier_count
FROM dbo.dim_carrier
WHERE operation IS NOT NULL
GROUP BY
    CASE
        WHEN operation = 'A' THEN 'Interstate'
        WHEN operation = 'B' THEN 'Intrastate Hazmat'
        WHEN operation = 'C' THEN 'Intrastate Non-Hazmat'
        ELSE 'Unknown'
    END
ORDER BY carrier_count DESC;


-- New Carrier Registrations - quarterly, last 5 years
-- Counts new carriers by year and quarter.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash
    ) AS all_dates
)
SELECT
    YEAR(c.add_date) AS registration_year,
    DATEPART(quarter, c.add_date) AS registration_quarter,
    COUNT(*) AS new_carrier_count
FROM dbo.dim_carrier AS c
CROSS JOIN asof_date AS a
WHERE c.add_date IS NOT NULL
  AND c.add_date >= DATEADD(year, -5, a.asof)
  AND c.add_date <= a.asof
GROUP BY
    YEAR(c.add_date),
    DATEPART(quarter, c.add_date)
ORDER BY
    registration_year,
    registration_quarter;

-- Fleet Size Distribution
-- Buckets carriers by power units.
WITH fleet_buckets AS (
    SELECT
        dot,
        power_units,
        CASE
            WHEN power_units IS NULL THEN 'Unknown'
            WHEN power_units = 0 THEN 'No Power Units'
            WHEN power_units = 1 THEN 'Solo'
            WHEN power_units BETWEEN 2 AND 10 THEN 'Small'
            WHEN power_units BETWEEN 11 AND 100 THEN 'Mid'
            ELSE 'Large'
        END AS fleet_size_bucket
    FROM dbo.dim_carrier
)
SELECT
    fleet_size_bucket,
    COUNT(*) AS carrier_count
FROM fleet_buckets
GROUP BY fleet_size_bucket
ORDER BY carrier_count DESC;

-- Popular Truck Makes
-- Counts observed truck units by make.
SELECT TOP (10)
    make,
    COUNT(*) AS truck_count
FROM dbo.fact_insp_vehicle
WHERE make IS NOT NULL
  AND unit_type IN ('Straight Truck', 'Truck Tractor', 'Van')
GROUP BY make
ORDER BY truck_count DESC;

-- Popular Trailer Makes
-- Counts observed trailer units by make.
SELECT TOP (10)
    make,
    COUNT(*) AS trailer_count
FROM dbo.fact_insp_vehicle
WHERE make IS NOT NULL
  AND unit_type IN ('Full Trailer', 'Semi Trailer', 'Pole Trailer', 'Intermodal Chassis', 'Crib Log Trailer')
GROUP BY make
ORDER BY trailer_count DESC;

-- Cargo Types
-- Counts active carriers by cargo flag.
WITH cargo_types AS (
    SELECT dot, 'General Freight' AS cargo_type FROM dbo.dim_carrier WHERE crgo_genfreight IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Household Goods' FROM dbo.dim_carrier WHERE crgo_household IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Metal Sheets' FROM dbo.dim_carrier WHERE crgo_metalsheet IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Motor Vehicles' FROM dbo.dim_carrier WHERE crgo_motoveh IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Drive/Tow Away' FROM dbo.dim_carrier WHERE crgo_drivetow IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Logs/Poles' FROM dbo.dim_carrier WHERE crgo_logpole IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Building Materials' FROM dbo.dim_carrier WHERE crgo_bldgmat IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Mobile Homes' FROM dbo.dim_carrier WHERE crgo_mobilehome IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Machinery' FROM dbo.dim_carrier WHERE crgo_machlrg IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Produce' FROM dbo.dim_carrier WHERE crgo_produce IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Liquids/Gases' FROM dbo.dim_carrier WHERE crgo_liqgas IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Intermodal Containers' FROM dbo.dim_carrier WHERE crgo_intermodal IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Passengers' FROM dbo.dim_carrier WHERE crgo_passengers IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Oilfield Equipment' FROM dbo.dim_carrier WHERE crgo_oilfield IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Livestock' FROM dbo.dim_carrier WHERE crgo_livestock IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Grain/Feed/Hay' FROM dbo.dim_carrier WHERE crgo_grainfeed IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Coal/Coke' FROM dbo.dim_carrier WHERE crgo_coalcoke IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Meat' FROM dbo.dim_carrier WHERE crgo_meat IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Garbage/Refuse' FROM dbo.dim_carrier WHERE crgo_garbage IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'US Mail' FROM dbo.dim_carrier WHERE crgo_usmail IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Chemicals' FROM dbo.dim_carrier WHERE crgo_chem IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Dry Bulk' FROM dbo.dim_carrier WHERE crgo_drybulk IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Cold Food' FROM dbo.dim_carrier WHERE crgo_coldfood IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Beverages' FROM dbo.dim_carrier WHERE crgo_beverages IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Paper Products' FROM dbo.dim_carrier WHERE crgo_paperprod IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Utility' FROM dbo.dim_carrier WHERE crgo_utility IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Farm Supplies' FROM dbo.dim_carrier WHERE crgo_farmsupp IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Construction' FROM dbo.dim_carrier WHERE crgo_construct IS NOT NULL AND status_code = 'A'
    UNION ALL SELECT dot, 'Water Well' FROM dbo.dim_carrier WHERE crgo_waterwell IS NOT NULL AND status_code = 'A'
)
SELECT
    cargo_type,
    COUNT(DISTINCT dot) AS carrier_count
FROM cargo_types
GROUP BY cargo_type
ORDER BY carrier_count DESC;

-- Crashes by State - last 8 weeks
-- Counts fatal, injury, and tow crashes by state.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash
    ) AS all_dates
)
SELECT
    c.state,
    SUM(CASE WHEN c.fatal > 0 THEN 1 ELSE 0 END) AS fatal_crashes,
    SUM(CASE WHEN c.injury > 0 THEN 1 ELSE 0 END) AS injury_crashes,
    SUM(CASE WHEN c.tow = 1 THEN 1 ELSE 0 END) AS tow_crashes,
    COUNT(*) AS total_crashes
FROM dbo.fact_crash AS c
CROSS JOIN asof_date AS a
WHERE c.crash_date >= DATEADD(day, -56, a.asof)
  AND c.crash_date <= a.asof
GROUP BY c.state
ORDER BY total_crashes DESC;

-- Top Violation Categories - last 12 months
-- Counts violations by category in the last 12 months.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash
    ) AS all_dates
)
SELECT TOP (20)
    CONCAT('Category ', v.category_basic) AS violation_category,
    COUNT(*) AS violation_count
FROM dbo.fact_violation AS v
JOIN dbo.fact_inspection AS i
    ON v.insp_id = i.insp_id
CROSS JOIN asof_date AS a
WHERE i.inspection_date >= DATEADD(month, -12, a.asof)
  AND i.inspection_date <= a.asof
GROUP BY v.category_basic
ORDER BY violation_count DESC;

-- Version 2: Mapped Category Names
-- Uses CASE to label known category IDs.
WITH asof_date AS (
    SELECT MAX(source_date) AS asof
    FROM (
        SELECT MAX(inspection_date) AS source_date FROM dbo.fact_inspection
        UNION ALL
        SELECT MAX(crash_date) FROM dbo.fact_crash
    ) AS all_dates
),
violation_names AS (
    SELECT
        v.insp_id,
        CASE v.category_basic
            WHEN 20 THEN 'Brakes'
            WHEN 16 THEN 'Lights'
            WHEN 51 THEN 'Vehicle Inspection'
            WHEN 12 THEN 'Hours of Service'
            WHEN 23 THEN 'Driver Qualification'
            WHEN 30 THEN 'Unsafe Driving'
            WHEN 7 THEN 'Cargo Securement'
            WHEN 47 THEN 'Tires'
        END AS violation_category
    FROM dbo.fact_violation AS v
    WHERE v.category_basic IN (20, 16, 51, 12, 23, 30, 7, 47)
)
SELECT
    v.violation_category,
    COUNT(*) AS violation_count
FROM violation_names AS v
JOIN dbo.fact_inspection AS i
    ON v.insp_id = i.insp_id
CROSS JOIN asof_date AS a
WHERE i.inspection_date >= DATEADD(month, -12, a.asof)
  AND i.inspection_date <= a.asof
GROUP BY v.violation_category
ORDER BY violation_count DESC;



-- Hazmat Carriers by State
-- Counts hazmat carriers by physical state.
SELECT
    physical_state,
    COUNT(*) AS hazmat_carrier_count
FROM dbo.dim_carrier
WHERE hm_flag = 'Y'
    AND status_code = 'A'
GROUP BY physical_state
ORDER BY hazmat_carrier_count DESC;

-- Top Insurance Providers
-- Counts active policies by insurer.
SELECT TOP (20)
    insurer_name,
    COUNT(*) AS active_policy_count
FROM dbo.dim_insurance
WHERE status = 'active'
  AND insurer_name IS NOT NULL
GROUP BY insurer_name
ORDER BY active_policy_count DESC;
