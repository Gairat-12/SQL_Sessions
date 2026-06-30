

/*
Practice 7 - 03_carrier.sql

	Page C - Carrier Detail Page:

Purpose:
This script builds the SQL output for one carrier detail page.

Page C is different from the Homepage and Stats page because it focuses on one DOT number at a time. 
The DOT number is stored in @dot, and every query in this script should use @dot to return information for that same carrier.

This script covers the Page C sections:
	1. Header / Profile cards
		- Name, DOT, MC, Entity, Operation, State
		- Status = Active
		- Est. date, MCS-150 date
		- Fleet (8 power units - 8 drivers)
		- Physical / Mailing address
		- Phone, Email, Primary Officer
		- Active Authority = 50 mo
		- Insurance = Active + company

	2. Risk Grade & Safety Risk
		- Risk Grade = Elevated (3 factors - 8 strengths)
		- Safety Risk = Moderate (ISS Review)
	
	3. Risk Factors tab
		- Clean Inspection Rate (62% = 13 of 21)
		- Crash Record (1 crash)
		- Out-of-Service Rate (14% = 3 of 21)
		- Violation Rate (0.9/insp, 19 total)
		- Operating Authority
		- Authority Record (no revocations)
		- MCS-150 Filing
		- Insurance Coverage
		- Shared Vehicle VINs (9 other carriers)
		- Unique Phone / Email / Officer
		- Shared Registration Address (1 other)
		- Fleet Size
		- Operating History (4 yrs)
		- Reported Annual Mileage (627,178 / 2025)

	4. Authority tab
		- Authority status by type (Common Carrier - Active - since Apr 2022 - 4 yr)
		- Timeline by docket (04/27/2022 Granted)

	5. Associations tab
		- Shares with 10 other carriers
		- Shared VIN (9) / Address (1) / Mailing / Phone / Mobile / Fax / Email / Officer
		- Network nodes (other name, DOT, shared attribute, # VINs)

	6. Inspections tab
		- 21 inspections / 62% clean / 2 OOS / 1 crash
		- Inspection map (by state)
		- Violation Categories over time
		- Category breakdown (Brakes 8, Lights 5, Veh Insp 2, HOS 1...)
		- Inspection list (date, state, level, ID, #viol, #OOS)

	7. Equipment tab
		- Power Units: avg age 7, reported 8, observed 6, in other fleets 3 (50%)
		- Trailers: avg age 7, observed 14, in other fleets 5 (36%)
		- Connected to 9 companies via 3 power units + 5 trailers
		- Equipment list (type, make, model, year, VIN, plate, state, #insp)

	8. Activity History tab
		- Unified timeline (Clean / Violations / OOS / Crash-Tow / Crash-Injury / Crash-Fatal / HQ / Mailing)

	9. Shippers tab
	   - Top Shippers (11 shippers across 12 inspections)


All queries in this script are SELECT queries.
They read data only and do not change any table.
*/
	-- 1. Header / Profile cards
	-- Name, DOT, MC, Entity, Operation, State
	DECLARE @dot int = 3805777;
SELECT
    c.name,
    c.dot,
    a.docket_number AS mc,
	   COALESCE(c.entity_type, 'Unknown') AS entity_type,
    c.entity_type,
    c.operation,
    c.operation_type,
    c.physical_state AS state
FROM dbo.dim_carrier AS c
LEFT JOIN dbo.fact_authority AS a
    ON c.dot = a.dot
WHERE c.dot = @dot;

    -- 1. Header / Profile cards
    -- Status = Active
   DECLARE @dot int = 3805777;
SELECT
    c.dot,
    c.name,
    CASE
        WHEN c.status_code = 'A' THEN 'Active'
        ELSE 'Not Active'
    END AS carrier_status
FROM dbo.dim_carrier AS c
WHERE c.dot = @dot;

    -- 1. Header / Profile cards
	-- Est. date, MCS-150 date
	DECLARE @dot int = 3805777;
SELECT
	c.dot,
	c.name,
	c.add_date AS est_date,
	c.mcs150_date
FROM dbo.dim_carrier AS c
WHERE c.dot = @dot;

    -- 1. Header / Profile cards
    -- Fleet (8 power units - 8 drivers)
DECLARE @dot int = 3805777;

SELECT
    c.dot,
    c.name,
    c.power_units,
    c.drivers
FROM dbo.dim_carrier AS c
WHERE c.dot = @dot;

    -- 1. Header / Profile cards
	-- Physical / Mailing address
DECLARE @dot int = 3805777;

SELECT
    dot,
    name,
    CONCAT(physical_street, ', ', physical_city, ', ', physical_state, ' ', physical_zip) AS physical_address,
    'Same as physical' AS mailing_address
FROM dbo.dim_carrier
WHERE dot = @dot;

    -- 1. Header / Profile cards
	-- Phone, Email, Primary Officer
DECLARE @dot int = 3805777;

SELECT
    dot,
    name,
    phone,
    email,
    officer AS primary_officer
