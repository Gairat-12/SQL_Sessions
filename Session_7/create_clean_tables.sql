
/*
Practice 7 - 00_create_clean_tables.sql

Purpose:
Create the clean dim_* and fact_* tables required by the PDF.

Source:
The seven staging tables already loaded in database usaTrucking.

This script creates these 7 clean project tables:
1. dbo.dim_carrier
2. dbo.fact_inspection
3. dbo.fact_violation
4. dbo.fact_crash
5. dbo.fact_insp_vehicle
6. dbo.dim_insurance
7. dbo.fact_authority

Important:
This script does not change the staging tables.
It drops/recreates only the clean project tables listed above.

    1. dim_carrier table
This clean table has 1 row per DOT carrier.
It comes from Company_Census_staging and keeps carrier name, DBA,
entity type, operation, address, contact info, power units, drivers,
MCS-150 dates, hazmat flag, cargo flags, and annual mileage. */

USE usaTrucking;
GO
    /* Checking Company_Census_staging:
    Confirms the table has 1 row per DOT carrier by comparing total rows
    to distinct DOT_NUMBER values and checking for blank DOT numbers. */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT DOT_NUMBER) AS distinct_dot_numbers,
    SUM(CASE WHEN DOT_NUMBER IS NULL OR TRIM(DOT_NUMBER) = '' THEN 1 ELSE 0 END) AS blank_dot_numbers
FROM dbo.Company_Census_staging;

    -- Creating
DROP TABLE IF EXISTS dbo.dim_carrier;
GO

SELECT
    TRY_CONVERT(int, DOT_NUMBER) AS dot,
    NULLIF(TRIM(LEGAL_NAME), '') AS name,
    NULLIF(TRIM(DBA_NAME), '') AS dba,
    NULLIF(TRIM(BUSINESS_ORG_DESC), '') AS entity_type,
    NULLIF(TRIM(CARRIER_OPERATION), '') AS operation,
    NULLIF(TRIM(PHY_STREET), '') AS physical_street,
    NULLIF(TRIM(PHY_CITY), '') AS physical_city,
    NULLIF(TRIM(PHY_STATE), '') AS physical_state,
    NULLIF(TRIM(PHY_ZIP), '') AS physical_zip,
    NULLIF(TRIM(PHONE), '') AS phone,
    NULLIF(TRIM(EMAIL_ADDRESS), '') AS email,
    NULLIF(TRIM(COMPANY_OFFICER_1), '') AS officer,
    TRY_CONVERT(int, POWER_UNITS) AS power_units,
    TRY_CONVERT(int, TOTAL_DRIVERS) AS drivers,
    TRY_CONVERT(date, LEFT(NULLIF(TRIM(MCS150_DATE), ''), 8), 112) AS mcs150_date,
    TRY_CONVERT(date, NULLIF(TRIM(ADD_DATE), ''), 112) AS add_date,
    NULLIF(TRIM(STATUS_CODE), '') AS status_code,

    NULLIF(TRIM(HM_Ind), '') AS hm_flag,
    TRY_CONVERT(bigint, MCS150_MILEAGE) AS annual_mileage,
    NULLIF(TRIM(CRGO_GENFREIGHT), '') AS crgo_genfreight,
    NULLIF(TRIM(CRGO_HOUSEHOLD), '') AS crgo_household,
    NULLIF(TRIM(CRGO_METALSHEET), '') AS crgo_metalsheet,
    NULLIF(TRIM(CRGO_MOTOVEH), '') AS crgo_motoveh,
    NULLIF(TRIM(CRGO_DRIVETOW), '') AS crgo_drivetow,
    NULLIF(TRIM(CRGO_LOGPOLE), '') AS crgo_logpole,
    NULLIF(TRIM(CRGO_BLDGMAT), '') AS crgo_bldgmat,
    NULLIF(TRIM(CRGO_MOBILEHOME), '') AS crgo_mobilehome,
    NULLIF(TRIM(CRGO_MACHLRG), '') AS crgo_machlrg,
    NULLIF(TRIM(CRGO_PRODUCE), '') AS crgo_produce,
    NULLIF(TRIM(CRGO_LIQGAS), '') AS crgo_liqgas,
    NULLIF(TRIM(CRGO_INTERMODAL), '') AS crgo_intermodal,
    NULLIF(TRIM(CRGO_PASSENGERS), '') AS crgo_passengers,
    NULLIF(TRIM(CRGO_OILFIELD), '') AS crgo_oilfield,
    NULLIF(TRIM(CRGO_LIVESTOCK), '') AS crgo_livestock,
    NULLIF(TRIM(CRGO_GRAINFEED), '') AS crgo_grainfeed,
    NULLIF(TRIM(CRGO_COALCOKE), '') AS crgo_coalcoke,
    NULLIF(TRIM(CRGO_MEAT), '') AS crgo_meat,
    NULLIF(TRIM(CRGO_GARBAGE), '') AS crgo_garbage,
    NULLIF(TRIM(CRGO_USMAIL), '') AS crgo_usmail,
    NULLIF(TRIM(CRGO_CHEM), '') AS crgo_chem,
    NULLIF(TRIM(CRGO_DRYBULK), '') AS crgo_drybulk,
    NULLIF(TRIM(CRGO_COLDFOOD), '') AS crgo_coldfood,
    NULLIF(TRIM(CRGO_BEVERAGES), '') AS crgo_beverages,
    NULLIF(TRIM(CRGO_PAPERPROD), '') AS crgo_paperprod,
    NULLIF(TRIM(CRGO_UTILITY), '') AS crgo_utility,
    NULLIF(TRIM(CRGO_FARMSUPP), '') AS crgo_farmsupp,
    NULLIF(TRIM(CRGO_CONSTRUCT), '') AS crgo_construct,
    NULLIF(TRIM(CRGO_WATERWELL), '') AS crgo_waterwell
