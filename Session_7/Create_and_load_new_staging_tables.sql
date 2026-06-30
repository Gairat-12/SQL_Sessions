/*
Practice 7 - Create and load missing FMCSA staging tables

This script uses direct BULK INSERT from local CSV file paths.
Run in SQL Server Management Studio against usaTrucking database.

Staging columns use VARCHAR(255) because these are raw import tables.
The clean fact tables should convert columns to proper INT, DATE, CHAR, etc.
*/

SET NOCOUNT ON;
GO

USE usaTrucking;
GO

/* Crash_File_staging */
DROP TABLE IF EXISTS dbo.[Crash_File_staging];
GO

CREATE TABLE dbo.[Crash_File_staging] (
    [CHANGE_DATE] VARCHAR(255) NULL,
    [CRASH_ID] VARCHAR(255) NULL,
    [REPORT_STATE] VARCHAR(255) NULL,
    [REPORT_NUMBER] VARCHAR(255) NULL,
    [REPORT_DATE] VARCHAR(255) NULL,
    [REPORT_TIME] VARCHAR(255) NULL,
    [REPORT_SEQ_NO] VARCHAR(255) NULL,
    [DOT_NUMBER] VARCHAR(255) NULL,
    [CI_STATUS_CODE] VARCHAR(255) NULL,
    [FINAL_STATUS_DATE] VARCHAR(255) NULL,
    [LOCATION] VARCHAR(255) NULL,
    [CITY_CODE] VARCHAR(255) NULL,
    [CITY] VARCHAR(255) NULL,
    [STATE] VARCHAR(255) NULL,
    [COUNTY_CODE] VARCHAR(255) NULL,
    [TRUCK_BUS_IND] VARCHAR(255) NULL,
    [TRAFFICWAY_ID] VARCHAR(255) NULL,
    [ACCESS_CONTROL_ID] VARCHAR(255) NULL,
    [ROAD_SURFACE_CONDITION_ID] VARCHAR(255) NULL,
    [CARGO_BODY_TYPE_ID] VARCHAR(255) NULL,
    [GVW_RATING_ID] VARCHAR(255) NULL,
    [VEHICLE_IDENTIFICATION_NUMBER] VARCHAR(255) NULL,
    [VEHICLE_LICENSE_NUMBER] VARCHAR(255) NULL,
    [VEHICLE_LIC_STATE] VARCHAR(255) NULL,
    [VEHICLE_HAZMAT_PLACARD] VARCHAR(255) NULL,
    [WEATHER_CONDITION_ID] VARCHAR(255) NULL,
    [VEHICLE_CONFIGURATION_ID] VARCHAR(255) NULL,
    [LIGHT_CONDITION_ID] VARCHAR(255) NULL,
    [HAZMAT_RELEASED] VARCHAR(255) NULL,
    [AGENCY] VARCHAR(255) NULL,
    [VEHICLES_IN_ACCIDENT] VARCHAR(255) NULL,
    [FATALITIES] VARCHAR(255) NULL,
    [INJURIES] VARCHAR(255) NULL,
    [TOW_AWAY] VARCHAR(255) NULL,
    [FEDERAL_RECORDABLE] VARCHAR(255) NULL,
    [STATE_RECORDABLE] VARCHAR(255) NULL,
    [SNET_VERSION_NUMBER] VARCHAR(255) NULL,
    [SNET_SEQUENCE_ID] VARCHAR(255) NULL,
    [TRANSACTION_CODE] VARCHAR(255) NULL,
    [TRANSACTION_DATE] VARCHAR(255) NULL,
    [UPLOAD_FIRST_BYTE] VARCHAR(255) NULL,
    [UPLOAD_DOT_NUMBER] VARCHAR(255) NULL,
    [UPLOAD_SEARCH_INDICATOR] VARCHAR(255) NULL,
    [UPLOAD_DATE] VARCHAR(255) NULL,
    [ADD_DATE] VARCHAR(255) NULL,
    [CRASH_CARRIER_ID] VARCHAR(255) NULL,
    [CRASH_CARRIER_NAME] VARCHAR(255) NULL,
    [CRASH_CARRIER_STREET] VARCHAR(255) NULL,
    [CRASH_CARRIER_CITY] VARCHAR(255) NULL,
    [CRASH_CARRIER_CITY_CODE] VARCHAR(255) NULL,
    [CRASH_CARRIER_STATE] VARCHAR(255) NULL,
    [CRASH_CARRIER_ZIP_CODE] VARCHAR(255) NULL,
    [CRASH_COLONIA] VARCHAR(255) NULL,
    [DOCKET_NUMBER] VARCHAR(255) NULL,
    [CRASH_CARRIER_INTERSTATE] VARCHAR(255) NULL,
    [NO_ID_FLAG] VARCHAR(255) NULL,
    [STATE_NUMBER] VARCHAR(255) NULL,
    [STATE_ISSUING_NUMBER] VARCHAR(255) NULL,
    [CRASH_EVENT_SEQ_ID_DESC] VARCHAR(255) NULL
);
GO

PRINT 'Loading dbo.Crash_File_staging';
GO

BULK INSERT dbo.[Crash_File_staging]
FROM 'C:\Users\mrhay\Downloads\Crash_File_20260611.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',
    TABLOCK,
    MAXERRORS       = 0
);
GO

SELECT 'Crash_File_staging' AS table_name, COUNT(*) AS row_count FROM dbo.[Crash_File_staging];
GO