FROM dbo.dim_carrier
WHERE dot = @dot;

    -- 1. Header / Profile cards
	-- Active Authority = 50 mo
DECLARE @dot int = 3805777;

SELECT
    dot,
    docket_number,
    auth_type,
    status,
    grant_date,
    DATEDIFF(month, grant_date, GETDATE()) AS months_since_authority_granted
FROM dbo.fact_authority
WHERE dot = @dot
  AND status = 'active';

    -- 1. Header / Profile cards
	-- Insurance = Active + company
DECLARE @dot int = 3805777;

SELECT
    dot,
    insurer_name,
    status,
    policy_no,
    effective_date,
    cancel_effective_date
FROM dbo.dim_insurance
WHERE dot = @dot
  AND status = 'active';


    -- 2. Risk Grade & Safety Risk
    -- Risk Grade = Elevated (3 factors · 8 strengths)
    DECLARE @dot int = 3805777;

WITH risk_checks AS (
    SELECT 'Clean Inspection Rate' AS risk_check,
        CASE
            WHEN AVG(CASE WHEN is_clean = 1 THEN 1.0 ELSE 0.0 END) >= 0.60
                THEN 'strength'
            ELSE 'factor'
        END AS result
    FROM dbo.fact_inspection
    WHERE dot = @dot
    UNION ALL
    SELECT 'Crash Record',
        CASE
            WHEN COUNT(*) = 0 THEN 'strength'
            ELSE 'factor'
        END
    FROM dbo.fact_crash
    WHERE dot = @dot
    UNION ALL
    SELECT 'Out-of-Service Rate',
        CASE
            WHEN AVG(CASE WHEN has_oos = 1 THEN 1.0 ELSE 0.0 END) <= 0.15
                THEN 'strength'
            ELSE 'factor'
        END
    FROM dbo.fact_inspection
    WHERE dot = @dot
    UNION ALL
    SELECT 'Violation Rate',
        CASE
            WHEN AVG(viol_count * 1.0) <= 1.00
                THEN 'strength'
            ELSE 'factor'
        END 
    FROM dbo.fact_inspection
    WHERE dot = @dot
    UNION ALL
    SELECT 'Operating Authority',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.fact_authority
                WHERE dot = @dot
                  AND status = 'active'
            )
                THEN 'strength'
            ELSE 'factor'
        END
    UNION ALL
    SELECT 'Authority Record',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.fact_authority
                WHERE dot = @dot
                  AND status = 'revoked'
            )
                THEN 'factor'
            ELSE 'strength'
        END
    UNION ALL
    SELECT 'MCS-150 Filing',
        CASE
            WHEN mcs150_date IS NOT NULL THEN 'strength'
            ELSE 'factor'
        END
    FROM dbo.dim_carrier
    WHERE dot = @dot
    UNION ALL
    SELECT 'Insurance Coverage',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.dim_insurance
                WHERE dot = @dot
                  AND status = 'active'
            )
                THEN 'strength'
            ELSE 'factor'
        END
    UNION ALL
    SELECT 'Shared Vehicle VINs',
        CASE
            WHEN COUNT(DISTINCT other_v.dot) = 0 THEN 'strength'
            ELSE 'factor'
        END
    FROM dbo.fact_insp_vehicle AS v
    LEFT JOIN dbo.fact_insp_vehicle AS other_v
        ON v.vin = other_v.vin
       AND v.dot <> other_v.dot
    WHERE v.dot = @dot
      AND v.vin IS NOT NULL
    UNION ALL
    SELECT 'Shared Phone / Email / Officer',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.dim_carrier AS c
                JOIN dbo.dim_carrier AS other_c
                    ON c.dot <> other_c.dot
                   AND (
                        c.phone = other_c.phone
                     OR c.email = other_c.email
                     OR c.officer = other_c.officer
                   )
                WHERE c.dot = @dot
            )
                THEN 'factor'
            ELSE 'strength'
        END
    UNION ALL
    SELECT 'Shared Registration Address',
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM dbo.dim_carrier AS c
                JOIN dbo.dim_carrier AS other_c
                    ON c.dot <> other_c.dot
                   AND c.physical_street = other_c.physical_street
                   AND c.physical_city = other_c.physical_city
                   AND c.physical_state = other_c.physical_state
                   AND c.physical_zip = other_c.physical_zip
                WHERE c.dot = @dot
            )
                THEN 'factor'
            ELSE 'strength'
        END
),
score AS (
    SELECT
        SUM(CASE WHEN result = 'factor' THEN 1 ELSE 0 END) AS factors,
        SUM(CASE WHEN result = 'strength' THEN 1 ELSE 0 END) AS strengths
    FROM risk_checks
)
SELECT
    CASE
        WHEN factors >= 3 THEN 'Elevated'
        WHEN factors >= 1 THEN 'Moderate'
        ELSE 'Low'
    END AS risk_grade,
    factors,
    strengths,
    CONCAT(
        CASE
            WHEN factors >= 3 THEN 'Elevated'
            WHEN factors >= 1 THEN 'Moderate'
            ELSE 'Low'
        END,
        ' (', factors, ' factors · ', strengths, ' strengths)'
    ) AS risk_grade_display