INTO dbo.dim_carrier
FROM dbo.Company_Census_staging
WHERE TRY_CONVERT(int, DOT_NUMBER) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.dim_carrier;


/* 
    2. fact_inspection table
1 row/inspection: insp_id, dot, state, date, level, oos flags/counts, viol_count 

   Checking Vehicle_Inspection_staging:
   Confirms the table has 1 row per inspection by comparing total rows
   to distinct INSPECTION_ID values and checking for blank inspection IDs. 
   */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT INSPECTION_ID) AS distinct_inspection_ids,
    SUM(CASE WHEN INSPECTION_ID IS NULL OR TRIM(INSPECTION_ID) = '' THEN 1 ELSE 0 END) AS blank_inspection_ids
FROM dbo.Vehicle_Inspection_staging;

    -- Creating
DROP TABLE IF EXISTS dbo.fact_inspection;
GO

SELECT
    TRY_CONVERT(int, INSPECTION_ID) AS insp_id,
    TRY_CONVERT(int, DOT_NUMBER) AS dot,
    NULLIF(TRIM(REPORT_STATE), '') AS state,
    TRY_CONVERT(date, INSP_DATE, 112) AS inspection_date,
    TRY_CONVERT(int, INSP_LEVEL_ID) AS inspection_level,
    TRY_CONVERT(int, VIOL_TOTAL) AS viol_count,
    TRY_CONVERT(int, OOS_TOTAL) AS oos_count,
    TRY_CONVERT(int, DRIVER_VIOL_TOTAL) AS driver_viol_count,
    TRY_CONVERT(int, DRIVER_OOS_TOTAL) AS driver_oos_count,
    TRY_CONVERT(int, VEHICLE_VIOL_TOTAL) AS vehicle_viol_count,
    TRY_CONVERT(int, VEHICLE_OOS_TOTAL) AS vehicle_oos_count,
    TRY_CONVERT(int, HAZMAT_VIOL_TOTAL) AS hazmat_viol_count,
    TRY_CONVERT(int, HAZMAT_OOS_TOTAL) AS hazmat_oos_count,
    CASE WHEN TRY_CONVERT(int, OOS_TOTAL) > 0 THEN 1 ELSE 0 END AS has_oos,
    CASE WHEN TRY_CONVERT(int, VIOL_TOTAL) = 0 THEN 1 ELSE 0 END AS is_clean
INTO dbo.fact_inspection
FROM dbo.Vehicle_Inspection_staging
WHERE TRY_CONVERT(int, INSPECTION_ID) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.fact_inspection;

-- 3. fact_violation table
-- 1 row/violation: insp_id, dot, category/basic, code, oos_flag

