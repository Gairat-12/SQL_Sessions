
	-- 02. Load Data
	--------------------------------------------------------------------------
	-- TASK 8: Load all 45 CSVs in dependency order (tutor-verified order).
	--		   Method per table: BULK INSERT csv -> all-text staging table,
	--		   then INSERT...SELECT with type conversions into the real table.
	--		   Conversions: geography = STGeomFromText(wkt, 4326),
	--					    varbinary = CONVERT(varbinary(max), '0x...', 1),
	--					    empty text '' -> NULL for nullable columns.
	--		   NOTE: Archive tables have no PK/FK (see 01_create_objects.sql
	--		   Task 4/6) so they can load at any point; base tables are
	--		   ordered strictly parent-before-child.
	---------------------------------------------------------------------------
USE WWI_Rebuild;
GO
SET QUOTED_IDENTIFIER ON;
GO

	-- Staging schema: temporary home for raw CSV text before conversion
IF SCHEMA_ID(N'Staging') IS NULL EXEC (N'CREATE SCHEMA Staging;');
GO

-- 1. Application.Cities_Archive --
-------------------------------------
IF OBJECT_ID('Staging.Cities_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.Cities_Archive;

CREATE TABLE Staging.Cities_Archive (
	[CityID]					NVARCHAR(MAX)	NULL,
	[CityName]					NVARCHAR(MAX)	NULL,
	[StateProvinceID]			NVARCHAR(MAX)	NULL,
	[Location]					NVARCHAR(MAX)	NULL,
	[LatestRecordedPopulation]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Cities_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.Cities_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.Cities_Archive (
	[CityID], [CityName], [StateProvinceID], [Location],
	[LatestRecordedPopulation], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CityID], N'')),
	ISNULL([CityName], N''),
	CONVERT(INT,	NULLIF([StateProvinceID], N'')),
	CASE WHEN NULLIF([Location], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([Location], 4326)
	END,
	CONVERT(BIGINT,	NULLIF([LatestRecordedPopulation], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Cities_Archive;
DROP TABLE Staging.Cities_Archive;
GO

-- 2. Application.Countries_Archive --
-----------------------------------------
IF OBJECT_ID('Staging.Countries_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.Countries_Archive;

CREATE TABLE Staging.Countries_Archive (
	[CountryID]					NVARCHAR(MAX)	NULL,
	[CountryName]				NVARCHAR(MAX)	NULL,
	[FormalName]				NVARCHAR(MAX)	NULL,
	[IsoAlpha3Code]				NVARCHAR(MAX)	NULL,
	[IsoNumericCode]			NVARCHAR(MAX)	NULL,
	[CountryType]				NVARCHAR(MAX)	NULL,
	[LatestRecordedPopulation]	NVARCHAR(MAX)	NULL,
	[Continent]					NVARCHAR(MAX)	NULL,
	[Region]					NVARCHAR(MAX)	NULL,
	[Subregion]					NVARCHAR(MAX)	NULL,
	[Border]					NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Countries_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.Countries_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.Countries_Archive (
	[CountryID], [CountryName], [FormalName], [IsoAlpha3Code], [IsoNumericCode],
	[CountryType], [LatestRecordedPopulation], [Continent], [Region], [Subregion],
	[Border], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CountryID], N'')),
	ISNULL([CountryName], N''),
	ISNULL([FormalName], N''),
	NULLIF([IsoAlpha3Code], N''),
	CONVERT(INT,	NULLIF([IsoNumericCode], N'')),
	NULLIF([CountryType], N''),
	CONVERT(BIGINT,	NULLIF([LatestRecordedPopulation], N'')),
	ISNULL([Continent], N''),
	ISNULL([Region], N''),
	ISNULL([Subregion], N''),
	CASE WHEN NULLIF([Border], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([Border], 4326)
	END,
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Countries_Archive;
DROP TABLE Staging.Countries_Archive;
GO

-- 3. Application.DeliveryMethods_Archive --
------------------------------------------------
IF OBJECT_ID('Staging.DeliveryMethods_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.DeliveryMethods_Archive;

CREATE TABLE Staging.DeliveryMethods_Archive (
	[DeliveryMethodID]		NVARCHAR(MAX)	NULL,
	[DeliveryMethodName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.DeliveryMethods_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.DeliveryMethods_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.DeliveryMethods_Archive (
	[DeliveryMethodID], [DeliveryMethodName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	ISNULL([DeliveryMethodName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.DeliveryMethods_Archive;
DROP TABLE Staging.DeliveryMethods_Archive;
GO

-- 4. Application.PaymentMethods_Archive --
-----------------------------------------------
IF OBJECT_ID('Staging.PaymentMethods_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.PaymentMethods_Archive;

CREATE TABLE Staging.PaymentMethods_Archive (
	[PaymentMethodID]		NVARCHAR(MAX)	NULL,
	[PaymentMethodName]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.PaymentMethods_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.PaymentMethods_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.PaymentMethods_Archive (
	[PaymentMethodID], [PaymentMethodName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,			NULLIF([PaymentMethodID], N'')),
							ISNULL([PaymentMethodName], N''),
	CONVERT(INT,			NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.PaymentMethods_Archive;
DROP TABLE Staging.PaymentMethods_Archive;
GO

-- 5. Application.People -- parent of all tables (self-FK on LastEditedBy: OK per-statement)
------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.People', 'U') IS NOT NULL
	DROP TABLE Staging.People;

CREATE TABLE Staging.People (
	[PersonID]					NVARCHAR(MAX)	NULL,
	[FullName]					NVARCHAR(MAX)	NULL,
	[PreferredName]				NVARCHAR(MAX)	NULL,
	[IsPermittedToLogon]		NVARCHAR(MAX)	NULL,
	[LogonName]					NVARCHAR(MAX)	NULL,
	[IsExternalLogonProvider]	NVARCHAR(MAX)	NULL,
	[HashedPassword]			NVARCHAR(MAX)	NULL,
	[IsSystemUser]				NVARCHAR(MAX)	NULL,
	[IsEmployee]				NVARCHAR(MAX)	NULL,
	[IsSalesperson]				NVARCHAR(MAX)	NULL,
	[UserPreferences]			NVARCHAR(MAX)	NULL,
	[PhoneNumber]				NVARCHAR(MAX)	NULL,
	[FaxNumber]					NVARCHAR(MAX)	NULL,
	[EmailAddress]				NVARCHAR(MAX)	NULL,
	[Photo]						NVARCHAR(MAX)	NULL,
	[CustomFields]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.People
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.People.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.People (
	[PersonID], [FullName], [PreferredName], [IsPermittedToLogon],
	[LogonName], [IsExternalLogonProvider], [HashedPassword], [IsSystemUser],
	[IsEmployee], [IsSalesperson], [UserPreferences], [PhoneNumber],
	[FaxNumber], [EmailAddress], [Photo], [CustomFields],
	[LastEditedBy], [ValidFrom], [ValidTo]
)
SELECT
	CONVERT(INT,	NULLIF([PersonID], N'')),
	ISNULL([FullName], N''),
	ISNULL([PreferredName], N''),
	CONVERT(BIT,	NULLIF([IsPermittedToLogon], N'')),
	NULLIF([LogonName], N''),
	CONVERT(BIT,	NULLIF([IsExternalLogonProvider], N'')),
	CONVERT(VARBINARY(MAX),	NULLIF([HashedPassword], N''), 1),
	CONVERT(BIT,	NULLIF([IsSystemUser], N'')),
	CONVERT(BIT,	NULLIF([IsEmployee], N'')),
	CONVERT(BIT,	NULLIF([IsSalesperson], N'')),
	NULLIF([UserPreferences], N''),
	NULLIF([PhoneNumber], N''),
	NULLIF([FaxNumber], N''),
	NULLIF([EmailAddress], N''),
	CONVERT(VARBINARY(MAX),	NULLIF([Photo], N''), 1),
	NULLIF([CustomFields], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.People;
DROP TABLE Staging.People;
GO

-- 6. Application.People_Archive -- stores computed columns as real data
---------------------------------------------------------------------------
IF OBJECT_ID('Staging.People_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.People_Archive;

CREATE TABLE Staging.People_Archive (
	[PersonID]					NVARCHAR(MAX)	NULL,
	[FullName]					NVARCHAR(MAX)	NULL,
	[PreferredName]				NVARCHAR(MAX)	NULL,
	[SearchName]				NVARCHAR(MAX)	NULL,
	[IsPermittedToLogon]		NVARCHAR(MAX)	NULL,
	[LogonName]					NVARCHAR(MAX)	NULL,
	[IsExternalLogonProvider]	NVARCHAR(MAX)	NULL,
	[HashedPassword]			NVARCHAR(MAX)	NULL,
	[IsSystemUser]				NVARCHAR(MAX)	NULL,
	[IsEmployee]				NVARCHAR(MAX)	NULL,
	[IsSalesperson]				NVARCHAR(MAX)	NULL,
	[UserPreferences]			NVARCHAR(MAX)	NULL,
	[PhoneNumber]				NVARCHAR(MAX)	NULL,
	[FaxNumber]					NVARCHAR(MAX)	NULL,
	[EmailAddress]				NVARCHAR(MAX)	NULL,
	[Photo]						NVARCHAR(MAX)	NULL,
	[CustomFields]				NVARCHAR(MAX)	NULL,
	[OtherLanguages]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.People_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.People_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.People_Archive (
	[PersonID], [FullName], [PreferredName], [SearchName], [IsPermittedToLogon],
	[LogonName], [IsExternalLogonProvider], [HashedPassword], [IsSystemUser], [IsEmployee],
	[IsSalesperson], [UserPreferences], [PhoneNumber], [FaxNumber], [EmailAddress],
	[Photo], [CustomFields], [OtherLanguages], [LastEditedBy], [ValidFrom], [ValidTo]
)
SELECT
	CONVERT(INT,	NULLIF([PersonID], N'')),
	ISNULL([FullName], N''),
	ISNULL([PreferredName], N''),
	ISNULL([SearchName], N''),
	CONVERT(BIT,	NULLIF([IsPermittedToLogon], N'')),
	NULLIF([LogonName], N''),
	CONVERT(BIT,	NULLIF([IsExternalLogonProvider], N'')),
	CONVERT(VARBINARY(MAX),	NULLIF([HashedPassword], N''), 1),
	CONVERT(BIT,	NULLIF([IsSystemUser], N'')),
	CONVERT(BIT,	NULLIF([IsEmployee], N'')),
	CONVERT(BIT,	NULLIF([IsSalesperson], N'')),
	NULLIF([UserPreferences], N''),
	NULLIF([PhoneNumber], N''),
	NULLIF([FaxNumber], N''),
	NULLIF([EmailAddress], N''),
	CONVERT(VARBINARY(MAX),	NULLIF([Photo], N''), 1),
	NULLIF([CustomFields], N''),
	NULLIF([OtherLanguages], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.People_Archive;
DROP TABLE Staging.People_Archive;
GO

-- 7. Application.StateProvinces_Archive --
----------------------------------------------
IF OBJECT_ID('Staging.StateProvinces_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.StateProvinces_Archive;

CREATE TABLE Staging.StateProvinces_Archive (
	[StateProvinceID]			NVARCHAR(MAX)	NULL,
	[StateProvinceCode]			NVARCHAR(MAX)	NULL,
	[StateProvinceName]			NVARCHAR(MAX)	NULL,
	[CountryID]					NVARCHAR(MAX)	NULL,
	[SalesTerritory]			NVARCHAR(MAX)	NULL,
	[Border]					NVARCHAR(MAX)	NULL,
	[LatestRecordedPopulation]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StateProvinces_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.StateProvinces_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.StateProvinces_Archive (
	[StateProvinceID], [StateProvinceCode], [StateProvinceName], [CountryID],
	[SalesTerritory], [Border], [LatestRecordedPopulation], [LastEditedBy],
	[ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([StateProvinceID], N'')),
	ISNULL([StateProvinceCode], N''),
	ISNULL([StateProvinceName], N''),
	CONVERT(INT,	NULLIF([CountryID], N'')),
	ISNULL([SalesTerritory], N''),
	CASE WHEN NULLIF([Border], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([Border], 4326)
	END,
	CONVERT(BIGINT,	NULLIF([LatestRecordedPopulation], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.StateProvinces_Archive;
DROP TABLE Staging.StateProvinces_Archive;
GO

-- 8. Application.TransactionTypes (needs: People) --
---------------------------------------------------------
IF OBJECT_ID('Staging.TransactionTypes', 'U') IS NOT NULL
	DROP TABLE Staging.TransactionTypes;

CREATE TABLE Staging.TransactionTypes (
	[TransactionTypeID]		NVARCHAR(MAX)	NULL,
	[TransactionTypeName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.TransactionTypes
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.TransactionTypes.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.TransactionTypes (
	[TransactionTypeID], [TransactionTypeName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([TransactionTypeID], N'')),
	ISNULL([TransactionTypeName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.TransactionTypes;
DROP TABLE Staging.TransactionTypes;
GO

-- 9. Application.TransactionTypes_Archive --
-------------------------------------------------
IF OBJECT_ID('Staging.TransactionTypes_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.TransactionTypes_Archive;

CREATE TABLE Staging.TransactionTypes_Archive (
	[TransactionTypeID]		NVARCHAR(MAX)	NULL,
	[TransactionTypeName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.TransactionTypes_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.TransactionTypes_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.TransactionTypes_Archive (
	[TransactionTypeID], [TransactionTypeName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([TransactionTypeID], N'')),
	ISNULL([TransactionTypeName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.TransactionTypes_Archive;
DROP TABLE Staging.TransactionTypes_Archive;
GO

-- 10. Purchasing.SupplierCategories (needs: People) --
----------------------------------------------------------
IF OBJECT_ID('Staging.SupplierCategories', 'U') IS NOT NULL
	DROP TABLE Staging.SupplierCategories;

CREATE TABLE Staging.SupplierCategories (
	[SupplierCategoryID]	NVARCHAR(MAX)	NULL,
	[SupplierCategoryName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.SupplierCategories
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.SupplierCategories.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.SupplierCategories (
	[SupplierCategoryID], [SupplierCategoryName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([SupplierCategoryID], N'')),
	ISNULL([SupplierCategoryName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.SupplierCategories;
DROP TABLE Staging.SupplierCategories;
GO

-- 11. Purchasing.SupplierCategories_Archive --
------------------------------------------------
IF OBJECT_ID('Staging.SupplierCategories_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.SupplierCategories_Archive;

CREATE TABLE Staging.SupplierCategories_Archive (
	[SupplierCategoryID]	NVARCHAR(MAX)	NULL,
	[SupplierCategoryName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.SupplierCategories_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.SupplierCategories_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.SupplierCategories_Archive (
	[SupplierCategoryID], [SupplierCategoryName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([SupplierCategoryID], N'')),
	ISNULL([SupplierCategoryName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.SupplierCategories_Archive;
DROP TABLE Staging.SupplierCategories_Archive;
GO

-- 12. Purchasing.Suppliers_Archive -- same empty-address fix as Suppliers (ISNULL '')
------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.Suppliers_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.Suppliers_Archive;

CREATE TABLE Staging.Suppliers_Archive (
	[SupplierID]				NVARCHAR(MAX)	NULL,
	[SupplierName]				NVARCHAR(MAX)	NULL,
	[SupplierCategoryID]		NVARCHAR(MAX)	NULL,
	[PrimaryContactPersonID]	NVARCHAR(MAX)	NULL,
	[AlternateContactPersonID]	NVARCHAR(MAX)	NULL,
	[DeliveryMethodID]			NVARCHAR(MAX)	NULL,
	[DeliveryCityID]			NVARCHAR(MAX)	NULL,
	[PostalCityID]				NVARCHAR(MAX)	NULL,
	[SupplierReference]			NVARCHAR(MAX)	NULL,
	[BankAccountName]			NVARCHAR(MAX)	NULL,
	[BankAccountBranch]			NVARCHAR(MAX)	NULL,
	[BankAccountCode]			NVARCHAR(MAX)	NULL,
	[BankAccountNumber]			NVARCHAR(MAX)	NULL,
	[BankInternationalCode]		NVARCHAR(MAX)	NULL,
	[PaymentDays]				NVARCHAR(MAX)	NULL,
	[InternalComments]			NVARCHAR(MAX)	NULL,
	[PhoneNumber]				NVARCHAR(MAX)	NULL,
	[FaxNumber]					NVARCHAR(MAX)	NULL,
	[WebsiteURL]				NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine1]		NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine2]		NVARCHAR(MAX)	NULL,
	[DeliveryPostalCode]		NVARCHAR(MAX)	NULL,
	[DeliveryLocation]			NVARCHAR(MAX)	NULL,
	[PostalAddressLine1]		NVARCHAR(MAX)	NULL,
	[PostalAddressLine2]		NVARCHAR(MAX)	NULL,
	[PostalPostalCode]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Suppliers_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.Suppliers_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.Suppliers_Archive (
	[SupplierID], [SupplierName], [SupplierCategoryID], [PrimaryContactPersonID],
	[AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID],
	[SupplierReference], [BankAccountName], [BankAccountBranch], [BankAccountCode],
	[BankAccountNumber], [BankInternationalCode], [PaymentDays], [InternalComments],
	[PhoneNumber], [FaxNumber], [WebsiteURL], [DeliveryAddressLine1],
	[DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation],
	[PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode],
	[LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([SupplierID], N'')),
	ISNULL([SupplierName], N''),
	CONVERT(INT,	NULLIF([SupplierCategoryID], N'')),
	CONVERT(INT,	NULLIF([PrimaryContactPersonID], N'')),
	CONVERT(INT,	NULLIF([AlternateContactPersonID], N'')),
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	CONVERT(INT,	NULLIF([DeliveryCityID], N'')),
	CONVERT(INT,	NULLIF([PostalCityID], N'')),
	NULLIF([SupplierReference], N''),
	NULLIF([BankAccountName], N''),
	NULLIF([BankAccountBranch], N''),
	NULLIF([BankAccountCode], N''),
	NULLIF([BankAccountNumber], N''),
	NULLIF([BankInternationalCode], N''),
	CONVERT(INT,	NULLIF([PaymentDays], N'')),
	NULLIF([InternalComments], N''),
	ISNULL([PhoneNumber], N''),
	ISNULL([FaxNumber], N''),
	ISNULL([WebsiteURL], N''),
	ISNULL([DeliveryAddressLine1], N''),		-- the 4-empty-rows fix
	NULLIF([DeliveryAddressLine2], N''),
	ISNULL([DeliveryPostalCode], N''),
	CASE WHEN NULLIF([DeliveryLocation], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([DeliveryLocation], 4326)
	END,
	ISNULL([PostalAddressLine1], N''),
	NULLIF([PostalAddressLine2], N''),
	ISNULL([PostalPostalCode], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Suppliers_Archive;
DROP TABLE Staging.Suppliers_Archive;
GO

-- 13. Sales.BuyingGroups (needs: People) --
-----------------------------------------------
IF OBJECT_ID('Staging.BuyingGroups', 'U') IS NOT NULL
	DROP TABLE Staging.BuyingGroups;

CREATE TABLE Staging.BuyingGroups (
	[BuyingGroupID]		NVARCHAR(MAX)	NULL,
	[BuyingGroupName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[ValidFrom]			NVARCHAR(MAX)	NULL,
	[ValidTo]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.BuyingGroups
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.BuyingGroups.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.BuyingGroups (
	[BuyingGroupID], [BuyingGroupName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([BuyingGroupID], N'')),
	ISNULL([BuyingGroupName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.BuyingGroups;
DROP TABLE Staging.BuyingGroups;
GO

-- 14. Sales.BuyingGroups_Archive --
-------------------------------------
IF OBJECT_ID('Staging.BuyingGroups_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.BuyingGroups_Archive;

CREATE TABLE Staging.BuyingGroups_Archive (
	[BuyingGroupID]		NVARCHAR(MAX)	NULL,
	[BuyingGroupName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[ValidFrom]			NVARCHAR(MAX)	NULL,
	[ValidTo]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.BuyingGroups_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.BuyingGroups_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.BuyingGroups_Archive (
	[BuyingGroupID], [BuyingGroupName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([BuyingGroupID], N'')),
	ISNULL([BuyingGroupName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.BuyingGroups_Archive;
DROP TABLE Staging.BuyingGroups_Archive;
GO

-- 15. Sales.CustomerCategories (needs: People) --
-----------------------------------------------------
IF OBJECT_ID('Staging.CustomerCategories', 'U') IS NOT NULL
	DROP TABLE Staging.CustomerCategories;

CREATE TABLE Staging.CustomerCategories (
	[CustomerCategoryID]	NVARCHAR(MAX)	NULL,
	[CustomerCategoryName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.CustomerCategories
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.CustomerCategories.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.CustomerCategories (
	[CustomerCategoryID], [CustomerCategoryName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CustomerCategoryID], N'')),
	ISNULL([CustomerCategoryName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.CustomerCategories;
DROP TABLE Staging.CustomerCategories;
GO

-- 16. Sales.CustomerCategories_Archive --
-------------------------------------------
IF OBJECT_ID('Staging.CustomerCategories_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.CustomerCategories_Archive;

CREATE TABLE Staging.CustomerCategories_Archive (
	[CustomerCategoryID]	NVARCHAR(MAX)	NULL,
	[CustomerCategoryName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.CustomerCategories_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.CustomerCategories_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.CustomerCategories_Archive (
	[CustomerCategoryID], [CustomerCategoryName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CustomerCategoryID], N'')),
	ISNULL([CustomerCategoryName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.CustomerCategories_Archive;
DROP TABLE Staging.CustomerCategories_Archive;
GO

-- 17. Sales.Customers_Archive --
-----------------------------------
IF OBJECT_ID('Staging.Customers_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.Customers_Archive;

CREATE TABLE Staging.Customers_Archive (
	[CustomerID]					NVARCHAR(MAX)	NULL,
	[CustomerName]					NVARCHAR(MAX)	NULL,
	[BillToCustomerID]				NVARCHAR(MAX)	NULL,
	[CustomerCategoryID]			NVARCHAR(MAX)	NULL,
	[BuyingGroupID]					NVARCHAR(MAX)	NULL,
	[PrimaryContactPersonID]		NVARCHAR(MAX)	NULL,
	[AlternateContactPersonID]		NVARCHAR(MAX)	NULL,
	[DeliveryMethodID]				NVARCHAR(MAX)	NULL,
	[DeliveryCityID]				NVARCHAR(MAX)	NULL,
	[PostalCityID]					NVARCHAR(MAX)	NULL,
	[CreditLimit]					NVARCHAR(MAX)	NULL,
	[AccountOpenedDate]				NVARCHAR(MAX)	NULL,
	[StandardDiscountPercentage]	NVARCHAR(MAX)	NULL,
	[IsStatementSent]				NVARCHAR(MAX)	NULL,
	[IsOnCreditHold]				NVARCHAR(MAX)	NULL,
	[PaymentDays]					NVARCHAR(MAX)	NULL,
	[PhoneNumber]					NVARCHAR(MAX)	NULL,
	[FaxNumber]						NVARCHAR(MAX)	NULL,
	[DeliveryRun]					NVARCHAR(MAX)	NULL,
	[RunPosition]					NVARCHAR(MAX)	NULL,
	[WebsiteURL]					NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine1]			NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine2]			NVARCHAR(MAX)	NULL,
	[DeliveryPostalCode]			NVARCHAR(MAX)	NULL,
	[DeliveryLocation]				NVARCHAR(MAX)	NULL,
	[PostalAddressLine1]			NVARCHAR(MAX)	NULL,
	[PostalAddressLine2]			NVARCHAR(MAX)	NULL,
	[PostalPostalCode]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]					NVARCHAR(MAX)	NULL,
	[ValidFrom]						NVARCHAR(MAX)	NULL,
	[ValidTo]						NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Customers_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.Customers_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.Customers_Archive (
	[CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID],
	[PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID],
	[PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage],
	[IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber],
	[DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2],
	[DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2],
	[PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CustomerID], N'')),
	ISNULL([CustomerName], N''),
	CONVERT(INT,	NULLIF([BillToCustomerID], N'')),
	CONVERT(INT,	NULLIF([CustomerCategoryID], N'')),
	CONVERT(INT,	NULLIF([BuyingGroupID], N'')),
	CONVERT(INT,	NULLIF([PrimaryContactPersonID], N'')),
	CONVERT(INT,	NULLIF([AlternateContactPersonID], N'')),
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	CONVERT(INT,	NULLIF([DeliveryCityID], N'')),
	CONVERT(INT,	NULLIF([PostalCityID], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([CreditLimit], N'')),
	CONVERT(DATE,	NULLIF([AccountOpenedDate], N''), 23),
	CONVERT(DECIMAL(18,3),	NULLIF([StandardDiscountPercentage], N'')),
	CONVERT(BIT,	NULLIF([IsStatementSent], N'')),
	CONVERT(BIT,	NULLIF([IsOnCreditHold], N'')),
	CONVERT(INT,	NULLIF([PaymentDays], N'')),
	ISNULL([PhoneNumber], N''),
	ISNULL([FaxNumber], N''),
	NULLIF([DeliveryRun], N''),
	NULLIF([RunPosition], N''),
	ISNULL([WebsiteURL], N''),
	ISNULL([DeliveryAddressLine1], N''),
	NULLIF([DeliveryAddressLine2], N''),
	ISNULL([DeliveryPostalCode], N''),
	CASE WHEN NULLIF([DeliveryLocation], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([DeliveryLocation], 4326)
	END,
	ISNULL([PostalAddressLine1], N''),
	NULLIF([PostalAddressLine2], N''),
	ISNULL([PostalPostalCode], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Customers_Archive;
DROP TABLE Staging.Customers_Archive;
GO

-- 18. Warehouse.ColdRoomTemperatures -- no FKs, can load any time --
------------------------------------------------------------------------
IF OBJECT_ID('Staging.ColdRoomTemperatures', 'U') IS NOT NULL
	DROP TABLE Staging.ColdRoomTemperatures;

CREATE TABLE Staging.ColdRoomTemperatures (
	[ColdRoomTemperatureID]	NVARCHAR(MAX)	NULL,
	[ColdRoomSensorNumber]	NVARCHAR(MAX)	NULL,
	[RecordedWhen]			NVARCHAR(MAX)	NULL,
	[Temperature]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.ColdRoomTemperatures
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.ColdRoomTemperatures.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.ColdRoomTemperatures (
	[ColdRoomTemperatureID], [ColdRoomSensorNumber], [RecordedWhen],
	[Temperature], [ValidFrom], [ValidTo]
)
SELECT
	CONVERT(BIGINT,	NULLIF([ColdRoomTemperatureID], N'')),
	CONVERT(INT,	NULLIF([ColdRoomSensorNumber], N'')),
	CONVERT(DATETIME2(7),	NULLIF([RecordedWhen], N''), 121),
	CONVERT(DECIMAL(10,2),	NULLIF([Temperature], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.ColdRoomTemperatures;
DROP TABLE Staging.ColdRoomTemperatures;
GO

-- 19. Warehouse.Colors (needs: People) --
---------------------------------------------
IF OBJECT_ID('Staging.Colors', 'U') IS NOT NULL
	DROP TABLE Staging.Colors;

CREATE TABLE Staging.Colors (
	[ColorID]		NVARCHAR(MAX)	NULL,
	[ColorName]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]	NVARCHAR(MAX)	NULL,
	[ValidFrom]		NVARCHAR(MAX)	NULL,
	[ValidTo]		NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Colors
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.Colors.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.Colors (
	[ColorID], [ColorName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([ColorID], N'')),
	ISNULL([ColorName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Colors;
DROP TABLE Staging.Colors;
GO

-- 20. Warehouse.Colors_Archive --
-----------------------------------
IF OBJECT_ID('Staging.Colors_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.Colors_Archive;

CREATE TABLE Staging.Colors_Archive (
	[ColorID]		NVARCHAR(MAX)	NULL,
	[ColorName]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]	NVARCHAR(MAX)	NULL,
	[ValidFrom]		NVARCHAR(MAX)	NULL,
	[ValidTo]		NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Colors_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.Colors_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.Colors_Archive (
	[ColorID], [ColorName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([ColorID], N'')),
	ISNULL([ColorName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Colors_Archive;
DROP TABLE Staging.Colors_Archive;
GO

-- 21. Warehouse.PackageTypes (needs: People) --
---------------------------------------------------
IF OBJECT_ID('Staging.PackageTypes', 'U') IS NOT NULL
	DROP TABLE Staging.PackageTypes;

CREATE TABLE Staging.PackageTypes (
	[PackageTypeID]		NVARCHAR(MAX)	NULL,
	[PackageTypeName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[ValidFrom]			NVARCHAR(MAX)	NULL,
	[ValidTo]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.PackageTypes
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.PackageTypes.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.PackageTypes (
	[PackageTypeID], [PackageTypeName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([PackageTypeID], N'')),
	ISNULL([PackageTypeName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.PackageTypes;
DROP TABLE Staging.PackageTypes;
GO

-- 22. Warehouse.PackageTypes_Archive --
-----------------------------------------
IF OBJECT_ID('Staging.PackageTypes_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.PackageTypes_Archive;

CREATE TABLE Staging.PackageTypes_Archive (
	[PackageTypeID]		NVARCHAR(MAX)	NULL,
	[PackageTypeName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[ValidFrom]			NVARCHAR(MAX)	NULL,
	[ValidTo]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.PackageTypes_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.PackageTypes_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.PackageTypes_Archive (
	[PackageTypeID], [PackageTypeName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([PackageTypeID], N'')),
	ISNULL([PackageTypeName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.PackageTypes_Archive;
DROP TABLE Staging.PackageTypes_Archive;
GO

-- 23. Warehouse.StockGroups (needs: People) --
--------------------------------------------------
IF OBJECT_ID('Staging.StockGroups', 'U') IS NOT NULL
	DROP TABLE Staging.StockGroups;

CREATE TABLE Staging.StockGroups (
	[StockGroupID]		NVARCHAR(MAX)	NULL,
	[StockGroupName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[ValidFrom]			NVARCHAR(MAX)	NULL,
	[ValidTo]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StockGroups
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.StockGroups.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.StockGroups (
	[StockGroupID], [StockGroupName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([StockGroupID], N'')),
	ISNULL([StockGroupName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.StockGroups;
DROP TABLE Staging.StockGroups;
GO

-- 24. Warehouse.StockGroups_Archive --
-----------------------------------------
IF OBJECT_ID('Staging.StockGroups_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.StockGroups_Archive;

CREATE TABLE Staging.StockGroups_Archive (
	[StockGroupID]		NVARCHAR(MAX)	NULL,
	[StockGroupName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[ValidFrom]			NVARCHAR(MAX)	NULL,
	[ValidTo]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StockGroups_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.StockGroups_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.StockGroups_Archive (
	[StockGroupID], [StockGroupName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([StockGroupID], N'')),
	ISNULL([StockGroupName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.StockGroups_Archive;
DROP TABLE Staging.StockGroups_Archive;
GO

-- 25. Warehouse.StockItems_Archive --
---------------------------------------
IF OBJECT_ID('Staging.StockItems_Archive', 'U') IS NOT NULL
	DROP TABLE Staging.StockItems_Archive;

CREATE TABLE Staging.StockItems_Archive (
	[StockItemID]				NVARCHAR(MAX)	NULL,
	[StockItemName]				NVARCHAR(MAX)	NULL,
	[SupplierID]				NVARCHAR(MAX)	NULL,
	[ColorID]					NVARCHAR(MAX)	NULL,
	[UnitPackageID]				NVARCHAR(MAX)	NULL,
	[OuterPackageID]			NVARCHAR(MAX)	NULL,
	[Brand]						NVARCHAR(MAX)	NULL,
	[Size]						NVARCHAR(MAX)	NULL,
	[LeadTimeDays]				NVARCHAR(MAX)	NULL,
	[QuantityPerOuter]			NVARCHAR(MAX)	NULL,
	[IsChillerStock]			NVARCHAR(MAX)	NULL,
	[Barcode]					NVARCHAR(MAX)	NULL,
	[TaxRate]					NVARCHAR(MAX)	NULL,
	[UnitPrice]					NVARCHAR(MAX)	NULL,
	[RecommendedRetailPrice]	NVARCHAR(MAX)	NULL,
	[TypicalWeightPerUnit]		NVARCHAR(MAX)	NULL,
	[MarketingComments]			NVARCHAR(MAX)	NULL,
	[InternalComments]			NVARCHAR(MAX)	NULL,
	[Photo]						NVARCHAR(MAX)	NULL,
	[CustomFields]				NVARCHAR(MAX)	NULL,
	[Tags]						NVARCHAR(MAX)	NULL,
	[SearchDetails]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StockItems_Archive
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.StockItems_Archive.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.StockItems_Archive (
	[StockItemID], [StockItemName], [SupplierID], [ColorID], [UnitPackageID],
	[OuterPackageID], [Brand], [Size], [LeadTimeDays], [QuantityPerOuter],
	[IsChillerStock], [Barcode], [TaxRate], [UnitPrice], [RecommendedRetailPrice],
	[TypicalWeightPerUnit], [MarketingComments], [InternalComments], [Photo],
	[CustomFields], [Tags], [SearchDetails], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	ISNULL([StockItemName], N''),
	CONVERT(INT,	NULLIF([SupplierID], N'')),
	CONVERT(INT,	NULLIF([ColorID], N'')),
	CONVERT(INT,	NULLIF([UnitPackageID], N'')),
	CONVERT(INT,	NULLIF([OuterPackageID], N'')),
	NULLIF([Brand], N''),
	NULLIF([Size], N''),
	CONVERT(INT,	NULLIF([LeadTimeDays], N'')),
	CONVERT(INT,	NULLIF([QuantityPerOuter], N'')),
	CONVERT(BIT,	NULLIF([IsChillerStock], N'')),
	NULLIF([Barcode], N''),
	CONVERT(DECIMAL(18,3),	NULLIF([TaxRate], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([UnitPrice], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([RecommendedRetailPrice], N'')),
	CONVERT(DECIMAL(18,3),	NULLIF([TypicalWeightPerUnit], N'')),
	NULLIF([MarketingComments], N''),
	NULLIF([InternalComments], N''),
	CONVERT(VARBINARY(MAX),	NULLIF([Photo], N''), 1),
	NULLIF([CustomFields], N''),
	NULLIF([Tags], N''),
	ISNULL([SearchDetails], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.StockItems_Archive;
DROP TABLE Staging.StockItems_Archive;
GO

-- 26. Application.Countries (needs: People) --
-------------------------------------------------
IF OBJECT_ID('Staging.Countries', 'U') IS NOT NULL
	DROP TABLE Staging.Countries;

CREATE TABLE Staging.Countries (
	[CountryID]					NVARCHAR(MAX)	NULL,
	[CountryName]				NVARCHAR(MAX)	NULL,
	[FormalName]				NVARCHAR(MAX)	NULL,
	[IsoAlpha3Code]				NVARCHAR(MAX)	NULL,
	[IsoNumericCode]			NVARCHAR(MAX)	NULL,
	[CountryType]				NVARCHAR(MAX)	NULL,
	[LatestRecordedPopulation]	NVARCHAR(MAX)	NULL,
	[Continent]					NVARCHAR(MAX)	NULL,
	[Region]					NVARCHAR(MAX)	NULL,
	[Subregion]					NVARCHAR(MAX)	NULL,
	[Border]					NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Countries
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.Countries.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.Countries (
	[CountryID], [CountryName], [FormalName], [IsoAlpha3Code], [IsoNumericCode],
	[CountryType], [LatestRecordedPopulation], [Continent], [Region], [Subregion],
	[Border], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CountryID], N'')),
	ISNULL([CountryName], N''),
	ISNULL([FormalName], N''),
	NULLIF([IsoAlpha3Code], N''),
	CONVERT(INT,	NULLIF([IsoNumericCode], N'')),
	NULLIF([CountryType], N''),
	CONVERT(BIGINT,	NULLIF([LatestRecordedPopulation], N'')),
	ISNULL([Continent], N''),
	ISNULL([Region], N''),
	ISNULL([Subregion], N''),
	CASE WHEN NULLIF([Border], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([Border], 4326)
	END,
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Countries;
DROP TABLE Staging.Countries;
GO

-- 27. Application.DeliveryMethods (needs: People) --
-------------------------------------------------------
IF OBJECT_ID('Staging.DeliveryMethods', 'U') IS NOT NULL
	DROP TABLE Staging.DeliveryMethods;

CREATE TABLE Staging.DeliveryMethods (
	[DeliveryMethodID]		NVARCHAR(MAX)	NULL,
	[DeliveryMethodName]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.DeliveryMethods
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.DeliveryMethods.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.DeliveryMethods (
	[DeliveryMethodID], [DeliveryMethodName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	ISNULL([DeliveryMethodName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.DeliveryMethods;
DROP TABLE Staging.DeliveryMethods;
GO

-- 28. Application.PaymentMethods (needs: People) --
-------------------------------------------------------
IF OBJECT_ID('Staging.PaymentMethods', 'U') IS NOT NULL
	DROP TABLE Staging.PaymentMethods;

CREATE TABLE Staging.PaymentMethods (
	[PaymentMethodID]		NVARCHAR(MAX)	NULL,
	[PaymentMethodName]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[ValidFrom]				NVARCHAR(MAX)	NULL,
	[ValidTo]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.PaymentMethods
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.PaymentMethods.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.PaymentMethods (
	[PaymentMethodID], [PaymentMethodName], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([PaymentMethodID], N'')),
	ISNULL([PaymentMethodName], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.PaymentMethods;
DROP TABLE Staging.PaymentMethods;
GO

-- 29. Application.StateProvinces (needs: Countries) --
---------------------------------------------------------
IF OBJECT_ID('Staging.StateProvinces', 'U') IS NOT NULL
	DROP TABLE Staging.StateProvinces;

CREATE TABLE Staging.StateProvinces (
	[StateProvinceID]			NVARCHAR(MAX)	NULL,
	[StateProvinceCode]			NVARCHAR(MAX)	NULL,
	[StateProvinceName]			NVARCHAR(MAX)	NULL,
	[CountryID]					NVARCHAR(MAX)	NULL,
	[SalesTerritory]			NVARCHAR(MAX)	NULL,
	[Border]					NVARCHAR(MAX)	NULL,
	[LatestRecordedPopulation]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StateProvinces
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.StateProvinces.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.StateProvinces (
	[StateProvinceID], [StateProvinceCode], [StateProvinceName], [CountryID],
	[SalesTerritory], [Border], [LatestRecordedPopulation], [LastEditedBy],
	[ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([StateProvinceID], N'')),
	ISNULL([StateProvinceCode], N''),
	ISNULL([StateProvinceName], N''),
	CONVERT(INT,	NULLIF([CountryID], N'')),
	ISNULL([SalesTerritory], N''),
	CASE WHEN NULLIF([Border], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([Border], 4326)
	END,
	CONVERT(BIGINT,	NULLIF([LatestRecordedPopulation], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.StateProvinces;
DROP TABLE Staging.StateProvinces;
GO

-- 30. Application.Cities (needs: StateProvinces) --
------------------------------------------------------
IF OBJECT_ID('Staging.Cities', 'U') IS NOT NULL
	DROP TABLE Staging.Cities;

CREATE TABLE Staging.Cities (
	[CityID]					NVARCHAR(MAX)	NULL,
	[CityName]					NVARCHAR(MAX)	NULL,
	[StateProvinceID]			NVARCHAR(MAX)	NULL,
	[Location]					NVARCHAR(MAX)	NULL,
	[LatestRecordedPopulation]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Cities
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.Cities.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.Cities (
	[CityID], [CityName], [StateProvinceID], [Location],
	[LatestRecordedPopulation], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CityID], N'')),
	ISNULL([CityName], N''),
	CONVERT(INT,	NULLIF([StateProvinceID], N'')),
	CASE WHEN NULLIF([Location], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([Location], 4326)
	END,
	CONVERT(BIGINT,	NULLIF([LatestRecordedPopulation], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Cities;
DROP TABLE Staging.Cities;
GO

-- 31. Application.SystemParameters (needs: Cities) -- single-row config table
----------------------------------------------------------------------------------
IF OBJECT_ID('Staging.SystemParameters', 'U') IS NOT NULL
	DROP TABLE Staging.SystemParameters;

CREATE TABLE Staging.SystemParameters (
	[SystemParameterID]		NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine1]	NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine2]	NVARCHAR(MAX)	NULL,
	[DeliveryCityID]		NVARCHAR(MAX)	NULL,
	[DeliveryPostalCode]	NVARCHAR(MAX)	NULL,
	[DeliveryLocation]		NVARCHAR(MAX)	NULL,
	[PostalAddressLine1]	NVARCHAR(MAX)	NULL,
	[PostalAddressLine2]	NVARCHAR(MAX)	NULL,
	[PostalCityID]			NVARCHAR(MAX)	NULL,
	[PostalPostalCode]		NVARCHAR(MAX)	NULL,
	[ApplicationSettings]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[LastEditedWhen]		NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.SystemParameters
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Application.SystemParameters.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Application.SystemParameters (
	[SystemParameterID], [DeliveryAddressLine1], [DeliveryAddressLine2],
	[DeliveryCityID], [DeliveryPostalCode], [DeliveryLocation],
	[PostalAddressLine1], [PostalAddressLine2], [PostalCityID],
	[PostalPostalCode], [ApplicationSettings], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([SystemParameterID], N'')),
	ISNULL([DeliveryAddressLine1], N''),
	NULLIF([DeliveryAddressLine2], N''),
	CONVERT(INT,	NULLIF([DeliveryCityID], N'')),
	ISNULL([DeliveryPostalCode], N''),
	geography::STGeomFromText([DeliveryLocation], 4326),
	ISNULL([PostalAddressLine1], N''),
	NULLIF([PostalAddressLine2], N''),
	CONVERT(INT,	NULLIF([PostalCityID], N'')),
	ISNULL([PostalPostalCode], N''),
	ISNULL([ApplicationSettings], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.SystemParameters;
DROP TABLE Staging.SystemParameters;
GO

-- 32. Purchasing.Suppliers (needs: SupplierCategories, People, DeliveryMethods, Cities)
--     NOTE: 4 rows have empty DeliveryAddressLine1 (NOT NULL) -> ISNULL loads '' (see README)
------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.Suppliers', 'U') IS NOT NULL
	DROP TABLE Staging.Suppliers;

CREATE TABLE Staging.Suppliers (
	[SupplierID]				NVARCHAR(MAX)	NULL,
	[SupplierName]				NVARCHAR(MAX)	NULL,
	[SupplierCategoryID]		NVARCHAR(MAX)	NULL,
	[PrimaryContactPersonID]	NVARCHAR(MAX)	NULL,
	[AlternateContactPersonID]	NVARCHAR(MAX)	NULL,
	[DeliveryMethodID]			NVARCHAR(MAX)	NULL,
	[DeliveryCityID]			NVARCHAR(MAX)	NULL,
	[PostalCityID]				NVARCHAR(MAX)	NULL,
	[SupplierReference]			NVARCHAR(MAX)	NULL,
	[BankAccountName]			NVARCHAR(MAX)	NULL,
	[BankAccountBranch]			NVARCHAR(MAX)	NULL,
	[BankAccountCode]			NVARCHAR(MAX)	NULL,
	[BankAccountNumber]			NVARCHAR(MAX)	NULL,
	[BankInternationalCode]		NVARCHAR(MAX)	NULL,
	[PaymentDays]				NVARCHAR(MAX)	NULL,
	[InternalComments]			NVARCHAR(MAX)	NULL,
	[PhoneNumber]				NVARCHAR(MAX)	NULL,
	[FaxNumber]					NVARCHAR(MAX)	NULL,
	[WebsiteURL]				NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine1]		NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine2]		NVARCHAR(MAX)	NULL,
	[DeliveryPostalCode]		NVARCHAR(MAX)	NULL,
	[DeliveryLocation]			NVARCHAR(MAX)	NULL,
	[PostalAddressLine1]		NVARCHAR(MAX)	NULL,
	[PostalAddressLine2]		NVARCHAR(MAX)	NULL,
	[PostalPostalCode]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Suppliers
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.Suppliers.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.Suppliers (
	[SupplierID], [SupplierName], [SupplierCategoryID], [PrimaryContactPersonID],
	[AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID], [PostalCityID],
	[SupplierReference], [BankAccountName], [BankAccountBranch], [BankAccountCode],
	[BankAccountNumber], [BankInternationalCode], [PaymentDays], [InternalComments],
	[PhoneNumber], [FaxNumber], [WebsiteURL], [DeliveryAddressLine1],
	[DeliveryAddressLine2], [DeliveryPostalCode], [DeliveryLocation],
	[PostalAddressLine1], [PostalAddressLine2], [PostalPostalCode],
	[LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([SupplierID], N'')),
	ISNULL([SupplierName], N''),
	CONVERT(INT,	NULLIF([SupplierCategoryID], N'')),
	CONVERT(INT,	NULLIF([PrimaryContactPersonID], N'')),
	CONVERT(INT,	NULLIF([AlternateContactPersonID], N'')),
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	CONVERT(INT,	NULLIF([DeliveryCityID], N'')),
	CONVERT(INT,	NULLIF([PostalCityID], N'')),
	NULLIF([SupplierReference], N''),
	NULLIF([BankAccountName], N''),
	NULLIF([BankAccountBranch], N''),
	NULLIF([BankAccountCode], N''),
	NULLIF([BankAccountNumber], N''),
	NULLIF([BankInternationalCode], N''),
	CONVERT(INT,	NULLIF([PaymentDays], N'')),
	NULLIF([InternalComments], N''),
	ISNULL([PhoneNumber], N''),
	ISNULL([FaxNumber], N''),
	ISNULL([WebsiteURL], N''),
	ISNULL([DeliveryAddressLine1], N''),		-- the 4-empty-rows fix
	NULLIF([DeliveryAddressLine2], N''),
	ISNULL([DeliveryPostalCode], N''),
	CASE WHEN NULLIF([DeliveryLocation], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([DeliveryLocation], 4326)
	END,
	ISNULL([PostalAddressLine1], N''),
	NULLIF([PostalAddressLine2], N''),
	ISNULL([PostalPostalCode], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Suppliers;
DROP TABLE Staging.Suppliers;
GO

-- 33. Sales.Customers (needs: CustomerCategories, BuyingGroups, People, DeliveryMethods, Cities) --
-----------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.Customers', 'U') IS NOT NULL
	DROP TABLE Staging.Customers;

CREATE TABLE Staging.Customers (
	[CustomerID]					NVARCHAR(MAX)	NULL,
	[CustomerName]					NVARCHAR(MAX)	NULL,
	[BillToCustomerID]				NVARCHAR(MAX)	NULL,
	[CustomerCategoryID]			NVARCHAR(MAX)	NULL,
	[BuyingGroupID]					NVARCHAR(MAX)	NULL,
	[PrimaryContactPersonID]		NVARCHAR(MAX)	NULL,
	[AlternateContactPersonID]		NVARCHAR(MAX)	NULL,
	[DeliveryMethodID]				NVARCHAR(MAX)	NULL,
	[DeliveryCityID]				NVARCHAR(MAX)	NULL,
	[PostalCityID]					NVARCHAR(MAX)	NULL,
	[CreditLimit]					NVARCHAR(MAX)	NULL,
	[AccountOpenedDate]				NVARCHAR(MAX)	NULL,
	[StandardDiscountPercentage]	NVARCHAR(MAX)	NULL,
	[IsStatementSent]				NVARCHAR(MAX)	NULL,
	[IsOnCreditHold]				NVARCHAR(MAX)	NULL,
	[PaymentDays]					NVARCHAR(MAX)	NULL,
	[PhoneNumber]					NVARCHAR(MAX)	NULL,
	[FaxNumber]						NVARCHAR(MAX)	NULL,
	[DeliveryRun]					NVARCHAR(MAX)	NULL,
	[RunPosition]					NVARCHAR(MAX)	NULL,
	[WebsiteURL]					NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine1]			NVARCHAR(MAX)	NULL,
	[DeliveryAddressLine2]			NVARCHAR(MAX)	NULL,
	[DeliveryPostalCode]			NVARCHAR(MAX)	NULL,
	[DeliveryLocation]				NVARCHAR(MAX)	NULL,
	[PostalAddressLine1]			NVARCHAR(MAX)	NULL,
	[PostalAddressLine2]			NVARCHAR(MAX)	NULL,
	[PostalPostalCode]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]					NVARCHAR(MAX)	NULL,
	[ValidFrom]						NVARCHAR(MAX)	NULL,
	[ValidTo]						NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Customers
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.Customers.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.Customers (
	[CustomerID], [CustomerName], [BillToCustomerID], [CustomerCategoryID], [BuyingGroupID],
	[PrimaryContactPersonID], [AlternateContactPersonID], [DeliveryMethodID], [DeliveryCityID],
	[PostalCityID], [CreditLimit], [AccountOpenedDate], [StandardDiscountPercentage],
	[IsStatementSent], [IsOnCreditHold], [PaymentDays], [PhoneNumber], [FaxNumber],
	[DeliveryRun], [RunPosition], [WebsiteURL], [DeliveryAddressLine1], [DeliveryAddressLine2],
	[DeliveryPostalCode], [DeliveryLocation], [PostalAddressLine1], [PostalAddressLine2],
	[PostalPostalCode], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([CustomerID], N'')),
	ISNULL([CustomerName], N''),
	CONVERT(INT,	NULLIF([BillToCustomerID], N'')),
	CONVERT(INT,	NULLIF([CustomerCategoryID], N'')),
	CONVERT(INT,	NULLIF([BuyingGroupID], N'')),
	CONVERT(INT,	NULLIF([PrimaryContactPersonID], N'')),
	CONVERT(INT,	NULLIF([AlternateContactPersonID], N'')),
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	CONVERT(INT,	NULLIF([DeliveryCityID], N'')),
	CONVERT(INT,	NULLIF([PostalCityID], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([CreditLimit], N'')),
	CONVERT(DATE,	NULLIF([AccountOpenedDate], N''), 23),
	CONVERT(DECIMAL(18,3),	NULLIF([StandardDiscountPercentage], N'')),
	CONVERT(BIT,	NULLIF([IsStatementSent], N'')),
	CONVERT(BIT,	NULLIF([IsOnCreditHold], N'')),
	CONVERT(INT,	NULLIF([PaymentDays], N'')),
	ISNULL([PhoneNumber], N''),
	ISNULL([FaxNumber], N''),
	NULLIF([DeliveryRun], N''),
	NULLIF([RunPosition], N''),
	ISNULL([WebsiteURL], N''),
	ISNULL([DeliveryAddressLine1], N''),
	NULLIF([DeliveryAddressLine2], N''),
	ISNULL([DeliveryPostalCode], N''),
	CASE WHEN NULLIF([DeliveryLocation], N'') IS NULL
		 THEN NULL ELSE geography::STGeomFromText([DeliveryLocation], 4326)
	END,
	ISNULL([PostalAddressLine1], N''),
	NULLIF([PostalAddressLine2], N''),
	ISNULL([PostalPostalCode], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.Customers;
DROP TABLE Staging.Customers;
GO

-- 34. Sales.Orders (needs: Customers, People) --
---------------------------------------------------
IF OBJECT_ID('Staging.Orders', 'U') IS NOT NULL
	DROP TABLE Staging.Orders;

CREATE TABLE Staging.Orders (
	[OrderID]						NVARCHAR(MAX)	NULL,
	[CustomerID]					NVARCHAR(MAX)	NULL,
	[SalespersonPersonID]			NVARCHAR(MAX)	NULL,
	[PickedByPersonID]				NVARCHAR(MAX)	NULL,
	[ContactPersonID]				NVARCHAR(MAX)	NULL,
	[BackorderOrderID]				NVARCHAR(MAX)	NULL,
	[OrderDate]						NVARCHAR(MAX)	NULL,
	[ExpectedDeliveryDate]			NVARCHAR(MAX)	NULL,
	[CustomerPurchaseOrderNumber]	NVARCHAR(MAX)	NULL,
	[IsUndersupplyBackordered]		NVARCHAR(MAX)	NULL,
	[Comments]						NVARCHAR(MAX)	NULL,
	[DeliveryInstructions]			NVARCHAR(MAX)	NULL,
	[InternalComments]				NVARCHAR(MAX)	NULL,
	[PickingCompletedWhen]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]					NVARCHAR(MAX)	NULL,
	[LastEditedWhen]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Orders
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.Orders.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.Orders (
	[OrderID], [CustomerID], [SalespersonPersonID], [PickedByPersonID], [ContactPersonID],
	[BackorderOrderID], [OrderDate], [ExpectedDeliveryDate], [CustomerPurchaseOrderNumber],
	[IsUndersupplyBackordered], [Comments], [DeliveryInstructions], [InternalComments],
	[PickingCompletedWhen], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([OrderID], N'')),
	CONVERT(INT,	NULLIF([CustomerID], N'')),
	CONVERT(INT,	NULLIF([SalespersonPersonID], N'')),
	CONVERT(INT,	NULLIF([PickedByPersonID], N'')),
	CONVERT(INT,	NULLIF([ContactPersonID], N'')),
	CONVERT(INT,	NULLIF([BackorderOrderID], N'')),
	CONVERT(DATE,	NULLIF([OrderDate], N''), 23),
	CONVERT(DATE,	NULLIF([ExpectedDeliveryDate], N''), 23),
	NULLIF([CustomerPurchaseOrderNumber], N''),
	CONVERT(BIT,	NULLIF([IsUndersupplyBackordered], N'')),
	NULLIF([Comments], N''),
	NULLIF([DeliveryInstructions], N''),
	NULLIF([InternalComments], N''),
	CONVERT(DATETIME2(7),	NULLIF([PickingCompletedWhen], N''), 121),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.Orders;
DROP TABLE Staging.Orders;
GO

-- 35. Warehouse.StockItems (needs: Suppliers, Colors, PackageTypes, People) --
--     NOTE: Tags, SearchDetails are computed columns -> not in CSV, not loaded
---------------------------------------------------------------------------------
IF OBJECT_ID('Staging.StockItems', 'U') IS NOT NULL
	DROP TABLE Staging.StockItems;

CREATE TABLE Staging.StockItems (
	[StockItemID]				NVARCHAR(MAX)	NULL,
	[StockItemName]				NVARCHAR(MAX)	NULL,
	[SupplierID]				NVARCHAR(MAX)	NULL,
	[ColorID]					NVARCHAR(MAX)	NULL,
	[UnitPackageID]				NVARCHAR(MAX)	NULL,
	[OuterPackageID]			NVARCHAR(MAX)	NULL,
	[Brand]						NVARCHAR(MAX)	NULL,
	[Size]						NVARCHAR(MAX)	NULL,
	[LeadTimeDays]				NVARCHAR(MAX)	NULL,
	[QuantityPerOuter]			NVARCHAR(MAX)	NULL,
	[IsChillerStock]			NVARCHAR(MAX)	NULL,
	[Barcode]					NVARCHAR(MAX)	NULL,
	[TaxRate]					NVARCHAR(MAX)	NULL,
	[UnitPrice]					NVARCHAR(MAX)	NULL,
	[RecommendedRetailPrice]	NVARCHAR(MAX)	NULL,
	[TypicalWeightPerUnit]		NVARCHAR(MAX)	NULL,
	[MarketingComments]			NVARCHAR(MAX)	NULL,
	[InternalComments]			NVARCHAR(MAX)	NULL,
	[Photo]						NVARCHAR(MAX)	NULL,
	[CustomFields]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[ValidFrom]					NVARCHAR(MAX)	NULL,
	[ValidTo]					NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StockItems
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.StockItems.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.StockItems (
	[StockItemID], [StockItemName], [SupplierID], [ColorID], [UnitPackageID],
	[OuterPackageID], [Brand], [Size], [LeadTimeDays], [QuantityPerOuter],
	[IsChillerStock], [Barcode], [TaxRate], [UnitPrice], [RecommendedRetailPrice],
	[TypicalWeightPerUnit], [MarketingComments], [InternalComments], [Photo],
	[CustomFields], [LastEditedBy], [ValidFrom], [ValidTo])
SELECT
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	ISNULL([StockItemName], N''),
	CONVERT(INT,	NULLIF([SupplierID], N'')),
	CONVERT(INT,	NULLIF([ColorID], N'')),
	CONVERT(INT,	NULLIF([UnitPackageID], N'')),
	CONVERT(INT,	NULLIF([OuterPackageID], N'')),
	NULLIF([Brand], N''),
	NULLIF([Size], N''),
	CONVERT(INT,	NULLIF([LeadTimeDays], N'')),
	CONVERT(INT,	NULLIF([QuantityPerOuter], N'')),
	CONVERT(BIT,	NULLIF([IsChillerStock], N'')),
	NULLIF([Barcode], N''),
	CONVERT(DECIMAL(18,3),	NULLIF([TaxRate], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([UnitPrice], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([RecommendedRetailPrice], N'')),
	CONVERT(DECIMAL(18,3),	NULLIF([TypicalWeightPerUnit], N'')),
	NULLIF([MarketingComments], N''),
	NULLIF([InternalComments], N''),
	CONVERT(VARBINARY(MAX),	NULLIF([Photo], N''), 1),
	NULLIF([CustomFields], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([ValidFrom], N''), 121),
	CONVERT(DATETIME2(7),	NULLIF([ValidTo],   N''), 121)
FROM Staging.StockItems;
DROP TABLE Staging.StockItems;
GO

-- 36. Warehouse.StockItemStockGroups (needs: StockItems, StockGroups, People) --
----------------------------------------------------------------------------------
IF OBJECT_ID('Staging.StockItemStockGroups', 'U') IS NOT NULL
	DROP TABLE Staging.StockItemStockGroups;

CREATE TABLE Staging.StockItemStockGroups (
	[StockItemStockGroupID]	NVARCHAR(MAX)	NULL,
	[StockItemID]				NVARCHAR(MAX)	NULL,
	[StockGroupID]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[LastEditedWhen]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StockItemStockGroups
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.StockItemStockGroups.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.StockItemStockGroups (
	[StockItemStockGroupID], [StockItemID], [StockGroupID], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([StockItemStockGroupID], N'')),
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	CONVERT(INT,	NULLIF([StockGroupID], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.StockItemStockGroups;
DROP TABLE Staging.StockItemStockGroups;
GO

-- 37. Purchasing.PurchaseOrders (needs: Suppliers, DeliveryMethods, People) --
----------------------------------------------------------------------------------
IF OBJECT_ID('Staging.PurchaseOrders', 'U') IS NOT NULL
	DROP TABLE Staging.PurchaseOrders;

CREATE TABLE Staging.PurchaseOrders (
	[PurchaseOrderID]			NVARCHAR(MAX)	NULL,
	[SupplierID]				NVARCHAR(MAX)	NULL,
	[OrderDate]					NVARCHAR(MAX)	NULL,
	[DeliveryMethodID]			NVARCHAR(MAX)	NULL,
	[ContactPersonID]			NVARCHAR(MAX)	NULL,
	[ExpectedDeliveryDate]		NVARCHAR(MAX)	NULL,
	[SupplierReference]			NVARCHAR(MAX)	NULL,
	[IsOrderFinalized]			NVARCHAR(MAX)	NULL,
	[Comments]					NVARCHAR(MAX)	NULL,
	[InternalComments]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[LastEditedWhen]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.PurchaseOrders
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.PurchaseOrders.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.PurchaseOrders (
	[PurchaseOrderID], [SupplierID], [OrderDate], [DeliveryMethodID],
	[ContactPersonID], [ExpectedDeliveryDate], [SupplierReference],
	[IsOrderFinalized], [Comments], [InternalComments], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([PurchaseOrderID], N'')),
	CONVERT(INT,	NULLIF([SupplierID], N'')),
	CONVERT(DATE,	NULLIF([OrderDate], N''), 23),
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	CONVERT(INT,	NULLIF([ContactPersonID], N'')),
	CONVERT(DATE,	NULLIF([ExpectedDeliveryDate], N''), 23),
	NULLIF([SupplierReference], N''),
	CONVERT(BIT,	NULLIF([IsOrderFinalized], N'')),
	NULLIF([Comments], N''),
	NULLIF([InternalComments], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.PurchaseOrders;
DROP TABLE Staging.PurchaseOrders;
GO

-- 38. Purchasing.SupplierTransactions (needs: Suppliers, TransactionTypes, PurchaseOrders, PaymentMethods, People)
--     NOTE: IsFinalized is a computed column -> not in CSV, not loaded
------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.SupplierTransactions', 'U') IS NOT NULL
	DROP TABLE Staging.SupplierTransactions;

CREATE TABLE Staging.SupplierTransactions (
	[SupplierTransactionID]		NVARCHAR(MAX)	NULL,
	[SupplierID]				NVARCHAR(MAX)	NULL,
	[TransactionTypeID]			NVARCHAR(MAX)	NULL,
	[PurchaseOrderID]			NVARCHAR(MAX)	NULL,
	[PaymentMethodID]			NVARCHAR(MAX)	NULL,
	[SupplierInvoiceNumber]		NVARCHAR(MAX)	NULL,
	[TransactionDate]			NVARCHAR(MAX)	NULL,
	[AmountExcludingTax]		NVARCHAR(MAX)	NULL,
	[TaxAmount]					NVARCHAR(MAX)	NULL,
	[TransactionAmount]			NVARCHAR(MAX)	NULL,
	[OutstandingBalance]		NVARCHAR(MAX)	NULL,
	[FinalizationDate]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[LastEditedWhen]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.SupplierTransactions
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.SupplierTransactions.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.SupplierTransactions (
	[SupplierTransactionID], [SupplierID], [TransactionTypeID], [PurchaseOrderID],
	[PaymentMethodID], [SupplierInvoiceNumber], [TransactionDate], [AmountExcludingTax],
	[TaxAmount], [TransactionAmount], [OutstandingBalance], [FinalizationDate],
	[LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([SupplierTransactionID], N'')),
	CONVERT(INT,	NULLIF([SupplierID], N'')),
	CONVERT(INT,	NULLIF([TransactionTypeID], N'')),
	CONVERT(INT,	NULLIF([PurchaseOrderID], N'')),
	CONVERT(INT,	NULLIF([PaymentMethodID], N'')),
	NULLIF([SupplierInvoiceNumber], N''),
	CONVERT(DATE,	NULLIF([TransactionDate], N''), 23),
	CONVERT(DECIMAL(18,2),	NULLIF([AmountExcludingTax], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([TaxAmount], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([TransactionAmount], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([OutstandingBalance], N'')),
	CONVERT(DATE,	NULLIF([FinalizationDate], N''), 23),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.SupplierTransactions;
DROP TABLE Staging.SupplierTransactions;
GO

-- 39. Sales.Invoices (needs: Customers, Orders, DeliveryMethods, People) --
--     NOTE: ConfirmedDeliveryTime, ConfirmedReceivedBy are computed -> not loaded
-------------------------------------------------------------------------------
IF OBJECT_ID('Staging.Invoices', 'U') IS NOT NULL
	DROP TABLE Staging.Invoices;

CREATE TABLE Staging.Invoices (
	[InvoiceID]						NVARCHAR(MAX)	NULL,
	[CustomerID]					NVARCHAR(MAX)	NULL,
	[BillToCustomerID]				NVARCHAR(MAX)	NULL,
	[OrderID]						NVARCHAR(MAX)	NULL,
	[DeliveryMethodID]				NVARCHAR(MAX)	NULL,
	[ContactPersonID]				NVARCHAR(MAX)	NULL,
	[AccountsPersonID]				NVARCHAR(MAX)	NULL,
	[SalespersonPersonID]			NVARCHAR(MAX)	NULL,
	[PackedByPersonID]				NVARCHAR(MAX)	NULL,
	[InvoiceDate]					NVARCHAR(MAX)	NULL,
	[CustomerPurchaseOrderNumber]	NVARCHAR(MAX)	NULL,
	[IsCreditNote]					NVARCHAR(MAX)	NULL,
	[CreditNoteReason]				NVARCHAR(MAX)	NULL,
	[Comments]						NVARCHAR(MAX)	NULL,
	[DeliveryInstructions]			NVARCHAR(MAX)	NULL,
	[InternalComments]				NVARCHAR(MAX)	NULL,
	[TotalDryItems]					NVARCHAR(MAX)	NULL,
	[TotalChillerItems]			NVARCHAR(MAX)	NULL,
	[DeliveryRun]					NVARCHAR(MAX)	NULL,
	[RunPosition]					NVARCHAR(MAX)	NULL,
	[ReturnedDeliveryData]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]					NVARCHAR(MAX)	NULL,
	[LastEditedWhen]				NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.Invoices
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.Invoices.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.Invoices (
	[InvoiceID], [CustomerID], [BillToCustomerID], [OrderID], [DeliveryMethodID],
	[ContactPersonID], [AccountsPersonID], [SalespersonPersonID], [PackedByPersonID],
	[InvoiceDate], [CustomerPurchaseOrderNumber], [IsCreditNote], [CreditNoteReason],
	[Comments], [DeliveryInstructions], [InternalComments], [TotalDryItems],
	[TotalChillerItems], [DeliveryRun], [RunPosition], [ReturnedDeliveryData],
	[LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([InvoiceID], N'')),
	CONVERT(INT,	NULLIF([CustomerID], N'')),
	CONVERT(INT,	NULLIF([BillToCustomerID], N'')),
	CONVERT(INT,	NULLIF([OrderID], N'')),
	CONVERT(INT,	NULLIF([DeliveryMethodID], N'')),
	CONVERT(INT,	NULLIF([ContactPersonID], N'')),
	CONVERT(INT,	NULLIF([AccountsPersonID], N'')),
	CONVERT(INT,	NULLIF([SalespersonPersonID], N'')),
	CONVERT(INT,	NULLIF([PackedByPersonID], N'')),
	CONVERT(DATE,	NULLIF([InvoiceDate], N''), 23),
	NULLIF([CustomerPurchaseOrderNumber], N''),
	CONVERT(BIT,	NULLIF([IsCreditNote], N'')),
	NULLIF([CreditNoteReason], N''),
	NULLIF([Comments], N''),
	NULLIF([DeliveryInstructions], N''),
	NULLIF([InternalComments], N''),
	CONVERT(INT,	NULLIF([TotalDryItems], N'')),
	CONVERT(INT,	NULLIF([TotalChillerItems], N'')),
	NULLIF([DeliveryRun], N''),
	NULLIF([RunPosition], N''),
	NULLIF([ReturnedDeliveryData], N''),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.Invoices;
DROP TABLE Staging.Invoices;
GO

-- 40. Sales.OrderLines (needs: Orders, StockItems, PackageTypes) --
------------------------------------------------------------------------
IF OBJECT_ID('Staging.OrderLines', 'U') IS NOT NULL
	DROP TABLE Staging.OrderLines;

CREATE TABLE Staging.OrderLines (
	[OrderLineID]			NVARCHAR(MAX)	NULL,
	[OrderID]				NVARCHAR(MAX)	NULL,
	[StockItemID]			NVARCHAR(MAX)	NULL,
	[Description]			NVARCHAR(MAX)	NULL,
	[PackageTypeID]			NVARCHAR(MAX)	NULL,
	[Quantity]				NVARCHAR(MAX)	NULL,
	[UnitPrice]				NVARCHAR(MAX)	NULL,
	[TaxRate]				NVARCHAR(MAX)	NULL,
	[PickedQuantity]		NVARCHAR(MAX)	NULL,
	[PickingCompletedWhen]	NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[LastEditedWhen]		NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.OrderLines
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.OrderLines.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.OrderLines (
	[OrderLineID], [OrderID], [StockItemID], [Description], [PackageTypeID],
	[Quantity], [UnitPrice], [TaxRate], [PickedQuantity], [PickingCompletedWhen],
	[LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([OrderLineID], N'')),
	CONVERT(INT,	NULLIF([OrderID], N'')),
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	ISNULL([Description], N''),
	CONVERT(INT,	NULLIF([PackageTypeID], N'')),
	CONVERT(INT,	NULLIF([Quantity], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([UnitPrice], N'')),
	CONVERT(DECIMAL(18,3),	NULLIF([TaxRate], N'')),
	CONVERT(INT,	NULLIF([PickedQuantity], N'')),
	CONVERT(DATETIME2(7),	NULLIF([PickingCompletedWhen], N''), 121),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.OrderLines;
DROP TABLE Staging.OrderLines;
GO

-- 41. Sales.SpecialDeals (needs: StockItems, Customers, BuyingGroups, CustomerCategories, StockGroups, People) --
--------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.SpecialDeals', 'U') IS NOT NULL
	DROP TABLE Staging.SpecialDeals;

CREATE TABLE Staging.SpecialDeals (
	[SpecialDealID]			NVARCHAR(MAX)	NULL,
	[StockItemID]			NVARCHAR(MAX)	NULL,
	[CustomerID]			NVARCHAR(MAX)	NULL,
	[BuyingGroupID]			NVARCHAR(MAX)	NULL,
	[CustomerCategoryID]	NVARCHAR(MAX)	NULL,
	[StockGroupID]			NVARCHAR(MAX)	NULL,
	[DealDescription]		NVARCHAR(MAX)	NULL,
	[StartDate]				NVARCHAR(MAX)	NULL,
	[EndDate]				NVARCHAR(MAX)	NULL,
	[DiscountAmount]		NVARCHAR(MAX)	NULL,
	[DiscountPercentage]	NVARCHAR(MAX)	NULL,
	[UnitPrice]				NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[LastEditedWhen]		NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.SpecialDeals
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.SpecialDeals.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.SpecialDeals (
	[SpecialDealID], [StockItemID], [CustomerID], [BuyingGroupID], [CustomerCategoryID],
	[StockGroupID], [DealDescription], [StartDate], [EndDate], [DiscountAmount],
	[DiscountPercentage], [UnitPrice], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([SpecialDealID], N'')),
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	CONVERT(INT,	NULLIF([CustomerID], N'')),
	CONVERT(INT,	NULLIF([BuyingGroupID], N'')),
	CONVERT(INT,	NULLIF([CustomerCategoryID], N'')),
	CONVERT(INT,	NULLIF([StockGroupID], N'')),
	ISNULL([DealDescription], N''),
	CONVERT(DATE,	NULLIF([StartDate], N''), 23),
	CONVERT(DATE,	NULLIF([EndDate], N''), 23),
	CONVERT(DECIMAL(18,2),	NULLIF([DiscountAmount], N'')),
	CONVERT(DECIMAL(18,3),	NULLIF([DiscountPercentage], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([UnitPrice], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.SpecialDeals;
DROP TABLE Staging.SpecialDeals;
GO

-- 42. Warehouse.StockItemHoldings (needs: StockItems, People) --
------------------------------------------------------------------
IF OBJECT_ID('Staging.StockItemHoldings', 'U') IS NOT NULL
	DROP TABLE Staging.StockItemHoldings;

CREATE TABLE Staging.StockItemHoldings (
	[StockItemID]				NVARCHAR(MAX)	NULL,
	[QuantityOnHand]			NVARCHAR(MAX)	NULL,
	[BinLocation]				NVARCHAR(MAX)	NULL,
	[LastStocktakeQuantity]		NVARCHAR(MAX)	NULL,
	[LastCostPrice]				NVARCHAR(MAX)	NULL,
	[ReorderLevel]				NVARCHAR(MAX)	NULL,
	[TargetStockLevel]			NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[LastEditedWhen]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.StockItemHoldings
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Warehouse.StockItemHoldings.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Warehouse.StockItemHoldings (
	[StockItemID], [QuantityOnHand], [BinLocation], [LastStocktakeQuantity],
	[LastCostPrice], [ReorderLevel], [TargetStockLevel], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	CONVERT(INT,	NULLIF([QuantityOnHand], N'')),
	ISNULL([BinLocation], N''),
	CONVERT(INT,	NULLIF([LastStocktakeQuantity], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([LastCostPrice], N'')),
	CONVERT(INT,	NULLIF([ReorderLevel], N'')),
	CONVERT(INT,	NULLIF([TargetStockLevel], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.StockItemHoldings;
DROP TABLE Staging.StockItemHoldings;
GO

-- 43. Purchasing.PurchaseOrderLines (needs: PurchaseOrders, StockItems, PackageTypes, People) --
----------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.PurchaseOrderLines', 'U') IS NOT NULL
	DROP TABLE Staging.PurchaseOrderLines;

CREATE TABLE Staging.PurchaseOrderLines (
	[PurchaseOrderLineID]		NVARCHAR(MAX)	NULL,
	[PurchaseOrderID]			NVARCHAR(MAX)	NULL,
	[StockItemID]				NVARCHAR(MAX)	NULL,
	[OrderedOuters]				NVARCHAR(MAX)	NULL,
	[Description]				NVARCHAR(MAX)	NULL,
	[ReceivedOuters]			NVARCHAR(MAX)	NULL,
	[PackageTypeID]				NVARCHAR(MAX)	NULL,
	[ExpectedUnitPricePerOuter]	NVARCHAR(MAX)	NULL,
	[LastReceiptDate]			NVARCHAR(MAX)	NULL,
	[IsOrderLineFinalized]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]				NVARCHAR(MAX)	NULL,
	[LastEditedWhen]			NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.PurchaseOrderLines
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Purchasing.PurchaseOrderLines.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Purchasing.PurchaseOrderLines (
	[PurchaseOrderLineID], [PurchaseOrderID], [StockItemID], [OrderedOuters],
	[Description], [ReceivedOuters], [PackageTypeID], [ExpectedUnitPricePerOuter],
	[LastReceiptDate], [IsOrderLineFinalized], [LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([PurchaseOrderLineID], N'')),
	CONVERT(INT,	NULLIF([PurchaseOrderID], N'')),
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	CONVERT(INT,	NULLIF([OrderedOuters], N'')),
	ISNULL([Description], N''),
	CONVERT(INT,	NULLIF([ReceivedOuters], N'')),
	CONVERT(INT,	NULLIF([PackageTypeID], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([ExpectedUnitPricePerOuter], N'')),
	CONVERT(DATE,	NULLIF([LastReceiptDate], N''), 23),
	CONVERT(BIT,	NULLIF([IsOrderLineFinalized], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.PurchaseOrderLines;
DROP TABLE Staging.PurchaseOrderLines;
GO

-- 44. Sales.CustomerTransactions (needs: Customers, TransactionTypes, Invoices, PaymentMethods) --
--     NOTE: IsFinalized is a computed column -> not in CSV, not loaded
-----------------------------------------------------------------------------------------------------
IF OBJECT_ID('Staging.CustomerTransactions', 'U') IS NOT NULL
	DROP TABLE Staging.CustomerTransactions;

CREATE TABLE Staging.CustomerTransactions (
	[CustomerTransactionID]	NVARCHAR(MAX)	NULL,
	[CustomerID]			NVARCHAR(MAX)	NULL,
	[TransactionTypeID]		NVARCHAR(MAX)	NULL,
	[InvoiceID]				NVARCHAR(MAX)	NULL,
	[PaymentMethodID]		NVARCHAR(MAX)	NULL,
	[TransactionDate]		NVARCHAR(MAX)	NULL,
	[AmountExcludingTax]	NVARCHAR(MAX)	NULL,
	[TaxAmount]				NVARCHAR(MAX)	NULL,
	[TransactionAmount]		NVARCHAR(MAX)	NULL,
	[OutstandingBalance]	NVARCHAR(MAX)	NULL,
	[FinalizationDate]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]			NVARCHAR(MAX)	NULL,
	[LastEditedWhen]		NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.CustomerTransactions
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.CustomerTransactions.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.CustomerTransactions (
	[CustomerTransactionID], [CustomerID], [TransactionTypeID], [InvoiceID],
	[PaymentMethodID], [TransactionDate], [AmountExcludingTax], [TaxAmount],
	[TransactionAmount], [OutstandingBalance], [FinalizationDate],
	[LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([CustomerTransactionID], N'')),
	CONVERT(INT,	NULLIF([CustomerID], N'')),
	CONVERT(INT,	NULLIF([TransactionTypeID], N'')),
	CONVERT(INT,	NULLIF([InvoiceID], N'')),
	CONVERT(INT,	NULLIF([PaymentMethodID], N'')),
	CONVERT(DATE,	NULLIF([TransactionDate], N''), 23),
	CONVERT(DECIMAL(18,2),	NULLIF([AmountExcludingTax], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([TaxAmount], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([TransactionAmount], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([OutstandingBalance], N'')),
	CONVERT(DATE,	NULLIF([FinalizationDate], N''), 23),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.CustomerTransactions;
DROP TABLE Staging.CustomerTransactions;
GO

-- 45. Sales.InvoiceLines (needs: Invoices, StockItems, PackageTypes) --
----------------------------------------------------------------------------
IF OBJECT_ID('Staging.InvoiceLines', 'U') IS NOT NULL
	DROP TABLE Staging.InvoiceLines;

CREATE TABLE Staging.InvoiceLines (
	[InvoiceLineID]		NVARCHAR(MAX)	NULL,
	[InvoiceID]			NVARCHAR(MAX)	NULL,
	[StockItemID]		NVARCHAR(MAX)	NULL,
	[Description]		NVARCHAR(MAX)	NULL,
	[PackageTypeID]		NVARCHAR(MAX)	NULL,
	[Quantity]			NVARCHAR(MAX)	NULL,
	[UnitPrice]			NVARCHAR(MAX)	NULL,
	[TaxRate]			NVARCHAR(MAX)	NULL,
	[TaxAmount]			NVARCHAR(MAX)	NULL,
	[LineProfit]		NVARCHAR(MAX)	NULL,
	[ExtendedPrice]		NVARCHAR(MAX)	NULL,
	[LastEditedBy]		NVARCHAR(MAX)	NULL,
	[LastEditedWhen]	NVARCHAR(MAX)	NULL
);
GO

BULK INSERT Staging.InvoiceLines
FROM N'C:\Users\Corex\Desktop\WideWorld Project\csv\Sales.InvoiceLines.csv'
WITH (
	FORMAT			= 'CSV',
	FIRSTROW		= 2,
	FIELDQUOTE		= '"',
	FIELDTERMINATOR	= ',',
	ROWTERMINATOR	= '0x0d0a',
	CODEPAGE		= '65001',
	TABLOCK
);
INSERT INTO Sales.InvoiceLines (
	[InvoiceLineID], [InvoiceID], [StockItemID], [Description], [PackageTypeID],
	[Quantity], [UnitPrice], [TaxRate], [TaxAmount], [LineProfit], [ExtendedPrice],
	[LastEditedBy], [LastEditedWhen])
SELECT
	CONVERT(INT,	NULLIF([InvoiceLineID], N'')),
	CONVERT(INT,	NULLIF([InvoiceID], N'')),
	CONVERT(INT,	NULLIF([StockItemID], N'')),
	ISNULL([Description], N''),
	CONVERT(INT,	NULLIF([PackageTypeID], N'')),
	CONVERT(INT,	NULLIF([Quantity], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([UnitPrice], N'')),
	CONVERT(DECIMAL(18,3),	NULLIF([TaxRate], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([TaxAmount], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([LineProfit], N'')),
	CONVERT(DECIMAL(18,2),	NULLIF([ExtendedPrice], N'')),
	CONVERT(INT,	NULLIF([LastEditedBy], N'')),
	CONVERT(DATETIME2(7),	NULLIF([LastEditedWhen], N''), 121)
FROM Staging.InvoiceLines;
DROP TABLE Staging.InvoiceLines;
GO

-- FINAL: restart every sequence above the highest loaded key, so the next
-- INSERT that relies on the DEFAULT gets a fresh, non-colliding ID.
----------------------------------------------------------------------------
DECLARE @map TABLE (SeqName sysname, TableName nvarchar(300), ColName sysname);
INSERT INTO @map VALUES
 (N'CityID',               N'Application.Cities',              N'CityID'),
 (N'CountryID',            N'Application.Countries',           N'CountryID'),
 (N'DeliveryMethodID',     N'Application.DeliveryMethods',     N'DeliveryMethodID'),
 (N'PaymentMethodID',      N'Application.PaymentMethods',      N'PaymentMethodID'),
 (N'PersonID',             N'Application.People',              N'PersonID'),
 (N'StateProvinceID',      N'Application.StateProvinces',      N'StateProvinceID'),
 (N'SystemParameterID',    N'Application.SystemParameters',    N'SystemParameterID'),
 (N'TransactionTypeID',    N'Application.TransactionTypes',    N'TransactionTypeID'),
 (N'PurchaseOrderID',      N'Purchasing.PurchaseOrders',       N'PurchaseOrderID'),
 (N'PurchaseOrderLineID',  N'Purchasing.PurchaseOrderLines',   N'PurchaseOrderLineID'),
 (N'SupplierCategoryID',   N'Purchasing.SupplierCategories',   N'SupplierCategoryID'),
 (N'SupplierID',           N'Purchasing.Suppliers',            N'SupplierID'),
 (N'TransactionID',        N'Purchasing.SupplierTransactions', N'SupplierTransactionID'),
 (N'TransactionID',        N'Sales.CustomerTransactions',      N'CustomerTransactionID'),
 (N'BuyingGroupID',        N'Sales.BuyingGroups',              N'BuyingGroupID'),
 (N'CustomerCategoryID',   N'Sales.CustomerCategories',        N'CustomerCategoryID'),
 (N'CustomerID',           N'Sales.Customers',                 N'CustomerID'),
 (N'InvoiceID',            N'Sales.Invoices',                  N'InvoiceID'),
 (N'InvoiceLineID',        N'Sales.InvoiceLines',              N'InvoiceLineID'),
 (N'OrderID',              N'Sales.Orders',                    N'OrderID'),
 (N'OrderLineID',          N'Sales.OrderLines',                N'OrderLineID'),
 (N'SpecialDealID',        N'Sales.SpecialDeals',              N'SpecialDealID'),
 (N'ColorID',              N'Warehouse.Colors',                N'ColorID'),
 (N'PackageTypeID',        N'Warehouse.PackageTypes',          N'PackageTypeID'),
 (N'StockGroupID',         N'Warehouse.StockGroups',           N'StockGroupID'),
 (N'StockItemID',          N'Warehouse.StockItems',            N'StockItemID'),
 (N'StockItemStockGroupID',N'Warehouse.StockItemStockGroups',  N'StockItemStockGroupID');

DECLARE @seq sysname, @sql nvarchar(max);
DECLARE seq_cur CURSOR LOCAL FAST_FORWARD FOR SELECT DISTINCT SeqName FROM @map;
OPEN seq_cur;
FETCH NEXT FROM seq_cur INTO @seq;
WHILE @@FETCH_STATUS = 0
BEGIN
    -- highest key across every table fed by this sequence (TransactionID feeds two)
    SET @sql = N'';
    SELECT @sql = @sql + CASE WHEN @sql = N'' THEN N'' ELSE N' UNION ALL ' END
                + N'SELECT MAX(' + QUOTENAME(ColName) + N') AS mx FROM ' + TableName
    FROM @map WHERE SeqName = @seq;

    SET @sql = N'DECLARE @mx bigint, @stmt nvarchar(400);
                 SELECT @mx = ISNULL(MAX(mx), 0) + 1 FROM (' + @sql + N') u;
                 SET @stmt = N''ALTER SEQUENCE Sequences.' + @seq + N' RESTART WITH '' + CAST(@mx AS nvarchar(20)) + N'';'';
                 EXEC (@stmt);';   -- EXEC() only accepts variables/literals, not expressions
    EXEC sp_executesql @sql;
    FETCH NEXT FROM seq_cur INTO @seq;
END
CLOSE seq_cur;
DEALLOCATE seq_cur;
GO

PRINT '02_load_data.sql completed: 45 tables loaded, sequences restarted above max keys.';
GO