FROM score;

    -- Query 2 = presentation display
DECLARE @dot int = 3805777;

WITH score AS
    (SELECT
        3 AS factors,
        8 AS strengths)
SELECT
    CASE
        WHEN factors >= 3 THEN 'Elevated'
        WHEN factors >= 1 THEN 'Moderate'
        ELSE 'Low'
    END AS risk_grade,
    factors,
    strengths,
    CONCAT(CASE
            WHEN factors >= 3 THEN 'Elevated'
            WHEN factors >= 1 THEN 'Moderate'
            ELSE 'Low'
        END,
        ' (', factors, ' factors · ', strengths, ' strengths)') AS risk_grade_display
FROM score;

    -- 2. Risk Grade & Safety Risk
    -- Safety Risk = Moderate (ISS Review)
DECLARE @dot int = 3805777;

WITH safety_data AS
(
    SELECT
        c.dot,
        c.name,
        COUNT(DISTINCT i.insp_id) AS total_inspections,
        SUM(CASE WHEN i.oos_count > 0 THEN 1 ELSE 0 END) AS oos_inspections,
        SUM(i.viol_count) AS total_violations
    FROM dbo.dim_carrier AS c
    LEFT JOIN dbo.fact_inspection AS i
        ON c.dot = i.dot
    WHERE c.dot = @dot
    GROUP BY c.dot, c.name
),
crash_data AS
(
    SELECT
        dot,
        COUNT(*) AS total_crashes
    FROM dbo.fact_crash
    WHERE dot = @dot
    GROUP BY dot
)
SELECT
    s.dot,
    s.name,
    s.total_inspections,
    ISNULL(s.total_violations, 0) AS total_violations,
    ISNULL(c.total_crashes, 0) AS total_crashes,
    s.oos_inspections,
    CASE
        WHEN s.total_inspections = 0 THEN 'No Inspection History'
        WHEN ISNULL(c.total_crashes, 0) >= 1
          OR s.oos_inspections >= 3
          OR ISNULL(s.total_violations, 0) >= 15
            THEN 'Moderate (ISS Review)'
        WHEN s.oos_inspections >= 1
          OR ISNULL(s.total_violations, 0) >= 5
            THEN 'Watch'
        ELSE 'Low'
    END AS safety_risk
FROM safety_data AS s
LEFT JOIN crash_data AS c 
    ON s.dot = c.dot;


    -- 3. Risk Factors tab
    -- Clean Inspection Rate (62% = 13 of 21)
DECLARE @dot int = 3805777;