/* Check Vehicle_Inspections_and_Violations_staging:
   Confirms the table has 1 row per violation by comparing total rows
   to distinct INSP_VIOLATION_ID values and checking for blank IDs. */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT INSP_VIOLATION_ID) AS distinct_violation_ids,
    SUM(CASE WHEN INSP_VIOLATION_ID IS NULL OR TRIM(INSP_VIOLATION_ID) = '' THEN 1 ELSE 0 END) AS blank_violation_ids
FROM dbo.Vehicle_Inspections_and_Violations_staging;


    -- Creating
DROP TABLE IF EXISTS dbo.fact_violation;
GO

SELECT
    TRY_CONVERT(int, v.INSPECTION_ID) AS insp_id,
    TRY_CONVERT(int, i.DOT_NUMBER) AS dot,
    TRY_CONVERT(int, v.INSP_VIOLATION_ID) AS violation_id,
    TRY_CONVERT(int, v.INSP_VIOLATION_CATEGORY_ID) AS category_basic,
    NULLIF(TRIM(v.PART_NO), '') AS part_no,
    NULLIF(TRIM(v.PART_NO_SECTION), '') AS part_no_section,
    CONCAT(NULLIF(TRIM(v.PART_NO), ''), '.', NULLIF(TRIM(v.PART_NO_SECTION), '')) AS code,
    NULLIF(TRIM(v.OUT_OF_SERVICE_INDICATOR), '') AS oos_flag,
    TRY_CONVERT(int, v.INSP_UNIT_ID) AS insp_unit_id,
    TRY_CONVERT(int, v.DEFECT_VERIFICATION_ID) AS defect_verification_id,
    NULLIF(TRIM(v.CITATION_NUMBER), '') AS citation_number
INTO dbo.fact_violation
FROM dbo.Vehicle_Inspections_and_Violations_staging AS v
LEFT JOIN dbo.Vehicle_Inspection_staging AS i
    ON TRY_CONVERT(int, v.INSPECTION_ID) = TRY_CONVERT(int, i.INSPECTION_ID)
WHERE TRY_CONVERT(int, v.INSP_VIOLATION_ID) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.fact_violation;


    -- 4. fact_crash table
    -- 1 row/crash: dot, date, state, fatal, injury, tow, lat/long

    /* Check Crash_File_staging:
   Confirms the table has 1 row per crash by comparing total rows
   to distinct CRASH_ID values and checking for blank crash IDs. */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT CRASH_ID) AS distinct_crash_ids,
    SUM(CASE WHEN CRASH_ID IS NULL OR TRIM(CRASH_ID) = '' THEN 1 ELSE 0 END) AS blank_crash_ids
FROM dbo.Crash_File_staging;

    -- Creating
DROP TABLE IF EXISTS dbo.fact_crash;
GO

SELECT
    TRY_CONVERT(int, CRASH_ID) AS crash_id,
    TRY_CONVERT(int, DOT_NUMBER) AS dot,
    TRY_CONVERT(date, REPORT_DATE, 112) AS crash_date,
    NULLIF(TRIM(REPORT_STATE), '') AS state,
    NULLIF(TRIM(CITY), '') AS city,
    NULLIF(TRIM(LOCATION), '') AS location,
    TRY_CONVERT(int, FATALITIES) AS fatal,
    TRY_CONVERT(int, INJURIES) AS injury,
    CASE WHEN UPPER(TRIM(TOW_AWAY)) = 'Y' THEN 1 ELSE 0 END AS tow,
    CAST(NULL AS decimal(9, 6)) AS latitude,
    CAST(NULL AS decimal(9, 6)) AS longitude
INTO dbo.fact_crash
FROM dbo.Crash_File_staging
WHERE TRY_CONVERT(int, CRASH_ID) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.fact_crash;


    -- 5. fact_insp_vehicle table
    -- 1 row/vehicle on an inspection: insp_id, dot, vin, make, unit_type

    /* Check Inspections_Per_Unit_staging:
   Confirms the table has 1 row per inspected vehicle/unit by comparing
   total rows to distinct INSP_UNIT_ID values and checking for blank unit IDs. */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT INSP_UNIT_ID) AS distinct_unit_ids,
    SUM(CASE WHEN INSP_UNIT_ID IS NULL OR TRIM(INSP_UNIT_ID) = '' THEN 1 ELSE 0 END) AS blank_unit_ids