/* Vehicle_Inspections_and_Violations_staging */
DROP TABLE IF EXISTS dbo.[Vehicle_Inspections_and_Violations_staging];
GO

CREATE TABLE dbo.[Vehicle_Inspections_and_Violations_staging] (
    [CHANGE_DATE] VARCHAR(255) NULL,
    [INSPECTION_ID] VARCHAR(255) NULL,
    [INSP_VIOLATION_ID] VARCHAR(255) NULL,
    [SEQ_NO] VARCHAR(255) NULL,
    [PART_NO] VARCHAR(255) NULL,
    [PART_NO_SECTION] VARCHAR(255) NULL,
    [INSP_VIOL_UNIT] VARCHAR(255) NULL,
    [INSP_UNIT_ID] VARCHAR(255) NULL,
    [INSP_VIOLATION_CATEGORY_ID] VARCHAR(255) NULL,
    [OUT_OF_SERVICE_INDICATOR] VARCHAR(255) NULL,
    [DEFECT_VERIFICATION_ID] VARCHAR(255) NULL,
    [CITATION_NUMBER] VARCHAR(255) NULL
);
GO

PRINT 'Loading dbo.Vehicle_Inspections_and_Violations_staging';
GO

BULK INSERT dbo.[Vehicle_Inspections_and_Violations_staging]
FROM 'C:\Users\mrhay\Downloads\Vehicle_Inspections_and_Violations_20260611.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',
    TABLOCK,
    MAXERRORS       = 0
);
GO

SELECT 'Vehicle_Inspections_and_Violations_staging' AS table_name, COUNT(*) AS row_count FROM dbo.[Vehicle_Inspections_and_Violations_staging];
GO

/* Inspections_Per_Unit_staging */
DROP TABLE IF EXISTS dbo.[Inspections_Per_Unit_staging];
GO

CREATE TABLE dbo.[Inspections_Per_Unit_staging] (
    [CHANGE_DATE] VARCHAR(255) NULL,
    [INSPECTION_ID] VARCHAR(255) NULL,
    [INSP_UNIT_ID] VARCHAR(255) NULL,
    [INSP_UNIT_TYPE_ID] VARCHAR(255) NULL,
    [INSP_UNIT_NUMBER] VARCHAR(255) NULL,
    [INSP_UNIT_MAKE] VARCHAR(255) NULL,
    [INSP_UNIT_COMPANY] VARCHAR(255) NULL,
    [INSP_UNIT_LICENSE] VARCHAR(255) NULL,
    [INSP_UNIT_LICENSE_STATE] VARCHAR(255) NULL,
    [INSP_UNIT_VEHICLE_ID_NUMBER] VARCHAR(255) NULL,
    [INSP_UNIT_DECAL] VARCHAR(255) NULL,
    [INSP_UNIT_DECAL_NUMBER] VARCHAR(255) NULL
);
GO

PRINT 'Loading dbo.Inspections_Per_Unit_staging';
GO

BULK INSERT dbo.[Inspections_Per_Unit_staging]
FROM 'C:\Users\mrhay\Downloads\Inspections_Per_Unit_20260611.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',
    TABLOCK,
    MAXERRORS       = 0
);
GO

SELECT 'Inspections_Per_Unit_staging' AS table_name, COUNT(*) AS row_count FROM dbo.[Inspections_Per_Unit_staging];
GO

/* AuthHist_All_With_History_staging */
DROP TABLE IF EXISTS dbo.[AuthHist_All_With_History_staging];
GO

CREATE TABLE dbo.[AuthHist_All_With_History_staging] (
    [DOCKET_NUMBER] VARCHAR(255) NULL,
    [DOT_NUMBER] VARCHAR(255) NULL,
    [SUB_NUMBER] VARCHAR(255) NULL,
    [OP_AUTH_TYPE] VARCHAR(255) NULL,
    [ORIGINAL_ACTION_DESC] VARCHAR(255) NULL,
    [ORIG_SERVED_DATE] VARCHAR(255) NULL,
    [DISP_ACTION_DESC] VARCHAR(255) NULL,
    [DISP_DECIDED_DATE] VARCHAR(255) NULL,
    [DISP_SERVED_DATE] VARCHAR(255) NULL
);
GO

PRINT 'Loading dbo.AuthHist_All_With_History_staging';
GO

BULK INSERT dbo.[AuthHist_All_With_History_staging]
FROM 'C:\Users\mrhay\Downloads\AuthHist_-_All_With_History_20260611.csv'
WITH (
    FORMAT          = 'CSV',
    FIELDQUOTE      = '"',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    CODEPAGE        = '65001',
    TABLOCK,
    MAXERRORS       = 0
);
GO

SELECT 'AuthHist_All_With_History_staging' AS table_name, COUNT(*) AS row_count FROM dbo.[AuthHist_All_With_History_staging];
GO

/* Final row-count summary */
SELECT 'Crash_File_staging' AS table_name, COUNT(*) AS row_count FROM dbo.Crash_File_staging
UNION ALL
SELECT 'Vehicle_Inspections_and_Violations_staging', COUNT(*) FROM dbo.Vehicle_Inspections_and_Violations_staging
UNION ALL
SELECT 'Inspections_Per_Unit_staging', COUNT(*) FROM dbo.Inspections_Per_Unit_staging
UNION ALL
SELECT 'AuthHist_All_With_History_staging', COUNT(*) FROM dbo.AuthHist_All_With_History_staging;
GO