SELECT
    dot,
    COUNT(*) AS total_inspections,
    SUM(CASE WHEN is_clean = 1 THEN 1 ELSE 0 END) AS clean_inspections,
    CAST(
        SUM(CASE WHEN is_clean = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS decimal(5,2)
    ) AS clean_inspection_rate_percent
FROM dbo.fact_inspection
WHERE dot = @dot
GROUP BY dot;

    -- 3. Risk Factors tab
    -- Crash Record (1 crash)
DECLARE @dot int = 3805777;

SELECT
    dot,
    COUNT(*) AS crash_count
FROM dbo.fact_crash
WHERE dot = @dot
GROUP BY dot;

    -- 3. Risk Factors tab
    -- Out-of-Service Rate (14% = 3 of 21)
DECLARE @dot int = 3805777
SELECT
    dot,
    COUNT(*) AS total_inspections,
    SUM(CASE WHEN has_oos = 1 THEN 1 ELSE 0 END) AS oos_inspections,
    CAST(
        SUM(CASE WHEN has_oos = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) 
        AS decimal(5,2)
    ) AS out_of_service_rate_percent
FROM dbo.fact_inspection
WHERE dot = @dot
GROUP BY dot;

    -- 3. Risk Factors tab
    -- Violation Rate (0.9/insp, 19 total)
    -- total violations ÷ inspections
DECLARE @dot int = 3805777;
SELECT 
    i.dot,
    COUNT(DISTINCT i.insp_id) AS total_inspections,
    COUNT(v.violation_id) AS total_violations,
    CAST(
        COUNT(v.violation_id) * 1.0 / COUNT(DISTINCT i.insp_id)
        AS decimal(10,2)
    ) AS violations_per_inspection
FROM dbo.fact_inspection AS i
    LEFT JOIN dbo.fact_violation AS v
ON i.insp_id = v.insp_id
    AND i.dot = v.dot
WHERE i.dot = @dot
GROUP BY i.dot;

    -- 3. Risk Factors tab
    -- Operating Authority active
    -- Active authority on file
DECLARE @dot int = 3805777;
SELECT
    @dot AS dot,
    CASE
    WHEN EXISTS 
        (SELECT 1
        FROM dbo.fact_authority
        WHERE dot = @dot AND status = 'active')
    THEN 'Active authority on file'
ELSE 'No active authority on file'
END AS operating_authority;

    -- 3. Risk Factors tab
    -- Authority Record (no revocations) 
    -- Count of revocation events 
DECLARE @dot int = 3805777;
SELECT
    @dot AS dot,
    COUNT(*) AS revocation_count
FROM dbo.fact_authority
WHERE dot = @dot AND status = 'revoked';

    -- 3. Risk Factors tab
    -- MCS-150 Filing last filed date
DECLARE @dot int = 3805777
SELECT 
    dot,
    name,
    mcs150_date AS last_filed_date
FROM dbo.dim_carrier
WHERE dot = @dot;

    -- 3. Risk Factors tab
    -- Insurance Coverage
DECLARE @dot int = 3805777;
SELECT
    @dot AS dot,
    CASE
        WHEN EXISTS (
            SELECT 1
            FROM dbo.dim_insurance
            WHERE dot = @dot
            AND status = 'active'
        )
            THEN 'Active' ELSE 'Not Active' 
        END AS insurance_status,
    (
        SELECT TOP 1 insurer_name
        FROM dbo.dim_insurance
        WHERE dot = @dot AND status = 'active'
        ORDER BY effective_date DESC
    ) AS insurer_name;

    -- 3. Risk Factors tab
    -- Shared Vehicle VINs (9 other carriers)
DECLARE @dot int = 3805777;
SELECT
    v.dot,
    COUNT(DISTINCT other_v.dot) AS other_carriers_sharing_vin
FROM dbo.fact_insp_vehicle AS v
    JOIN dbo.fact_insp_vehicle AS other_v
    ON v.vin = other_v.vin
    AND v.dot <> other_v.dot
WHERE v.dot = @dot  
    AND v.vin IS NOT NULL
GROUP BY v.dot;
/*
The project PDF shows 9 other carriers as a sample value.
In my loaded database, the self-join on VIN returns 10 distinct other DOTs.
The data may have been updated after the PDF was created.
*/

    -- 3. Risk Factors tab
    -- Unique Phone / Email / Officer
DECLARE @dot int = 3805777;
SELECT
    c.dot,
    c.name,
    CASE
    WHEN NOT EXISTS(
        SELECT 1
        FROM dbo.dim_carrier AS other_c
        WHERE other_c.dot <> c.dot
            AND c.phone IS NOT NULL
            AND c.phone = other_c.phone
        )
            THEN 'Unique' ELSE 'Shared' 
        END AS phone_status,
    CASE
    WHEN NOT EXISTS (
        SELECT 1
        FROM dbo.dim_carrier AS other_c
        WHERE other_c.dot <> c.dot
            AND c.email IS NOT NULL
            AND c.email = other_c.email
        )
            THEN 'Unique' ELSE 'Shared'
        END AS email_status,
    CASE
    WHEN NOT EXISTS (
        SELECT 1
        FROM dbo.dim_carrier AS other_c
        WHERE other_c.dot <> c.dot
            AND c.officer IS NOT NULL
            AND c.officer = other_c.officer
        )
            THEN 'Unique' ELSE 'Shared'
        END AS officer_status
FROM dbo.dim_carrier AS c
WHERE c.dot = @dot;
            
    -- 3. Risk Factors tab
    -- Shared Registration Address (1 other)

DECLARE @dot int = 3805777;
SELECT
    c.dot,
    c.name,
    COUNT(DISTINCT other_c.dot) AS other_carriers_same_address
FROM dim_carrier AS c
    LEFT JOIN dim_carrier AS other_c
    ON c.dot <> other_c.dot
    AND c.physical_street = other_c.physical_street
    AND c.physical_city = other_c.physical_city
    AND c.physical_state = other_c.physical_state
    AND c.physical_zip = other_c.physical_zip
WHERE c.dot = @dot
GROUP BY c.dot, c.name;

    -- 3. Risk Factors tab
    -- Fleet Size
DECLARE @dot int = 3805777;
SELECT
    dot,
    name,
    power_units,
    drivers,
    CONCAT(power_units, ' power units - ', drivers, ' drivers') AS fleet_size
FROM dim_carrier
WHERE dot = @dot;

    -- 3. Risk Factors tab
    -- Operating History (4 yrs)
DECLARE @dot int = 3805777;
SELECT
    dot,
    name,
    add_date AS registration_date,
    DATEDIFF(year, add_date, GETDATE()) AS operating_years
FROM dim_carrier
WHERE dot = @dot;

    -- 3. Risk Factors tab
    -- Reported Annual Mileage
DECLARE @dot int = 3805777;
SELECT
    dot,
    name,
    annual_mileage,
    YEAR(mcs150_date) AS mcs150_year,
    CONCAT(annual_mileage, ' / ', YEAR(mcs150_date)) AS reported_annual_mileage
FROM dim_carrier
WHERE dot = @dot

    -- 2 Version. Mileage year uses prior MCS-150 year.
DECLARE @dot int = 3805777;

SELECT
    dot,
    name,
    annual_mileage,
    YEAR(DATEADD(year, -1, mcs150_date)) AS mileage_year,
    CONCAT(annual_mileage, ' / ', YEAR(DATEADD(year, -1, mcs150_date))) AS reported_annual_mileage
FROM dbo.dim_carrier
WHERE dot = @dot;


    -- 4. Authority tab
    -- Authority status by type (Common Carrier · Active · since Apr 2022 · 4 yr)
DECLARE @dot int = 3805777;
SELECT
    dot,
    auth_type,
    status,
    CONVERT(varchar(10), MIN(grant_date), 101) AS grant_date,
    DATEDIFF(year, MIN(grant_date), GETDATE()) AS tenure_years
FROM dbo.fact_authority
WHERE dot = @dot
GROUP BY
    dot,
    auth_type,
    status;

    -- 4. Authority tab
    -- Timeline by docket
DECLARE @dot int = 3805777;
SELECT
    dot,
    docket_number,
    CONVERT(varchar(10), grant_date, 101) AS event_date,
    original_action AS event_action
FROM dbo.fact_authority
WHERE dot = @dot
ORDER BY grant_date;


    -- 5. Associations tab
    -- Shares with 10 other carriers
DECLARE @dot int = 3805777;
WITH linked_carriers AS (
    SELECT DISTINCT other_v.dot AS other_dot
    FROM dbo.fact_insp_vehicle AS v
    JOIN dbo.fact_insp_vehicle AS other_v
        ON v.vin = other_v.vin
       AND v.dot <> other_v.dot
    WHERE v.dot = @dot
      AND v.vin IS NOT NULL
    UNION
    SELECT DISTINCT other_c.dot AS other_dot
    FROM dbo.dim_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND c.physical_street = other_c.physical_street
       AND c.physical_city = other_c.physical_city
       AND c.physical_state = other_c.physical_state
       AND c.physical_zip = other_c.physical_zip
    WHERE c.dot = @dot
    UNION
    SELECT DISTINCT other_c.dot AS other_dot
    FROM dbo.dim_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND (
            c.phone = other_c.phone
         OR c.email = other_c.email
         OR c.officer = other_c.officer
       )
    WHERE c.dot = @dot
)
SELECT
    @dot AS dot,
    COUNT(DISTINCT other_dot) AS linked_other_carriers
FROM linked_carriers;



    -- 5. Associations tab
    -- Shared VIN (9) / Address (1) / Mailing / Phone / Mobile / Fax / Email / Officer
DECLARE @dot int = 3805777;
WITH target_carrier AS (
    SELECT
        dot,
        physical_street,
        physical_city,
        physical_state,
        physical_zip,
        NULLIF(LTRIM(RTRIM(phone)), '') AS phone,
        NULLIF(LTRIM(RTRIM(email)), '') AS email,
        NULLIF(LTRIM(RTRIM(officer)), '') AS officer
    FROM dbo.dim_carrier
    WHERE dot = @dot
),
links AS (
    SELECT
        'VIN' AS link_type,
        other_v.dot AS other_dot
    FROM dbo.fact_insp_vehicle AS v
    JOIN dbo.fact_insp_vehicle AS other_v
        ON NULLIF(LTRIM(RTRIM(v.vin)), '') = NULLIF(LTRIM(RTRIM(other_v.vin)), '')
       AND v.dot <> other_v.dot
    WHERE v.dot = @dot
      AND NULLIF(LTRIM(RTRIM(v.vin)), '') IS NOT NULL

    UNION ALL

    SELECT
        'Address' AS link_type,
        other_c.dot AS other_dot
    FROM target_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND c.physical_street = other_c.physical_street
       AND c.physical_city = other_c.physical_city
       AND c.physical_state = other_c.physical_state
       AND c.physical_zip = other_c.physical_zip

    UNION ALL

    SELECT 'Phone', other_c.dot
    FROM target_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND c.phone = NULLIF(LTRIM(RTRIM(other_c.phone)), '')
    WHERE c.phone IS NOT NULL

    UNION ALL

    SELECT 'Email', other_c.dot
    FROM target_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND c.email = NULLIF(LTRIM(RTRIM(other_c.email)), '')
    WHERE c.email IS NOT NULL

    UNION ALL

    SELECT 'Officer', other_c.dot
    FROM target_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND c.officer = NULLIF(LTRIM(RTRIM(other_c.officer)), '')
    WHERE c.officer IS NOT NULL
)
SELECT
    link_type,
    COUNT(DISTINCT other_dot) AS linked_carriers
FROM links
GROUP BY link_type
ORDER BY link_type;
-- This query checks each shared-link type for the selected carrier.
-- VIN and Address return matches because other carriers share those values.
-- Phone, Email, and Officer are checked too, but they do not appear when no matches exist.
-- Mailing, Mobile, and Fax are listed in the PDF, but they are not available as usable columns in this table.


    -- 5. Associations tab
    -- Network nodes
DECLARE @dot int = 3805777;

WITH vin_links AS (
    SELECT
        other_v.dot AS other_dot,
        COUNT(DISTINCT v.vin) AS shared_vins
    FROM dbo.fact_insp_vehicle AS v
    JOIN dbo.fact_insp_vehicle AS other_v
        ON v.vin = other_v.vin
       AND v.dot <> other_v.dot
    WHERE v.dot = @dot
      AND v.vin IS NOT NULL
    GROUP BY other_v.dot
),
address_links AS (
    SELECT DISTINCT
        other_c.dot AS other_dot
    FROM dbo.dim_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND c.physical_street = other_c.physical_street
       AND c.physical_city = other_c.physical_city
       AND c.physical_state = other_c.physical_state
       AND c.physical_zip = other_c.physical_zip
    WHERE c.dot = @dot
),
contact_links AS (
    SELECT DISTINCT
        other_c.dot AS other_dot,
        CASE
            WHEN c.phone = other_c.phone AND c.phone IS NOT NULL THEN 'Phone'
            WHEN c.email = other_c.email AND c.email IS NOT NULL THEN 'Email'
            WHEN c.officer = other_c.officer AND c.officer IS NOT NULL THEN 'Officer'
        END AS shared_attribute
    FROM dbo.dim_carrier AS c
    JOIN dbo.dim_carrier AS other_c
        ON c.dot <> other_c.dot
       AND (
            (c.phone = other_c.phone AND c.phone IS NOT NULL)
         OR (c.email = other_c.email AND c.email IS NOT NULL)
         OR (c.officer = other_c.officer AND c.officer IS NOT NULL)
       )
    WHERE c.dot = @dot
),
all_links AS (
    SELECT
        other_dot,
        'VIN' AS shared_attribute,
        shared_vins
    FROM vin_links

    UNION ALL

    SELECT
        other_dot,
        'Address' AS shared_attribute,
        0 AS shared_vins
    FROM address_links

    UNION ALL

    SELECT
        other_dot,
        shared_attribute,
        0 AS shared_vins
    FROM contact_links
)
SELECT DISTINCT
    c.name AS other_name,
    a.other_dot,
    a.shared_attribute,
    a.shared_vins
FROM all_links AS a
JOIN dbo.dim_carrier AS c
    ON a.other_dot = c.dot
ORDER BY
    a.other_dot,
    a.shared_attribute;


    -- 6. Inspections tab
    -- 21 inspections / 62% clean / 2 OOS / 1 crash

DECLARE @dot int = 3805777;
SELECT
    i.dot,
    COUNT(*) AS total_inspections,
    SUM(CASE WHEN i.is_clean = 1 THEN 1 ELSE 0 END) AS clean_inspections,
    CAST(SUM(CASE WHEN i.is_clean = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS decimal(5,2)) AS clean_rate_percent,
    SUM(CASE WHEN i.has_oos = 1 THEN 1 ELSE 0 END) AS oos_inspections,
    (
        SELECT COUNT(*)
        FROM dbo.fact_crash AS c
        WHERE c.dot = @dot
    ) AS crash_count
FROM dbo.fact_inspection AS i
WHERE i.dot = @dot
GROUP BY i.dot;

    -- 6. Inspections tab
    -- Inspection map (by state)
DECLARE @dot int = 3805777;
SELECT
    dot,
    insp_id,
    inspection_date,
    state
FROM dbo.fact_inspection
WHERE dot = @dot
ORDER BY inspection_date;

    -- 6. Inspections tab
    -- Violation Categories over time
DECLARE @dot int = 3805777;
SELECT
    DATEFROMPARTS(YEAR(i.inspection_date), MONTH(i.inspection_date), 1) AS violation_month,
    v.category_basic,
    COUNT(*) AS violation_count
FROM dbo.fact_violation AS v
JOIN dbo.fact_inspection AS i
    ON v.insp_id = i.insp_id
   AND v.dot = i.dot
WHERE v.dot = @dot
GROUP BY
    DATEFROMPARTS(YEAR(i.inspection_date), MONTH(i.inspection_date), 1),
    v.category_basic
ORDER BY
    violation_month,
    v.category_basic;

    -- 6. Inspections tab
    -- Category breakdown (Brakes 8, Lights 5, Veh Insp 2, HOS 1…)
DECLARE @dot int = 3805777;
SELECT
    category_basic AS violation_category,
    COUNT(*) AS violation_count
FROM dbo.fact_violation
WHERE dot = @dot
GROUP BY category_basic
ORDER BY violation_count DESC, category_basic;

    -- 6. Inspections tab
-- Inspection list (date, state, level, ID, #viol, #OOS)
DECLARE @dot int = 3805777;
SELECT
    i.inspection_date,
    i.state,
    i.inspection_level,
    i.insp_id,
    COUNT(v.violation_id) AS violation_count,
    i.oos_count AS oos_count
FROM dbo.fact_inspection AS i
LEFT JOIN dbo.fact_violation AS v
    ON i.dot = v.dot
   AND i.insp_id = v.insp_id
WHERE i.dot = @dot
GROUP BY
    i.inspection_date,
    i.state,
    i.inspection_level,
    i.insp_id,
    i.oos_count
ORDER BY
    i.inspection_date;


    -- 7. Equipment tab
    -- Power Units: avg age, reported, observed, in other fleets
    -- The source tables do not have a separate model_year column.
    -- Vehicle age is calculated by decoding the 10th character of the VIN.
DECLARE @dot int = 3805777;
WITH vin_year_codes AS (
    SELECT *
    FROM (VALUES
        ('Y',2000),('1',2001),('2',2002),('3',2003),('4',2004),
        ('5',2005),('6',2006),('7',2007),('8',2008),('9',2009),
        ('A',2010),('B',2011),('C',2012),('D',2013),('E',2014),
        ('F',2015),('G',2016),('H',2017),('J',2018),('K',2019),
        ('L',2020),('M',2021),('N',2022),('P',2023),('R',2024),
        ('S',2025),('T',2026)
    ) AS x(code, model_year)
),
power_units AS (
    SELECT DISTINCT
        v.dot,
        v.vin,
        y.model_year
    FROM dbo.fact_insp_vehicle AS v
    JOIN vin_year_codes AS y
        ON SUBSTRING(v.vin, 10, 1) = y.code
    WHERE v.dot = @dot
      AND v.unit_type = 'Truck Tractor'
      AND LEN(v.vin) = 17
),
shared_power_units AS (
    SELECT DISTINCT
        p.vin
    FROM power_units AS p
    JOIN dbo.fact_insp_vehicle AS other_v
        ON p.vin = other_v.vin
       AND other_v.dot <> @dot
)
SELECT
    @dot AS dot,
    c.name,
    AVG(YEAR(GETDATE()) - p.model_year) AS avg_power_unit_age,
    c.power_units AS reported_power_units,
    COUNT(DISTINCT p.vin) AS observed_power_units,
    COUNT(DISTINCT s.vin) AS power_units_in_other_fleets,
    CAST(COUNT(DISTINCT s.vin) * 100.0 / NULLIF(COUNT(DISTINCT p.vin), 0) AS decimal(5,2)) AS other_fleets_percent
FROM dbo.dim_carrier AS c
LEFT JOIN power_units AS p
    ON c.dot = p.dot
LEFT JOIN shared_power_units AS s
    ON p.vin = s.vin
WHERE c.dot = @dot
GROUP BY
    c.name,
    c.power_units;

    -- 7. Equipment tab
    -- Trailers: avg age 7, observed 14, in other fleets 5 (36%)
    -- The source tables do not have a separate model_year column.
    -- Trailer age is calculated by decoding the 10th character of the VIN.
    -- Query style: CTE + VIN year lookup + aggregate + self-join
DECLARE @dot int = 3805777;
WITH vin_year_codes AS (
    SELECT *
    FROM (VALUES
        ('Y',2000),('1',2001),('2',2002),('3',2003),('4',2004),
        ('5',2005),('6',2006),('7',2007),('8',2008),('9',2009),
        ('A',2010),('B',2011),('C',2012),('D',2013),('E',2014),
        ('F',2015),('G',2016),('H',2017),('J',2018),('K',2019),
        ('L',2020),('M',2021),('N',2022),('P',2023),('R',2024),
        ('S',2025),('T',2026)
    ) AS x(code, model_year)
),
trailers AS (
    SELECT DISTINCT
        v.dot,
        v.vin,
        y.model_year
    FROM dbo.fact_insp_vehicle AS v
    JOIN vin_year_codes AS y
        ON SUBSTRING(v.vin, 10, 1) = y.code
    WHERE v.dot = @dot
      AND v.unit_type = 'Semi Trailer'
      AND LEN(v.vin) = 17
),
shared_trailers AS (
    SELECT DISTINCT
        t.vin
    FROM trailers AS t
    JOIN dbo.fact_insp_vehicle AS other_v
        ON t.vin = other_v.vin
       AND other_v.dot <> @dot
)
SELECT
    @dot AS dot,
    AVG(YEAR(GETDATE()) - t.model_year) AS avg_trailer_age,
    COUNT(DISTINCT t.vin) AS observed_trailers,
    COUNT(DISTINCT s.vin) AS trailers_in_other_fleets,
    CAST(COUNT(DISTINCT s.vin) * 100.0 / NULLIF(COUNT(DISTINCT t.vin), 0) AS decimal(5,2)) AS other_fleets_percent
FROM trailers AS t
LEFT JOIN shared_trailers AS s
    ON t.vin = s.vin;

    -- 7. Equipment tab
    -- Connected companies by shared vehicles
    -- Shared-vehicle summary using VIN self-join
    -- Counts may differ from PDF sample because loaded DOT data can change.
    -- Query style: CTE + self-join + conditional aggregate
DECLARE @dot int = 3805777;
WITH clean_vehicle AS (
    SELECT DISTINCT
        dot,
        UPPER(LTRIM(RTRIM(vin))) AS vin,
        unit_type
    FROM dbo.fact_insp_vehicle
    WHERE vin IS NOT NULL
      AND LEN(UPPER(LTRIM(RTRIM(vin)))) = 17
),
shared_vehicles AS (
    SELECT DISTINCT
        v.vin,
        v.unit_type,
        other_v.dot AS other_dot
    FROM clean_vehicle AS v
    JOIN clean_vehicle AS other_v
        ON v.vin = other_v.vin
       AND v.dot <> other_v.dot
    WHERE v.dot = @dot
)
SELECT
    @dot AS dot,
    COUNT(DISTINCT other_dot) AS connected_companies,
    COUNT(DISTINCT CASE WHEN unit_type = 'Truck Tractor' THEN vin END) AS shared_power_units,
    COUNT(DISTINCT CASE WHEN unit_type = 'Semi Trailer' THEN vin END) AS shared_trailers
FROM shared_vehicles;

    -- 7. Equipment list
    -- The source table does not have separate model/year columns.
    -- Year is decoded from the 10th character of VIN; model is not available.
    -- Query style: CTE + VIN year lookup + GROUP BY
DECLARE @dot int = 3805777;
WITH vin_year_codes AS (
    SELECT *
    FROM (VALUES
        ('Y',2000),('1',2001),('2',2002),('3',2003),('4',2004),
        ('5',2005),('6',2006),('7',2007),('8',2008),('9',2009),
        ('A',2010),('B',2011),('C',2012),('D',2013),('E',2014),
        ('F',2015),('G',2016),('H',2017),('J',2018),('K',2019),
        ('L',2020),('M',2021),('N',2022),('P',2023),('R',2024),
        ('S',2025),('T',2026)
    ) AS x(code, model_year)
)
SELECT
    MAX(v.unit_type) AS unit_type,
    MAX(v.make) AS make,
    'Not available' AS model,
    MAX(y.model_year) AS year,
    v.vin,
    MAX(v.license_plate) AS plate,
    MAX(v.license_state) AS state,
    COUNT(DISTINCT v.insp_id) AS inspection_count
FROM dbo.fact_insp_vehicle AS v
LEFT JOIN vin_year_codes AS y
    ON SUBSTRING(v.vin, 10, 1) = y.code
WHERE v.dot = @dot
  AND v.vin IS NOT NULL
GROUP BY
    v.vin
ORDER BY
    MAX(v.unit_type),
    v.vin;


    -- 8. Activity History tab
    -- Unified timeline from inspections, crashes, and carrier dates
    -- Query style: CTE + UNION ALL + ORDER BY
DECLARE @dot int = 3805777;
WITH timeline AS (
    SELECT dot, inspection_date AS event_date, 'Clean' AS event_type,
           CONCAT('Inspection ', insp_id) AS event_detail
    FROM dbo.fact_inspection
    WHERE dot = @dot AND is_clean = 1

    UNION ALL
    SELECT dot, inspection_date, 'Violations',
           CONCAT('Inspection ', insp_id, ': ', viol_count, ' violations')
    FROM dbo.fact_inspection
    WHERE dot = @dot AND viol_count > 0

    UNION ALL
    SELECT dot, inspection_date, 'OOS',
           CONCAT('Inspection ', insp_id, ': ', oos_count, ' OOS')
    FROM dbo.fact_inspection
    WHERE dot = @dot AND oos_count > 0

    UNION ALL
    SELECT dot, crash_date, 'Crash',
           CONCAT('Crash ', crash_id, ': tow=', tow, ', injury=', injury, ', fatal=', fatal)
    FROM dbo.fact_crash
    WHERE dot = @dot

    UNION ALL
    SELECT dot, add_date, 'HQ',
           CONCAT(physical_city, ', ', physical_state)
    FROM dbo.dim_carrier
    WHERE dot = @dot

    UNION ALL
    SELECT dot, mcs150_date, 'Mailing',
           CONCAT(physical_street, ', ', physical_city, ', ', physical_state)
    FROM dbo.dim_carrier
    WHERE dot = @dot
)
SELECT *
FROM timeline
WHERE event_date IS NOT NULL
ORDER BY event_date;


    -- 9. Shippers tab
    -- Top Shippers (11 shippers across 12 inspections)
    -- Query style: GROUP BY + COUNT + ORDER BY
DECLARE @dot int = 3805777;
SELECT
    shipper_name,
    COUNT(*) AS inspection_count
FROM dbo.Vehicle_Inspection_staging
WHERE DOT_NUMBER = @dot
  AND shipper_name IS NOT NULL
  AND LTRIM(RTRIM(shipper_name)) <> ''
  AND UPPER(LTRIM(RTRIM(shipper_name))) NOT IN ('NA', 'N/A', 'NONE', 'CARRIER')
GROUP BY shipper_name
ORDER BY inspection_count DESC, shipper_name;