FROM dbo.Inspections_Per_Unit_staging;

    -- Creating
DROP TABLE IF EXISTS dbo.fact_insp_vehicle;
GO

SELECT
    TRY_CONVERT(int, u.INSPECTION_ID) AS insp_id,
    TRY_CONVERT(int, i.DOT_NUMBER) AS dot,
    TRY_CONVERT(int, u.INSP_UNIT_ID) AS insp_unit_id,
    TRY_CONVERT(int, u.INSP_UNIT_TYPE_ID) AS unit_type_id,
    CASE TRY_CONVERT(int, u.INSP_UNIT_TYPE_ID)
        WHEN 1 THEN 'Bus'
        WHEN 2 THEN 'Dolly Converter'
        WHEN 3 THEN 'Full Trailer'
        WHEN 4 THEN 'Limousine'
        WHEN 5 THEN 'Motor Carrier'
        WHEN 6 THEN 'Other'
        WHEN 7 THEN 'Pole Trailer'
        WHEN 8 THEN 'School Bus'
        WHEN 9 THEN 'Semi Trailer'
        WHEN 10 THEN 'Straight Truck'
        WHEN 11 THEN 'Truck Tractor'
        WHEN 12 THEN 'Van'
        WHEN 13 THEN 'Unknown'
        WHEN 14 THEN 'Intermodal Chassis'
        WHEN 15 THEN 'Crib Log Trailer'
        ELSE 'Unknown'
    END AS unit_type,
    NULLIF(TRIM(u.INSP_UNIT_MAKE), '') AS make,
    NULLIF(TRIM(u.INSP_UNIT_VEHICLE_ID_NUMBER), '') AS vin,
    NULLIF(TRIM(u.INSP_UNIT_LICENSE), '') AS license_plate,
    NULLIF(TRIM(u.INSP_UNIT_LICENSE_STATE), '') AS license_state
INTO dbo.fact_insp_vehicle
FROM dbo.Inspections_Per_Unit_staging AS u
LEFT JOIN dbo.Vehicle_Inspection_staging AS i
    ON TRY_CONVERT(int, u.INSPECTION_ID) = TRY_CONVERT(int, i.INSPECTION_ID)
WHERE TRY_CONVERT(int, u.INSP_UNIT_ID) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.fact_insp_vehicle;


    -- 6. dim_insurance table
    -- 1 row/policy: dot, insurer_name, status, effective dates

    /* Check ActPendInsur_staging:
   Confirms the insurance staging table has policy rows and checks key blanks. */
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN DOT_NUMBER IS NULL OR TRIM(DOT_NUMBER) = '' THEN 1 ELSE 0 END) AS blank_dot_numbers,
    SUM(CASE WHEN policy_no IS NULL OR TRIM(policy_no) = '' THEN 1 ELSE 0 END) AS blank_policy_numbers,
    SUM(CASE WHEN name_company IS NULL OR TRIM(name_company) = '' THEN 1 ELSE 0 END) AS blank_insurer_names
FROM dbo.ActPendInsur_staging;

    -- Creating
DROP TABLE IF EXISTS dbo.dim_insurance;
GO

SELECT
    TRY_CONVERT(int, DOT_NUMBER) AS dot,
    NULLIF(TRIM(DOCKET_NUMBER), '') AS docket_number,
    NULLIF(TRIM(ins_form_code), '') AS form_code,
    NULLIF(TRIM(ins_type_desc), '') AS insurance_type,
    NULLIF(TRIM(name_company), '') AS insurer_name,
    NULLIF(TRIM(policy_no), '') AS policy_no,
    TRY_CONVERT(date, trans_date, 101) AS trans_date,
    TRY_CONVERT(int, underl_lim_amount) AS underlying_limit_amount,
    TRY_CONVERT(int, max_cov_amount) AS max_coverage_amount,
    TRY_CONVERT(date, effective_date, 101) AS effective_date,
    TRY_CONVERT(date, cancl_effective_date, 101) AS cancel_effective_date,
    CASE
        WHEN TRY_CONVERT(date, cancl_effective_date, 101) IS NULL THEN 'active'
        WHEN TRY_CONVERT(date, cancl_effective_date, 101) >= '2026-06-11' THEN 'active'
        ELSE 'inactive'
    END AS status
INTO dbo.dim_insurance
FROM dbo.ActPendInsur_staging
WHERE TRY_CONVERT(int, DOT_NUMBER) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.dim_insurance;


    -- 7. fact_authority table
    -- 1 row/authority: dot, mc/docket, auth_type, status, grant_date

    /* Check AuthHist_All_With_History_staging:
   Confirms the authority staging table has authority rows and checks key blanks. */
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN DOT_NUMBER IS NULL OR TRIM(DOT_NUMBER) = '' THEN 1 ELSE 0 END) AS blank_dot_numbers,
    SUM(CASE WHEN DOCKET_NUMBER IS NULL OR TRIM(DOCKET_NUMBER) = '' THEN 1 ELSE 0 END) AS blank_docket_numbers,
    SUM(CASE WHEN OP_AUTH_TYPE IS NULL OR TRIM(OP_AUTH_TYPE) = '' THEN 1 ELSE 0 END) AS blank_auth_types
FROM dbo.AuthHist_All_With_History_staging;

    -- Creating
DROP TABLE IF EXISTS dbo.fact_authority;
GO

SELECT
    TRY_CONVERT(int, DOT_NUMBER) AS dot,
    NULLIF(TRIM(DOCKET_NUMBER), '') AS docket_number,
    TRY_CONVERT(int, SUB_NUMBER) AS sub_number,
    NULLIF(TRIM(OP_AUTH_TYPE), '') AS auth_type,
    NULLIF(TRIM(ORIGINAL_ACTION_DESC), '') AS original_action,
    CASE
        WHEN TRY_CONVERT(date, ORIG_SERVED_DATE, 101) >= '1900-01-01'
        THEN TRY_CONVERT(date, ORIG_SERVED_DATE, 101)
        ELSE NULL
    END AS grant_date,
    NULLIF(TRIM(DISP_ACTION_DESC), '') AS disposition_action,
    CASE
        WHEN TRY_CONVERT(date, DISP_DECIDED_DATE, 101) >= '1900-01-01'
        THEN TRY_CONVERT(date, DISP_DECIDED_DATE, 101)
        ELSE NULL
    END AS disposition_decided_date,
    CASE
        WHEN TRY_CONVERT(date, DISP_SERVED_DATE, 101) >= '1900-01-01'
        THEN TRY_CONVERT(date, DISP_SERVED_DATE, 101)
        ELSE NULL
    END AS disposition_served_date,
    CASE
        WHEN UPPER(TRIM(DISP_ACTION_DESC)) = 'REVOKED' THEN 'revoked'
        WHEN UPPER(TRIM(ORIGINAL_ACTION_DESC)) IN ('GRANTED', 'REINSTATED')
             AND (DISP_ACTION_DESC IS NULL OR TRIM(DISP_ACTION_DESC) = '') THEN 'active'
        ELSE LOWER(NULLIF(TRIM(COALESCE(DISP_ACTION_DESC, ORIGINAL_ACTION_DESC)), ''))
    END AS status
INTO dbo.fact_authority
FROM dbo.AuthHist_All_With_History_staging
WHERE TRY_CONVERT(int, DOT_NUMBER) IS NOT NULL;
GO

    -- Verify
SELECT COUNT(*) AS row_count
FROM dbo.fact_authority;

    -- Run 1 final all-table check:
SELECT 'dim_carrier' AS table_name, COUNT(*) AS row_count FROM dbo.dim_carrier
UNION ALL
SELECT 'fact_inspection', COUNT(*) FROM dbo.fact_inspection
UNION ALL
SELECT 'fact_violation', COUNT(*) FROM dbo.fact_violation
UNION ALL
SELECT 'fact_crash', COUNT(*) FROM dbo.fact_crash
UNION ALL
SELECT 'fact_insp_vehicle', COUNT(*) FROM dbo.fact_insp_vehicle
UNION ALL
SELECT 'dim_insurance', COUNT(*) FROM dbo.dim_insurance
UNION ALL
SELECT 'fact_authority', COUNT(*) FROM dbo.fact_authority;

