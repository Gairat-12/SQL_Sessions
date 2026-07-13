
	-- 01. Create Objects
	-------------------------------------
	-- TASK 1: Create database & schemas
	-------------------------------------
USE master;
GO
DROP DATABASE IF EXISTS WWI_Rebuild; 
GO
CREATE DATABASE WWI_Rebuild;
GO
USE WWI_Rebuild;
GO

	-- Required: some computed columns use JSON functions
SET QUOTED_IDENTIFIER ON;
GO

CREATE SCHEMA Application;   -- reference data: people, geography, methods
GO
CREATE SCHEMA Purchasing;    -- suppliers and purchase orders
GO
CREATE SCHEMA Sales;         -- customers, orders, invoices
GO
CREATE SCHEMA Warehouse;     -- stock items and warehouse telemetry
GO
CREATE SCHEMA Sequences;     -- container for all sequence objects
GO

	--------------------------------------------------------------------------------
	-- TASK 2 : sequences (26) — every "NEXT VALUE FOR" default in the dictionary
	--------------------------------------------------------------------------------
CREATE SEQUENCE [Sequences].[CityID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[CountryID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[DeliveryMethodID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[PaymentMethodID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[PersonID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[StateProvinceID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[SystemParameterID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[TransactionTypeID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[PurchaseOrderID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[PurchaseOrderLineID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[SupplierCategoryID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[SupplierID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[TransactionID] AS INT START WITH 1 INCREMENT BY 1; 
CREATE SEQUENCE [Sequences].[BuyingGroupID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[CustomerCategoryID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[CustomerID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[InvoiceID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[InvoiceLineID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[OrderID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[OrderLineID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[SpecialDealID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[ColorID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[PackageTypeID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[StockGroupID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[StockItemID] AS INT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE [Sequences].[StockItemStockGroupID] AS INT START WITH 1 INCREMENT BY 1;
GO

------------------------------------------------------------------------------------------
--	TASK 3. Create all 45 tables — columns only.
--			Exact types, lengths, NULL/NOT NULL from the data dictionary.
--			Computed columns defined here too.
--			No PK/FK/defaults/checks — those come later via ALTER TABLE.
------------------------------------------------------------------------------------------
								-------------------
------------------------------- SCHEMA: Application -------------------------------------
								-------------------
-- Shared reference data. Dependency order: 
-- People -> Countries -> StateProvinces -> Cities + methods & config
----------------------------------------------------------------------
CREATE TABLE Application.People (
	PersonID				INT				NOT NULL,
	FullName				NVARCHAR(50)	NOT NULL,
	PreferredName			NVARCHAR(50)	NOT NULL,
	SearchName				AS (concat([PreferredName],N' ',[FullName])),
	IsPermittedToLogon		BIT				NOT NULL,
	LogonName				NVARCHAR(50)	NULL,
	IsExternalLogonProvider	BIT				NOT NULL,
	HashedPassword			VARBINARY(MAX)	NULL,
	IsSystemUser			BIT				NOT NULL,
	IsEmployee				BIT				NOT NULL,
	IsSalesperson			BIT				NOT NULL,
	UserPreferences			NVARCHAR(MAX)	NULL,
	PhoneNumber				NVARCHAR(20)	NULL,
	FaxNumber				NVARCHAR(20)	NULL,
	EmailAddress			NVARCHAR(256)	NULL,
	Photo					VARBINARY(MAX)	NULL,
	CustomFields			NVARCHAR(MAX)	NULL,
	OtherLanguages			AS (json_query([CustomFields],N'$.OtherLanguages')),
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.People_Archive (
	PersonID				INT				NOT NULL,
	FullName				NVARCHAR(50)	NOT NULL,
	PreferredName			NVARCHAR(50)	NOT NULL,
	SearchName				NVARCHAR(101)	NOT NULL,
	IsPermittedToLogon		BIT				NOT NULL,
	LogonName				NVARCHAR(50)	NULL,
	IsExternalLogonProvider	BIT				NOT NULL,
	HashedPassword			VARBINARY(MAX)	NULL,
	IsSystemUser			BIT				NOT NULL,
	IsEmployee				BIT				NOT NULL,
	IsSalesperson			BIT				NOT NULL,
	UserPreferences			NVARCHAR(MAX)	NULL,
	PhoneNumber				NVARCHAR(20)	NULL,
	FaxNumber				NVARCHAR(20)	NULL,
	EmailAddress			NVARCHAR(256)	NULL,
	Photo					VARBINARY(MAX)	NULL,
	CustomFields			NVARCHAR(MAX)	NULL,
	OtherLanguages			NVARCHAR(MAX)	NULL,
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.Countries (
	CountryID					INT				NOT NULL,
	CountryName					NVARCHAR(60)	NOT NULL,
	FormalName					NVARCHAR(60)	NOT NULL,
	IsoAlpha3Code				NVARCHAR(3)		NULL,
	IsoNumericCode				INT				NULL,
	CountryType					NVARCHAR(20)	NULL,
	LatestRecordedPopulation	BIGINT			NULL,
	Continent					NVARCHAR(30)	NOT NULL,
	Region						NVARCHAR(30)	NOT NULL,
	Subregion					NVARCHAR(30)	NOT NULL,
	Border						GEOGRAPHY		NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.Countries_Archive (
	CountryID					INT				NOT NULL,
	CountryName					NVARCHAR(60)	NOT NULL,
	FormalName					NVARCHAR(60)	NOT NULL,
	IsoAlpha3Code				NVARCHAR(3)		NULL,
	IsoNumericCode				INT				NULL,
	CountryType					NVARCHAR(20)	NULL,
	LatestRecordedPopulation	BIGINT			NULL,
	Continent					NVARCHAR(30)	NOT NULL,
	Region						NVARCHAR(30)	NOT NULL,
	Subregion					NVARCHAR(30)	NOT NULL,
	Border						GEOGRAPHY		NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.StateProvinces (
	StateProvinceID				INT				NOT NULL,
	StateProvinceCode			NVARCHAR(5)		NOT NULL,
	StateProvinceName			NVARCHAR(50)	NOT NULL,
	CountryID					INT				NOT NULL,
	SalesTerritory				NVARCHAR(50)	NOT NULL,
	Border						GEOGRAPHY		NULL,
	LatestRecordedPopulation	BIGINT			NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.StateProvinces_Archive (
	StateProvinceID				INT				NOT NULL,
	StateProvinceCode			NVARCHAR(5)		NOT NULL,
	StateProvinceName			NVARCHAR(50)	NOT NULL,
	CountryID					INT				NOT NULL,
	SalesTerritory				NVARCHAR(50)	NOT NULL,
	Border						GEOGRAPHY		NULL,
	LatestRecordedPopulation	BIGINT			NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.DeliveryMethods (
	DeliveryMethodID	INT				NOT NULL,
	DeliveryMethodName	NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.DeliveryMethods_Archive (
	DeliveryMethodID	INT				NOT NULL,
	DeliveryMethodName	NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.PaymentMethods (
	PaymentMethodID		INT				NOT NULL,
	PaymentMethodName	NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.PaymentMethods_Archive (
	PaymentMethodID		INT				NOT NULL,
	PaymentMethodName	NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO


CREATE TABLE Application.TransactionTypes (
	TransactionTypeID	INT				NOT NULL,
	TransactionTypeName	NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.TransactionTypes_Archive (
	TransactionTypeID	INT				NOT NULL,
	TransactionTypeName	NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.SystemParameters (
	SystemParameterID		INT				NOT NULL,
	DeliveryAddressLine1	NVARCHAR(60)	NOT NULL,
	DeliveryAddressLine2	NVARCHAR(60)	NULL,
	DeliveryCityID			INT				NOT NULL,
	DeliveryPostalCode		NVARCHAR(10)	NOT NULL,
	DeliveryLocation		GEOGRAPHY		NOT NULL,
	PostalAddressLine1		NVARCHAR(60)	NOT NULL,
	PostalAddressLine2		NVARCHAR(60)	NULL,
	PostalCityID			INT				NOT NULL,
	PostalPostalCode		NVARCHAR(10)	NOT NULL,
	ApplicationSettings		NVARCHAR(MAX)	NOT NULL,
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.Cities (
	CityID						INT				NOT NULL,
	CityName					NVARCHAR(50)	NOT NULL,
	StateProvinceID				INT				NOT NULL,
	Location					GEOGRAPHY		NULL,
	LatestRecordedPopulation	BIGINT			NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Application.Cities_Archive (
	CityID						INT				NOT NULL,
	CityName					NVARCHAR(50)	NOT NULL,
	StateProvinceID				INT				NOT NULL,
	Location					GEOGRAPHY		NULL,
	LatestRecordedPopulation	BIGINT			NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO
									  --------------------
-------------------------------------- SCHEMA: Purchasing --------------------------------------
									  --------------------
-- Dependency order: Category -> Supplier -> Order -> Lines -> Transactions
----------------------------------------------------------------------------
CREATE TABLE Purchasing.SupplierCategories (
	SupplierCategoryID		INT				NOT NULL,
	SupplierCategoryName	NVARCHAR(50)	NOT NULL,
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Purchasing.SupplierCategories_Archive (
	SupplierCategoryID		INT				NOT NULL,
	SupplierCategoryName	NVARCHAR(50)	NOT NULL,
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Purchasing.Suppliers (
	SupplierID					INT				NOT NULL,
	SupplierName				NVARCHAR(100)	NOT NULL,
	SupplierCategoryID			INT				NOT NULL,
	PrimaryContactPersonID		INT				NOT NULL,
	AlternateContactPersonID	INT				NOT NULL,
	DeliveryMethodID			INT				NULL,
	DeliveryCityID				INT				NOT NULL,
	PostalCityID				INT				NOT NULL,
	SupplierReference			NVARCHAR(20)	NULL,
	BankAccountName				NVARCHAR(50)	NULL,
	BankAccountBranch			NVARCHAR(50)	NULL,
	BankAccountCode				NVARCHAR(20)	NULL,
	BankAccountNumber			NVARCHAR(20)	NULL,
	BankInternationalCode		NVARCHAR(20)	NULL,
	PaymentDays					INT				NOT NULL,
	InternalComments			NVARCHAR(MAX)	NULL,
	PhoneNumber					NVARCHAR(20)	NOT NULL,
	FaxNumber					NVARCHAR(20)	NOT NULL,
	WebsiteURL					NVARCHAR(256)	NOT NULL,
	DeliveryAddressLine1		NVARCHAR(60)	NOT NULL,
	DeliveryAddressLine2		NVARCHAR(60)	NULL,
	DeliveryPostalCode			NVARCHAR(10)	NOT NULL,
	DeliveryLocation			GEOGRAPHY		NULL,
	PostalAddressLine1			NVARCHAR(60)	NOT NULL,
	PostalAddressLine2			NVARCHAR(60)	NULL,
	PostalPostalCode			NVARCHAR(10)	NOT NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Purchasing.Suppliers_Archive (
	SupplierID					INT				NOT NULL,
	SupplierName				NVARCHAR(100)	NOT NULL,
	SupplierCategoryID			INT				NOT NULL,
	PrimaryContactPersonID		INT				NOT NULL,
	AlternateContactPersonID	INT				NOT NULL,
	DeliveryMethodID			INT				NULL,
	DeliveryCityID				INT				NOT NULL,
	PostalCityID				INT				NOT NULL,
	SupplierReference			NVARCHAR(20)	NULL,
	BankAccountName				NVARCHAR(50)	NULL,
	BankAccountBranch			NVARCHAR(50)	NULL,
	BankAccountCode				NVARCHAR(20)	NULL,
	BankAccountNumber			NVARCHAR(20)	NULL,
	BankInternationalCode		NVARCHAR(20)	NULL,
	PaymentDays					INT				NOT NULL,
	InternalComments			NVARCHAR(MAX)	NULL,
	PhoneNumber					NVARCHAR(20)	NOT NULL,
	FaxNumber					NVARCHAR(20)	NOT NULL,
	WebsiteURL					NVARCHAR(256)	NOT NULL,
	DeliveryAddressLine1		NVARCHAR(60)	NOT NULL,
	DeliveryAddressLine2		NVARCHAR(60)	NULL,
	DeliveryPostalCode			NVARCHAR(10)	NOT NULL,
	DeliveryLocation			GEOGRAPHY		NULL,
	PostalAddressLine1			NVARCHAR(60)	NOT NULL,
	PostalAddressLine2			NVARCHAR(60)	NULL,
	PostalPostalCode			NVARCHAR(10)	NOT NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Purchasing.PurchaseOrders (
	PurchaseOrderID			INT				NOT NULL,
	SupplierID				INT				NOT NULL,
	OrderDate				DATE			NOT NULL,
	DeliveryMethodID		INT				NOT NULL,
	ContactPersonID			INT				NOT NULL,
	ExpectedDeliveryDate	DATE			NULL,
	SupplierReference		NVARCHAR(20)	NULL,
	IsOrderFinalized		BIT				NOT NULL,
	Comments				NVARCHAR(MAX)	NULL,
	InternalComments		NVARCHAR(MAX)	NULL,
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Purchasing.PurchaseOrderLines (
	PurchaseOrderLineID			INT				NOT NULL,
	PurchaseOrderID				INT				NOT NULL,
	StockItemID					INT				NOT NULL,
	OrderedOuters				INT				NOT NULL,
	Description					NVARCHAR(100)	NOT NULL,
	ReceivedOuters				INT				NOT NULL,
	PackageTypeID				INT				NOT NULL,
	ExpectedUnitPricePerOuter	DECIMAL(18,2)	NULL,
	LastReceiptDate				DATE			NULL,
	IsOrderLineFinalized		BIT				NOT NULL,
	LastEditedBy				INT				NOT NULL,
	LastEditedWhen				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Purchasing.SupplierTransactions (
	SupplierTransactionID	INT				NOT NULL,
	SupplierID				INT				NOT NULL,
	TransactionTypeID		INT				NOT NULL,
	PurchaseOrderID			INT				NULL,
	PaymentMethodID			INT				NULL,
	SupplierInvoiceNumber	NVARCHAR(20)	NULL,
	TransactionDate			DATE			NOT NULL,
	AmountExcludingTax		DECIMAL(18,2)	NOT NULL,
	TaxAmount				DECIMAL(18,2)	NOT NULL,
	TransactionAmount		DECIMAL(18,2)	NOT NULL,
	OutstandingBalance		DECIMAL(18,2)	NOT NULL,
	FinalizationDate		DATE			NULL,
	IsFinalized				AS (CASE WHEN [FinalizationDate] IS NULL THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END),
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO
									  ---------------
-------------------------------------- SCHEMA: Sales --------------------------------------
									  ---------------
-- Dependency order: Groups/Categories -> Customers -> Orders -> Invoices -> Lines -> Transactions
---------------------------------------------------------------------------------------------------
CREATE TABLE Sales.BuyingGroups (
	BuyingGroupID		INT				NOT NULL,
	BuyingGroupName		NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.BuyingGroups_Archive (
	BuyingGroupID		INT				NOT NULL,
	BuyingGroupName		NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.CustomerCategories (
	CustomerCategoryID		INT				NOT NULL,
	CustomerCategoryName	NVARCHAR(50)	NOT NULL,
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.CustomerCategories_Archive (
	CustomerCategoryID		INT				NOT NULL,
	CustomerCategoryName	NVARCHAR(50)	NOT NULL,
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.Customers (
	CustomerID					INT				NOT NULL,
	CustomerName				NVARCHAR(100)	NOT NULL,
	BillToCustomerID			INT				NOT NULL,
	CustomerCategoryID			INT				NOT NULL,
	BuyingGroupID				INT				NULL,
	PrimaryContactPersonID		INT				NOT NULL,
	AlternateContactPersonID	INT				NULL,
	DeliveryMethodID			INT				NOT NULL,
	DeliveryCityID				INT				NOT NULL,
	PostalCityID				INT				NOT NULL,
	CreditLimit					DECIMAL(18,2)	NULL,
	AccountOpenedDate			DATE			NOT NULL,
	StandardDiscountPercentage	DECIMAL(18,3)	NOT NULL,
	IsStatementSent				BIT				NOT NULL,
	IsOnCreditHold				BIT				NOT NULL,
	PaymentDays					INT				NOT NULL,
	PhoneNumber					NVARCHAR(20)	NOT NULL,
	FaxNumber					NVARCHAR(20)	NOT NULL,
	DeliveryRun					NVARCHAR(5)		NULL,
	RunPosition					NVARCHAR(5)		NULL,
	WebsiteURL					NVARCHAR(256)	NOT NULL,
	DeliveryAddressLine1		NVARCHAR(60)	NOT NULL,
	DeliveryAddressLine2		NVARCHAR(60)	NULL,
	DeliveryPostalCode			NVARCHAR(10)	NOT NULL,
	DeliveryLocation			GEOGRAPHY		NULL,
	PostalAddressLine1			NVARCHAR(60)	NOT NULL,
	PostalAddressLine2			NVARCHAR(60)	NULL,
	PostalPostalCode			NVARCHAR(10)	NOT NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.Customers_Archive (
	CustomerID					INT				NOT NULL,
	CustomerName				NVARCHAR(100)	NOT NULL,
	BillToCustomerID			INT				NOT NULL,
	CustomerCategoryID			INT				NOT NULL,
	BuyingGroupID				INT				NULL,
	PrimaryContactPersonID		INT				NOT NULL,
	AlternateContactPersonID	INT				NULL,
	DeliveryMethodID			INT				NOT NULL,
	DeliveryCityID				INT				NOT NULL,
	PostalCityID				INT				NOT NULL,
	CreditLimit					DECIMAL(18,2)	NULL,
	AccountOpenedDate			DATE			NOT NULL,
	StandardDiscountPercentage	DECIMAL(18,3)	NOT NULL,
	IsStatementSent				BIT				NOT NULL,
	IsOnCreditHold				BIT				NOT NULL,
	PaymentDays					INT				NOT NULL,
	PhoneNumber					NVARCHAR(20)	NOT NULL,
	FaxNumber					NVARCHAR(20)	NOT NULL,
	DeliveryRun					NVARCHAR(5)		NULL,
	RunPosition					NVARCHAR(5)		NULL,
	WebsiteURL					NVARCHAR(256)	NOT NULL,
	DeliveryAddressLine1		NVARCHAR(60)	NOT NULL,
	DeliveryAddressLine2		NVARCHAR(60)	NULL,
	DeliveryPostalCode			NVARCHAR(10)	NOT NULL,
	DeliveryLocation			GEOGRAPHY		NULL,
	PostalAddressLine1			NVARCHAR(60)	NOT NULL,
	PostalAddressLine2			NVARCHAR(60)	NULL,
	PostalPostalCode			NVARCHAR(10)	NOT NULL,
	LastEditedBy				INT				NOT NULL,
	ValidFrom					DATETIME2(7)	NOT NULL,
	ValidTo						DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.Orders (
	OrderID						INT				NOT NULL,
	CustomerID					INT				NOT NULL,
	SalespersonPersonID			INT				NOT NULL,
	PickedByPersonID			INT				NULL,
	ContactPersonID				INT				NOT NULL,
	BackorderOrderID			INT				NULL,
	OrderDate					DATE			NOT NULL,
	ExpectedDeliveryDate		DATE			NOT NULL,
	CustomerPurchaseOrderNumber	NVARCHAR(20)	NULL,
	IsUndersupplyBackordered	BIT				NOT NULL,
	Comments					NVARCHAR(MAX)	NULL,
	DeliveryInstructions		NVARCHAR(MAX)	NULL,
	InternalComments			NVARCHAR(MAX)	NULL,
	PickingCompletedWhen		DATETIME2(7)	NULL,
	LastEditedBy				INT				NOT NULL,
	LastEditedWhen				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.OrderLines (
	OrderLineID				INT				NOT NULL,
	OrderID					INT				NOT NULL,
	StockItemID				INT				NOT NULL,
	Description				NVARCHAR(100)	NOT NULL,
	PackageTypeID			INT				NOT NULL,
	Quantity				INT				NOT NULL,
	UnitPrice				DECIMAL(18,2)	NULL,
	TaxRate					DECIMAL(18,3)	NOT NULL,
	PickedQuantity			INT				NOT NULL,
	PickingCompletedWhen	DATETIME2(7)	NULL,
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.Invoices (
	InvoiceID					INT				NOT NULL,
	CustomerID					INT				NOT NULL,
	BillToCustomerID			INT				NOT NULL,
	OrderID						INT				NULL,
	DeliveryMethodID			INT				NOT NULL,
	ContactPersonID				INT				NOT NULL,
	AccountsPersonID			INT				NOT NULL,
	SalespersonPersonID			INT				NOT NULL,
	PackedByPersonID			INT				NOT NULL,
	InvoiceDate					DATE			NOT NULL,
	CustomerPurchaseOrderNumber	NVARCHAR(20)	NULL,
	IsCreditNote				BIT				NOT NULL,
	CreditNoteReason			NVARCHAR(MAX)	NULL,
	Comments					NVARCHAR(MAX)	NULL,
	DeliveryInstructions		NVARCHAR(MAX)	NULL,
	InternalComments			NVARCHAR(MAX)	NULL,
	TotalDryItems				INT				NOT NULL,
	TotalChillerItems			INT				NOT NULL,
	DeliveryRun					NVARCHAR(5)		NULL,
	RunPosition					NVARCHAR(5)		NULL,
	ReturnedDeliveryData		NVARCHAR(MAX)	NULL,
	ConfirmedDeliveryTime		AS (TRY_CONVERT(DATETIME2(7), JSON_VALUE([ReturnedDeliveryData], N'$.DeliveredWhen'), 126)),
	ConfirmedReceivedBy			AS (JSON_VALUE([ReturnedDeliveryData], N'$.ReceivedBy')),
	LastEditedBy				INT				NOT NULL,
	LastEditedWhen				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.InvoiceLines (
	InvoiceLineID	INT				NOT NULL,
	InvoiceID		INT				NOT NULL,
	StockItemID		INT				NOT NULL,
	Description		NVARCHAR(100)	NOT NULL,
	PackageTypeID	INT				NOT NULL,
	Quantity		INT				NOT NULL,
	UnitPrice		DECIMAL(18,2)	NULL,
	TaxRate			DECIMAL(18,3)	NOT NULL,
	TaxAmount		DECIMAL(18,2)	NOT NULL,
	LineProfit		DECIMAL(18,2)	NOT NULL,
	ExtendedPrice	DECIMAL(18,2)	NOT NULL,
	LastEditedBy	INT				NOT NULL,
	LastEditedWhen	DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.CustomerTransactions (
	CustomerTransactionID	INT				NOT NULL,
	CustomerID				INT				NOT NULL,
	TransactionTypeID		INT				NOT NULL,
	InvoiceID				INT				NULL,
	PaymentMethodID			INT				NULL,
	TransactionDate			DATE			NOT NULL,
	AmountExcludingTax		DECIMAL(18,2)	NOT NULL,
	TaxAmount				DECIMAL(18,2)	NOT NULL,
	TransactionAmount		DECIMAL(18,2)	NOT NULL,
	OutstandingBalance		DECIMAL(18,2)	NOT NULL,
	FinalizationDate		DATE			NULL,
	IsFinalized				AS (CASE WHEN [FinalizationDate] IS NULL THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END),
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Sales.SpecialDeals (
	SpecialDealID		INT				NOT NULL,
	StockItemID			INT				NULL,
	CustomerID			INT				NULL,
	BuyingGroupID		INT				NULL,
	CustomerCategoryID	INT				NULL,
	StockGroupID		INT				NULL,
	DealDescription		NVARCHAR(30)	NOT NULL,
	StartDate			DATE			NOT NULL,
	EndDate				DATE			NOT NULL,
	DiscountAmount		DECIMAL(18,2)	NULL,
	DiscountPercentage	DECIMAL(18,3)	NULL,
	UnitPrice			DECIMAL(18,2)	NULL,
	LastEditedBy		INT				NOT NULL,
	LastEditedWhen		DATETIME2(7)	NOT NULL
	);
GO
											 -------------------
--------------------------------------------- SCHEMA: Warehouse ---------------------------------------------
-- Dependency order:						 -------------------
-- Colors/PackageTypes/StockGroups -> StockItems -> Holdings & StockItemStockGroups + ColdRoom sensors
-------------------------------------------------------------------------------------------------------
CREATE TABLE Warehouse.Colors (
	ColorID			INT				NOT NULL,
	ColorName		NVARCHAR(20)	NOT NULL,
	LastEditedBy	INT				NOT NULL,
	ValidFrom		DATETIME2(7)	NOT NULL,
	ValidTo			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.Colors_Archive (
	ColorID			INT				NOT NULL,
	ColorName		NVARCHAR(20)	NOT NULL,
	LastEditedBy	INT				NOT NULL,
	ValidFrom		DATETIME2(7)	NOT NULL,
	ValidTo			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.PackageTypes (
	PackageTypeID		INT				NOT NULL,
	PackageTypeName		NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.PackageTypes_Archive (
	PackageTypeID		INT				NOT NULL,
	PackageTypeName		NVARCHAR(50)	NOT NULL,
	LastEditedBy		INT				NOT NULL,
	ValidFrom			DATETIME2(7)	NOT NULL,
	ValidTo				DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.StockGroups (
	StockGroupID	INT				NOT NULL,
	StockGroupName	NVARCHAR(50)	NOT NULL,
	LastEditedBy	INT				NOT NULL,
	ValidFrom		DATETIME2(7)	NOT NULL,
	ValidTo			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.StockGroups_Archive (
	StockGroupID	INT				NOT NULL,
	StockGroupName	NVARCHAR(50)	NOT NULL,
	LastEditedBy	INT				NOT NULL,
	ValidFrom		DATETIME2(7)	NOT NULL,
	ValidTo			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.StockItems (
	StockItemID				INT				NOT NULL,
	StockItemName			NVARCHAR(100)	NOT NULL,
	SupplierID				INT				NOT NULL,
	ColorID					INT				NULL,
	UnitPackageID			INT				NOT NULL,
	OuterPackageID			INT				NOT NULL,
	Brand					NVARCHAR(50)	NULL,
	Size					NVARCHAR(20)	NULL,
	LeadTimeDays			INT				NOT NULL,
	QuantityPerOuter		INT				NOT NULL,
	IsChillerStock			BIT				NOT NULL,
	Barcode					NVARCHAR(50)	NULL,
	TaxRate					DECIMAL(18,3)	NOT NULL,
	UnitPrice				DECIMAL(18,2)	NOT NULL,
	RecommendedRetailPrice	DECIMAL(18,2)	NULL,
	TypicalWeightPerUnit	DECIMAL(18,3)	NOT NULL,
	MarketingComments		NVARCHAR(MAX)	NULL,
	InternalComments		NVARCHAR(MAX)	NULL,
	Photo					VARBINARY(MAX)	NULL,
	CustomFields			NVARCHAR(MAX)	NULL,
	Tags					AS (JSON_QUERY([CustomFields], N'$.Tags')),
	SearchDetails			AS (CONCAT([StockItemName], N' ', [MarketingComments])),
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.StockItems_Archive (
	StockItemID				INT				NOT NULL,
	StockItemName			NVARCHAR(100)	NOT NULL,
	SupplierID				INT				NOT NULL,
	ColorID					INT				NULL,
	UnitPackageID			INT				NOT NULL,
	OuterPackageID			INT				NOT NULL,
	Brand					NVARCHAR(50)	NULL,
	Size					NVARCHAR(20)	NULL,
	LeadTimeDays			INT				NOT NULL,
	QuantityPerOuter		INT				NOT NULL,
	IsChillerStock			BIT				NOT NULL,
	Barcode					NVARCHAR(50)	NULL,
	TaxRate					DECIMAL(18,3)	NOT NULL,
	UnitPrice				DECIMAL(18,2)	NOT NULL,
	RecommendedRetailPrice	DECIMAL(18,2)	NULL,
	TypicalWeightPerUnit	DECIMAL(18,3)	NOT NULL,
	MarketingComments		NVARCHAR(MAX)	NULL,
	InternalComments		NVARCHAR(MAX)	NULL,
	Photo					VARBINARY(MAX)	NULL,
	CustomFields			NVARCHAR(MAX)	NULL,
	Tags					NVARCHAR(MAX)	NULL,
	SearchDetails			NVARCHAR(MAX)	NOT NULL,
	LastEditedBy			INT				NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.StockItemHoldings (
	StockItemID				INT				NOT NULL,
	QuantityOnHand			INT				NOT NULL,
	BinLocation				NVARCHAR(20)	NOT NULL,
	LastStocktakeQuantity	INT				NOT NULL,
	LastCostPrice			DECIMAL(18,2)	NOT NULL,
	ReorderLevel			INT				NOT NULL,
	TargetStockLevel		INT				NOT NULL,
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.StockItemStockGroups (
	StockItemStockGroupID	INT				NOT NULL,
	StockItemID				INT				NOT NULL,
	StockGroupID			INT				NOT NULL,
	LastEditedBy			INT				NOT NULL,
	LastEditedWhen			DATETIME2(7)	NOT NULL
	);
GO

CREATE TABLE Warehouse.ColdRoomTemperatures (
	ColdRoomTemperatureID	BIGINT			NOT NULL,
	ColdRoomSensorNumber	INT				NOT NULL,
	RecordedWhen			DATETIME2(7)	NOT NULL,
	Temperature				DECIMAL(10,2)	NOT NULL,
	ValidFrom				DATETIME2(7)	NOT NULL,
	ValidTo					DATETIME2(7)	NOT NULL
	);
GO

--------------------------------------------------------------------------
-- TASK 4: Primary keys & unique constraints — via ALTER TABLE.
--		   PK on every base table (29); Archive tables = history, no keys.
--		   Unique constraints: none indicated in the dictionary.
--		   Naming: PK_Schema_Table
---------------------------------------------------------------------------
													  /* Application PKs */
													  ---------------------
ALTER TABLE Application.People            ADD CONSTRAINT PK_Application_People            PRIMARY KEY (PersonID);
ALTER TABLE Application.Countries         ADD CONSTRAINT PK_Application_Countries         PRIMARY KEY (CountryID);
ALTER TABLE Application.StateProvinces    ADD CONSTRAINT PK_Application_StateProvinces    PRIMARY KEY (StateProvinceID);
ALTER TABLE Application.DeliveryMethods   ADD CONSTRAINT PK_Application_DeliveryMethods   PRIMARY KEY (DeliveryMethodID);
ALTER TABLE Application.PaymentMethods    ADD CONSTRAINT PK_Application_PaymentMethods    PRIMARY KEY (PaymentMethodID);
ALTER TABLE Application.TransactionTypes  ADD CONSTRAINT PK_Application_TransactionTypes  PRIMARY KEY (TransactionTypeID);
ALTER TABLE Application.SystemParameters  ADD CONSTRAINT PK_Application_SystemParameters  PRIMARY KEY (SystemParameterID);
ALTER TABLE Application.Cities            ADD CONSTRAINT PK_Application_Cities            PRIMARY KEY (CityID);

													  ---------------------
													  /* Purchasing  PKs */
													  ---------------------
ALTER TABLE Purchasing.SupplierCategories   ADD CONSTRAINT PK_Purchasing_SupplierCategories   PRIMARY KEY (SupplierCategoryID);
ALTER TABLE Purchasing.Suppliers            ADD CONSTRAINT PK_Purchasing_Suppliers            PRIMARY KEY (SupplierID);
ALTER TABLE Purchasing.PurchaseOrders       ADD CONSTRAINT PK_Purchasing_PurchaseOrders       PRIMARY KEY (PurchaseOrderID);
ALTER TABLE Purchasing.PurchaseOrderLines   ADD CONSTRAINT PK_Purchasing_PurchaseOrderLines   PRIMARY KEY (PurchaseOrderLineID);
ALTER TABLE Purchasing.SupplierTransactions ADD CONSTRAINT PK_Purchasing_SupplierTransactions PRIMARY KEY (SupplierTransactionID);

														----------------
														/* Sales  PKs */
														----------------
ALTER TABLE Sales.BuyingGroups          ADD CONSTRAINT PK_Sales_BuyingGroups          PRIMARY KEY (BuyingGroupID);
ALTER TABLE Sales.CustomerCategories    ADD CONSTRAINT PK_Sales_CustomerCategories    PRIMARY KEY (CustomerCategoryID);
ALTER TABLE Sales.Customers             ADD CONSTRAINT PK_Sales_Customers             PRIMARY KEY (CustomerID);
ALTER TABLE Sales.Orders                ADD CONSTRAINT PK_Sales_Orders                PRIMARY KEY (OrderID);
ALTER TABLE Sales.OrderLines            ADD CONSTRAINT PK_Sales_OrderLines            PRIMARY KEY (OrderLineID);
ALTER TABLE Sales.Invoices              ADD CONSTRAINT PK_Sales_Invoices              PRIMARY KEY (InvoiceID);
ALTER TABLE Sales.InvoiceLines          ADD CONSTRAINT PK_Sales_InvoiceLines          PRIMARY KEY (InvoiceLineID);
ALTER TABLE Sales.CustomerTransactions  ADD CONSTRAINT PK_Sales_CustomerTransactions  PRIMARY KEY (CustomerTransactionID);
ALTER TABLE Sales.SpecialDeals          ADD CONSTRAINT PK_Sales_SpecialDeals          PRIMARY KEY (SpecialDealID);
													   --------------------
													   /* Warehouse  PKs */
													   --------------------
ALTER TABLE Warehouse.Colors               ADD CONSTRAINT PK_Warehouse_Colors               PRIMARY KEY (ColorID);
ALTER TABLE Warehouse.PackageTypes         ADD CONSTRAINT PK_Warehouse_PackageTypes         PRIMARY KEY (PackageTypeID);
ALTER TABLE Warehouse.StockGroups          ADD CONSTRAINT PK_Warehouse_StockGroups          PRIMARY KEY (StockGroupID);
ALTER TABLE Warehouse.StockItems           ADD CONSTRAINT PK_Warehouse_StockItems           PRIMARY KEY (StockItemID);
ALTER TABLE Warehouse.StockItemHoldings    ADD CONSTRAINT PK_Warehouse_StockItemHoldings    PRIMARY KEY (StockItemID);
ALTER TABLE Warehouse.StockItemStockGroups ADD CONSTRAINT PK_Warehouse_StockItemStockGroups PRIMARY KEY (StockItemStockGroupID);
ALTER TABLE Warehouse.ColdRoomTemperatures ADD CONSTRAINT PK_Warehouse_ColdRoomTemperatures PRIMARY KEY (ColdRoomTemperatureID);
GO

-------------------------------------------------------------------------
-- TASK 5: Defaults & checks — via ALTER TABLE.
--		   Sequence defaults from Task 2: 26 sequences -> 27 ID columns
--		   (TransactionID is shared by Supplier- & CustomerTransactions).
--		   Value defaults: sysdatetime() on LastEditedWhen columns.
--		   No check constraints in the dictionary.
--		   Naming: DF_Schema_Table_Column
-------------------------------------------------------------------------
									  -----------------------------------
									  /* Application Defaults & checks */
									  -----------------------------------
ALTER TABLE Application.People				ADD CONSTRAINT DF_Application_People_PersonID	
	DEFAULT (NEXT VALUE FOR Sequences.PersonID)				FOR PersonID;
ALTER TABLE Application.Countries			ADD CONSTRAINT DF_Application_Countries_CountryID 
	DEFAULT (NEXT VALUE FOR Sequences.CountryID)			FOR CountryID;
ALTER TABLE Application.StateProvinces		ADD CONSTRAINT DF_Application_StateProvinces_StateProvinceID 
	DEFAULT (NEXT VALUE FOR Sequences.StateProvinceID)		FOR StateProvinceID;
ALTER TABLE Application.DeliveryMethods		ADD CONSTRAINT DF_Application_DeliveryMethods_DeliveryMethodID
	DEFAULT (NEXT VALUE FOR Sequences.DeliveryMethodID)		FOR DeliveryMethodID;
ALTER TABLE Application.PaymentMethods		ADD CONSTRAINT DF_Application_PaymentMethods_PaymentMethodID
	DEFAULT (NEXT VALUE FOR Sequences.PaymentMethodID)		FOR PaymentMethodID;
ALTER TABLE Application.TransactionTypes	ADD CONSTRAINT DF_Application_TransactionTypes_TransactionTypeID
	DEFAULT (NEXT VALUE FOR Sequences.TransactionTypeID)	FOR TransactionTypeID;
ALTER TABLE Application.SystemParameters	ADD CONSTRAINT DF_Application_SystemParameters_SystemParameterID
	DEFAULT (NEXT VALUE FOR Sequences.SystemParameterID)	FOR SystemParameterID;
ALTER TABLE Application.Cities				ADD CONSTRAINT DF_Application_Cities_CityID
	DEFAULT (NEXT VALUE FOR Sequences.CityID)				FOR CityID;
ALTER TABLE Application.SystemParameters	ADD CONSTRAINT DF_Application_SystemParameters_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;

									   ----------------------------------
									   /* Purchasing Defaults & checks */
									   ----------------------------------
ALTER TABLE Purchasing.SupplierCategories	ADD CONSTRAINT DF_Purchasing_SupplierCategories_SupplierCategoryID
	DEFAULT (NEXT VALUE FOR Sequences.SupplierCategoryID)	FOR SupplierCategoryID;
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT DF_Purchasing_Suppliers_SupplierID
	DEFAULT (NEXT VALUE FOR Sequences.SupplierID)			FOR SupplierID;
ALTER TABLE Purchasing.PurchaseOrders		ADD CONSTRAINT DF_Purchasing_PurchaseOrders_PurchaseOrderID
	DEFAULT (NEXT VALUE FOR Sequences.PurchaseOrderID)		FOR PurchaseOrderID;
ALTER TABLE Purchasing.PurchaseOrderLines	ADD CONSTRAINT DF_Purchasing_PurchaseOrderLines_PurchaseOrderLineID
	DEFAULT (NEXT VALUE FOR Sequences.PurchaseOrderLineID)	FOR PurchaseOrderLineID;
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT DF_Purchasing_SupplierTransactions_SupplierTransactionID
	DEFAULT (NEXT VALUE FOR Sequences.TransactionID)		FOR SupplierTransactionID;
ALTER TABLE Purchasing.PurchaseOrders		ADD CONSTRAINT DF_Purchasing_PurchaseOrders_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Purchasing.PurchaseOrderLines	ADD CONSTRAINT DF_Purchasing_PurchaseOrderLines_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT DF_Purchasing_SupplierTransactions_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;

										  -----------------------------
										  /* Sales Defaults & checks */
										  -----------------------------
ALTER TABLE Sales.BuyingGroups			ADD CONSTRAINT DF_Sales_BuyingGroups_BuyingGroupID
	DEFAULT (NEXT VALUE FOR Sequences.BuyingGroupID)		FOR BuyingGroupID;
ALTER TABLE Sales.CustomerCategories	ADD CONSTRAINT DF_Sales_CustomerCategories_CustomerCategoryID
	DEFAULT (NEXT VALUE FOR Sequences.CustomerCategoryID)	FOR CustomerCategoryID;
ALTER TABLE Sales.Customers				ADD CONSTRAINT DF_Sales_Customers_CustomerID
	DEFAULT (NEXT VALUE FOR Sequences.CustomerID)			FOR CustomerID;
ALTER TABLE Sales.Orders				ADD CONSTRAINT DF_Sales_Orders_OrderID
	DEFAULT (NEXT VALUE FOR Sequences.OrderID)				FOR OrderID;
ALTER TABLE Sales.OrderLines			ADD CONSTRAINT DF_Sales_OrderLines_OrderLineID
	DEFAULT (NEXT VALUE FOR Sequences.OrderLineID)			FOR OrderLineID;
ALTER TABLE Sales.Invoices				ADD CONSTRAINT DF_Sales_Invoices_InvoiceID
	DEFAULT (NEXT VALUE FOR Sequences.InvoiceID)			FOR InvoiceID;
ALTER TABLE Sales.InvoiceLines			ADD CONSTRAINT DF_Sales_InvoiceLines_InvoiceLineID
	DEFAULT (NEXT VALUE FOR Sequences.InvoiceLineID)		FOR InvoiceLineID;
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT DF_Sales_CustomerTransactions_CustomerTransactionID
	DEFAULT (NEXT VALUE FOR Sequences.TransactionID)		FOR CustomerTransactionID;
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT DF_Sales_SpecialDeals_SpecialDealID
	DEFAULT (NEXT VALUE FOR Sequences.SpecialDealID)		FOR SpecialDealID;
ALTER TABLE Sales.Orders				ADD CONSTRAINT DF_Sales_Orders_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Sales.OrderLines			ADD CONSTRAINT DF_Sales_OrderLines_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Sales.Invoices				ADD CONSTRAINT DF_Sales_Invoices_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Sales.InvoiceLines			ADD CONSTRAINT DF_Sales_InvoiceLines_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT DF_Sales_CustomerTransactions_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT DF_Sales_SpecialDeals_LastEditedWhen
	DEFAULT (SYSDATETIME())									FOR LastEditedWhen;

										---------------------------------
										/* Warehouse Defaults & checks */
										---------------------------------
ALTER TABLE Warehouse.Colors				ADD CONSTRAINT DF_Warehouse_Colors_ColorID
	DEFAULT (NEXT VALUE FOR Sequences.ColorID)					FOR ColorID;
ALTER TABLE Warehouse.PackageTypes			ADD CONSTRAINT DF_Warehouse_PackageTypes_PackageTypeID
	DEFAULT (NEXT VALUE FOR Sequences.PackageTypeID)			FOR PackageTypeID;
ALTER TABLE Warehouse.StockGroups			ADD CONSTRAINT DF_Warehouse_StockGroups_StockGroupID
	DEFAULT (NEXT VALUE FOR Sequences.StockGroupID)				FOR StockGroupID;
ALTER TABLE Warehouse.StockItems			ADD CONSTRAINT DF_Warehouse_StockItems_StockItemID
	DEFAULT (NEXT VALUE FOR Sequences.StockItemID)				FOR StockItemID;
ALTER TABLE Warehouse.StockItemStockGroups	ADD CONSTRAINT DF_Warehouse_StockItemStockGroups_StockItemStockGroupID
	DEFAULT (NEXT VALUE FOR Sequences.StockItemStockGroupID)	FOR StockItemStockGroupID;
ALTER TABLE Warehouse.StockItemHoldings		ADD CONSTRAINT DF_Warehouse_StockItemHoldings_LastEditedWhen
	DEFAULT (SYSDATETIME())										FOR LastEditedWhen;
ALTER TABLE Warehouse.StockItemStockGroups	ADD CONSTRAINT DF_Warehouse_StockItemStockGroups_LastEditedWhen
	DEFAULT (SYSDATETIME())										FOR LastEditedWhen;

---------------------------------------------------------------------------------
-- TASK 6: Foreign keys — via ALTER TABLE ... FOREIGN KEY ... REFERENCES.
--		   Source: data dictionary + ER diagram (relationships.csv not provided).
--		   WHY AFTER ALL TABLES: an FK can only reference a parent that already
--		   exists, and some references are circular (People -> People,
--		   Purchasing <-> Warehouse) — no CREATE TABLE order could satisfy
--		   them inline. Create all tables first, then all FKs = no order problem.
--		   Naming: FK_Child_Column_Parent
----------------------------------------------------------------------------------
--\\ Application //--
---------------------
ALTER TABLE Application.People				ADD CONSTRAINT FK_People_LastEditedBy_People				FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.Countries			ADD CONSTRAINT FK_Countries_LastEditedBy_People				FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.StateProvinces		ADD CONSTRAINT FK_StateProvinces_CountryID_Countries		FOREIGN KEY (CountryID)			
	REFERENCES Application.Countries (CountryID);
ALTER TABLE Application.StateProvinces		ADD CONSTRAINT FK_StateProvinces_LastEditedBy_People		FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.Cities				ADD CONSTRAINT FK_Cities_StateProvinceID_StateProvinces		FOREIGN KEY (StateProvinceID)	
	REFERENCES Application.StateProvinces (StateProvinceID);
ALTER TABLE Application.Cities				ADD CONSTRAINT FK_Cities_LastEditedBy_People				FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.DeliveryMethods		ADD CONSTRAINT FK_DeliveryMethods_LastEditedBy_People		FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.PaymentMethods		ADD CONSTRAINT FK_PaymentMethods_LastEditedBy_People		FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.TransactionTypes	ADD CONSTRAINT FK_TransactionTypes_LastEditedBy_People		FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);
ALTER TABLE Application.SystemParameters	ADD CONSTRAINT FK_SystemParameters_DeliveryCityID_Cities	FOREIGN KEY (DeliveryCityID)	
	REFERENCES Application.Cities (CityID);
ALTER TABLE Application.SystemParameters	ADD CONSTRAINT FK_SystemParameters_PostalCityID_Cities		FOREIGN KEY (PostalCityID)		
	REFERENCES Application.Cities (CityID);
ALTER TABLE Application.SystemParameters	ADD CONSTRAINT FK_SystemParameters_LastEditedBy_People		FOREIGN KEY (LastEditedBy)		
	REFERENCES Application.People (PersonID);

--\\ Purchasing //--
--------------------
ALTER TABLE Purchasing.SupplierCategories	ADD CONSTRAINT FK_SupplierCategories_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_SupplierCategoryID_SupplierCategories
	FOREIGN KEY (SupplierCategoryID)		REFERENCES Purchasing.SupplierCategories (SupplierCategoryID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_PrimaryContactPersonID_People
	FOREIGN KEY (PrimaryContactPersonID)	REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_AlternateContactPersonID_People
	FOREIGN KEY (AlternateContactPersonID)	REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_DeliveryMethodID_DeliveryMethods
	FOREIGN KEY (DeliveryMethodID)			REFERENCES Application.DeliveryMethods (DeliveryMethodID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_DeliveryCityID_Cities
	FOREIGN KEY (DeliveryCityID)			REFERENCES Application.Cities (CityID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_PostalCityID_Cities
	FOREIGN KEY (PostalCityID)				REFERENCES Application.Cities (CityID);
ALTER TABLE Purchasing.Suppliers			ADD CONSTRAINT FK_Suppliers_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.PurchaseOrders		ADD CONSTRAINT FK_PurchaseOrders_SupplierID_Suppliers
	FOREIGN KEY (SupplierID)				REFERENCES Purchasing.Suppliers (SupplierID);
ALTER TABLE Purchasing.PurchaseOrders		ADD CONSTRAINT FK_PurchaseOrders_DeliveryMethodID_DeliveryMethods
	FOREIGN KEY (DeliveryMethodID)			REFERENCES Application.DeliveryMethods (DeliveryMethodID);
ALTER TABLE Purchasing.PurchaseOrders		ADD CONSTRAINT FK_PurchaseOrders_ContactPersonID_People
	FOREIGN KEY (ContactPersonID)			REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.PurchaseOrders		ADD CONSTRAINT FK_PurchaseOrders_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.PurchaseOrderLines	ADD CONSTRAINT FK_PurchaseOrderLines_PurchaseOrderID_PurchaseOrders
	FOREIGN KEY (PurchaseOrderID)			REFERENCES Purchasing.PurchaseOrders (PurchaseOrderID);
ALTER TABLE Purchasing.PurchaseOrderLines	ADD CONSTRAINT FK_PurchaseOrderLines_StockItemID_StockItems
	FOREIGN KEY (StockItemID)				REFERENCES Warehouse.StockItems (StockItemID);
ALTER TABLE Purchasing.PurchaseOrderLines	ADD CONSTRAINT FK_PurchaseOrderLines_PackageTypeID_PackageTypes
	FOREIGN KEY (PackageTypeID)				REFERENCES Warehouse.PackageTypes (PackageTypeID);
ALTER TABLE Purchasing.PurchaseOrderLines	ADD CONSTRAINT FK_PurchaseOrderLines_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT FK_SupplierTransactions_SupplierID_Suppliers
	FOREIGN KEY (SupplierID)				REFERENCES Purchasing.Suppliers (SupplierID);
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT FK_SupplierTransactions_TransactionTypeID_TransactionTypes
	FOREIGN KEY (TransactionTypeID)			REFERENCES Application.TransactionTypes (TransactionTypeID);
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT FK_SupplierTransactions_PurchaseOrderID_PurchaseOrders
	FOREIGN KEY (PurchaseOrderID)			REFERENCES Purchasing.PurchaseOrders (PurchaseOrderID);
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT FK_SupplierTransactions_PaymentMethodID_PaymentMethods
	FOREIGN KEY (PaymentMethodID)			REFERENCES Application.PaymentMethods (PaymentMethodID);
ALTER TABLE Purchasing.SupplierTransactions	ADD CONSTRAINT FK_SupplierTransactions_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);

--\\ Sales //--
---------------
ALTER TABLE Sales.BuyingGroups			ADD CONSTRAINT FK_BuyingGroups_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.CustomerCategories	ADD CONSTRAINT FK_CustomerCategories_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_BillToCustomerID_Customers
	FOREIGN KEY (BillToCustomerID)			REFERENCES Sales.Customers (CustomerID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_CustomerCategoryID_CustomerCategories
	FOREIGN KEY (CustomerCategoryID)		REFERENCES Sales.CustomerCategories (CustomerCategoryID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_BuyingGroupID_BuyingGroups
	FOREIGN KEY (BuyingGroupID)				REFERENCES Sales.BuyingGroups (BuyingGroupID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_PrimaryContactPersonID_People
	FOREIGN KEY (PrimaryContactPersonID)	REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_AlternateContactPersonID_People
	FOREIGN KEY (AlternateContactPersonID)	REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_DeliveryMethodID_DeliveryMethods
	FOREIGN KEY (DeliveryMethodID)			REFERENCES Application.DeliveryMethods (DeliveryMethodID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_DeliveryCityID_Cities
	FOREIGN KEY (DeliveryCityID)			REFERENCES Application.Cities (CityID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_PostalCityID_Cities
	FOREIGN KEY (PostalCityID)				REFERENCES Application.Cities (CityID);
ALTER TABLE Sales.Customers				ADD CONSTRAINT FK_Customers_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Orders				ADD CONSTRAINT FK_Orders_CustomerID_Customers
	FOREIGN KEY (CustomerID)				REFERENCES Sales.Customers (CustomerID);
ALTER TABLE Sales.Orders				ADD CONSTRAINT FK_Orders_SalespersonPersonID_People
	FOREIGN KEY (SalespersonPersonID)		REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Orders				ADD CONSTRAINT FK_Orders_PickedByPersonID_People
	FOREIGN KEY (PickedByPersonID)			REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Orders				ADD CONSTRAINT FK_Orders_ContactPersonID_People
	FOREIGN KEY (ContactPersonID)			REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Orders				ADD CONSTRAINT FK_Orders_BackorderOrderID_Orders
	FOREIGN KEY (BackorderOrderID)			REFERENCES Sales.Orders (OrderID);
ALTER TABLE Sales.Orders				ADD CONSTRAINT FK_Orders_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.OrderLines			ADD CONSTRAINT FK_OrderLines_OrderID_Orders
	FOREIGN KEY (OrderID)					REFERENCES Sales.Orders (OrderID);
ALTER TABLE Sales.OrderLines			ADD CONSTRAINT FK_OrderLines_StockItemID_StockItems
	FOREIGN KEY (StockItemID)				REFERENCES Warehouse.StockItems (StockItemID);
ALTER TABLE Sales.OrderLines			ADD CONSTRAINT FK_OrderLines_PackageTypeID_PackageTypes
	FOREIGN KEY (PackageTypeID)				REFERENCES Warehouse.PackageTypes (PackageTypeID);
ALTER TABLE Sales.OrderLines			ADD CONSTRAINT FK_OrderLines_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_CustomerID_Customers
	FOREIGN KEY (CustomerID)				REFERENCES Sales.Customers (CustomerID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_BillToCustomerID_Customers
	FOREIGN KEY (BillToCustomerID)			REFERENCES Sales.Customers (CustomerID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_OrderID_Orders
	FOREIGN KEY (OrderID)					REFERENCES Sales.Orders (OrderID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_DeliveryMethodID_DeliveryMethods
	FOREIGN KEY (DeliveryMethodID)			REFERENCES Application.DeliveryMethods (DeliveryMethodID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_ContactPersonID_People
	FOREIGN KEY (ContactPersonID)			REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_AccountsPersonID_People
	FOREIGN KEY (AccountsPersonID)			REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_SalespersonPersonID_People
	FOREIGN KEY (SalespersonPersonID)		REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_PackedByPersonID_People
	FOREIGN KEY (PackedByPersonID)			REFERENCES Application.People (PersonID);
ALTER TABLE Sales.Invoices				ADD CONSTRAINT FK_Invoices_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.InvoiceLines			ADD CONSTRAINT FK_InvoiceLines_InvoiceID_Invoices
	FOREIGN KEY (InvoiceID)					REFERENCES Sales.Invoices (InvoiceID);
ALTER TABLE Sales.InvoiceLines			ADD CONSTRAINT FK_InvoiceLines_StockItemID_StockItems
	FOREIGN KEY (StockItemID)				REFERENCES Warehouse.StockItems (StockItemID);
ALTER TABLE Sales.InvoiceLines			ADD CONSTRAINT FK_InvoiceLines_PackageTypeID_PackageTypes
	FOREIGN KEY (PackageTypeID)				REFERENCES Warehouse.PackageTypes (PackageTypeID);
ALTER TABLE Sales.InvoiceLines			ADD CONSTRAINT FK_InvoiceLines_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT FK_CustomerTransactions_CustomerID_Customers
	FOREIGN KEY (CustomerID)				REFERENCES Sales.Customers (CustomerID);
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT FK_CustomerTransactions_TransactionTypeID_TransactionTypes
	FOREIGN KEY (TransactionTypeID)			REFERENCES Application.TransactionTypes (TransactionTypeID);
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT FK_CustomerTransactions_InvoiceID_Invoices
	FOREIGN KEY (InvoiceID)					REFERENCES Sales.Invoices (InvoiceID);
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT FK_CustomerTransactions_PaymentMethodID_PaymentMethods
	FOREIGN KEY (PaymentMethodID)			REFERENCES Application.PaymentMethods (PaymentMethodID);
ALTER TABLE Sales.CustomerTransactions	ADD CONSTRAINT FK_CustomerTransactions_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT FK_SpecialDeals_StockItemID_StockItems
	FOREIGN KEY (StockItemID)				REFERENCES Warehouse.StockItems (StockItemID);
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT FK_SpecialDeals_CustomerID_Customers
	FOREIGN KEY (CustomerID)				REFERENCES Sales.Customers (CustomerID);
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT FK_SpecialDeals_BuyingGroupID_BuyingGroups
	FOREIGN KEY (BuyingGroupID)				REFERENCES Sales.BuyingGroups (BuyingGroupID);
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT FK_SpecialDeals_CustomerCategoryID_CustomerCategories
	FOREIGN KEY (CustomerCategoryID)		REFERENCES Sales.CustomerCategories (CustomerCategoryID);
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT FK_SpecialDeals_StockGroupID_StockGroups
	FOREIGN KEY (StockGroupID)				REFERENCES Warehouse.StockGroups (StockGroupID);
ALTER TABLE Sales.SpecialDeals			ADD CONSTRAINT FK_SpecialDeals_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)				REFERENCES Application.People (PersonID);

--\\ Warehouse //--
-------------------
ALTER TABLE Warehouse.Colors				ADD CONSTRAINT FK_Colors_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)			REFERENCES Application.People (PersonID);
ALTER TABLE Warehouse.PackageTypes			ADD CONSTRAINT FK_PackageTypes_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)			REFERENCES Application.People (PersonID);
ALTER TABLE Warehouse.StockGroups			ADD CONSTRAINT FK_StockGroups_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)			REFERENCES Application.People (PersonID);
ALTER TABLE Warehouse.StockItems			ADD CONSTRAINT FK_StockItems_SupplierID_Suppliers
	FOREIGN KEY (SupplierID)			REFERENCES Purchasing.Suppliers (SupplierID);
ALTER TABLE Warehouse.StockItems			ADD CONSTRAINT FK_StockItems_ColorID_Colors
	FOREIGN KEY (ColorID)				REFERENCES Warehouse.Colors (ColorID);
ALTER TABLE Warehouse.StockItems			ADD CONSTRAINT FK_StockItems_UnitPackageID_PackageTypes
	FOREIGN KEY (UnitPackageID)			REFERENCES Warehouse.PackageTypes (PackageTypeID);
ALTER TABLE Warehouse.StockItems			ADD CONSTRAINT FK_StockItems_OuterPackageID_PackageTypes
	FOREIGN KEY (OuterPackageID)		REFERENCES Warehouse.PackageTypes (PackageTypeID);
ALTER TABLE Warehouse.StockItems			ADD CONSTRAINT FK_StockItems_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)			REFERENCES Application.People (PersonID);
ALTER TABLE Warehouse.StockItemHoldings		ADD CONSTRAINT FK_StockItemHoldings_StockItemID_StockItems
	FOREIGN KEY (StockItemID)			REFERENCES Warehouse.StockItems (StockItemID);
ALTER TABLE Warehouse.StockItemHoldings		ADD CONSTRAINT FK_StockItemHoldings_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)			REFERENCES Application.People (PersonID);
ALTER TABLE Warehouse.StockItemStockGroups	ADD CONSTRAINT FK_StockItemStockGroups_StockItemID_StockItems
	FOREIGN KEY (StockItemID)			REFERENCES Warehouse.StockItems (StockItemID);
ALTER TABLE Warehouse.StockItemStockGroups	ADD CONSTRAINT FK_StockItemStockGroups_StockGroupID_StockGroups
	FOREIGN KEY (StockGroupID)			REFERENCES Warehouse.StockGroups (StockGroupID);
ALTER TABLE Warehouse.StockItemStockGroups	ADD CONSTRAINT FK_StockItemStockGroups_LastEditedBy_People
	FOREIGN KEY (LastEditedBy)			REFERENCES Application.People (PersonID);
GO

---------------------------------------------------------------
-- TASK 7: Indexes — nonclustered index on every FK column.
--		   SQL Server does NOT index FK columns automatically,
--		   and they drive almost every join in this database.
--		   Naming: IX_Schema_Table_Column
---------------------------------------------------------------
--\\ Application //--
---------------------
CREATE NONCLUSTERED INDEX IX_Application_People_LastEditedBy				ON Application.People (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_Countries_LastEditedBy				ON Application.Countries (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_StateProvinces_CountryID			ON Application.StateProvinces (CountryID);
CREATE NONCLUSTERED INDEX IX_Application_StateProvinces_LastEditedBy		ON Application.StateProvinces (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_Cities_StateProvinceID				ON Application.Cities (StateProvinceID);
CREATE NONCLUSTERED INDEX IX_Application_Cities_LastEditedBy				ON Application.Cities (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_DeliveryMethods_LastEditedBy		ON Application.DeliveryMethods (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_PaymentMethods_LastEditedBy		ON Application.PaymentMethods (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_TransactionTypes_LastEditedBy		ON Application.TransactionTypes (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Application_SystemParameters_DeliveryCityID	ON Application.SystemParameters (DeliveryCityID);
CREATE NONCLUSTERED INDEX IX_Application_SystemParameters_PostalCityID		ON Application.SystemParameters (PostalCityID);
CREATE NONCLUSTERED INDEX IX_Application_SystemParameters_LastEditedBy		ON Application.SystemParameters (LastEditedBy);

--\\ Purchasing //--
--------------------
CREATE NONCLUSTERED INDEX IX_Purchasing_SupplierCategories_LastEditedBy			ON Purchasing.SupplierCategories (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_SupplierCategoryID			ON Purchasing.Suppliers (SupplierCategoryID);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_PrimaryContactPersonID		ON Purchasing.Suppliers (PrimaryContactPersonID);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_AlternateContactPersonID		ON Purchasing.Suppliers (AlternateContactPersonID);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_DeliveryMethodID				ON Purchasing.Suppliers (DeliveryMethodID);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_DeliveryCityID				ON Purchasing.Suppliers (DeliveryCityID);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_PostalCityID					ON Purchasing.Suppliers (PostalCityID);
CREATE NONCLUSTERED INDEX IX_Purchasing_Suppliers_LastEditedBy					ON Purchasing.Suppliers (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrders_SupplierID				ON Purchasing.PurchaseOrders (SupplierID);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrders_DeliveryMethodID			ON Purchasing.PurchaseOrders (DeliveryMethodID);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrders_ContactPersonID			ON Purchasing.PurchaseOrders (ContactPersonID);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrders_LastEditedBy				ON Purchasing.PurchaseOrders (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrderLines_PurchaseOrderID		ON Purchasing.PurchaseOrderLines (PurchaseOrderID);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrderLines_StockItemID			ON Purchasing.PurchaseOrderLines (StockItemID);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrderLines_PackageTypeID		ON Purchasing.PurchaseOrderLines (PackageTypeID);
CREATE NONCLUSTERED INDEX IX_Purchasing_PurchaseOrderLines_LastEditedBy			ON Purchasing.PurchaseOrderLines (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Purchasing_SupplierTransactions_SupplierID			ON Purchasing.SupplierTransactions (SupplierID);
CREATE NONCLUSTERED INDEX IX_Purchasing_SupplierTransactions_TransactionTypeID	ON Purchasing.SupplierTransactions (TransactionTypeID);
CREATE NONCLUSTERED INDEX IX_Purchasing_SupplierTransactions_PurchaseOrderID	ON Purchasing.SupplierTransactions (PurchaseOrderID);
CREATE NONCLUSTERED INDEX IX_Purchasing_SupplierTransactions_PaymentMethodID	ON Purchasing.SupplierTransactions (PaymentMethodID);
CREATE NONCLUSTERED INDEX IX_Purchasing_SupplierTransactions_LastEditedBy		ON Purchasing.SupplierTransactions (LastEditedBy);

--\\ Sales //--
---------------
CREATE NONCLUSTERED INDEX IX_Sales_BuyingGroups_LastEditedBy				ON Sales.BuyingGroups (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerCategories_LastEditedBy			ON Sales.CustomerCategories (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_BillToCustomerID				ON Sales.Customers (BillToCustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_CustomerCategoryID				ON Sales.Customers (CustomerCategoryID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_BuyingGroupID					ON Sales.Customers (BuyingGroupID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_PrimaryContactPersonID			ON Sales.Customers (PrimaryContactPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_AlternateContactPersonID		ON Sales.Customers (AlternateContactPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_DeliveryMethodID				ON Sales.Customers (DeliveryMethodID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_DeliveryCityID					ON Sales.Customers (DeliveryCityID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_PostalCityID					ON Sales.Customers (PostalCityID);
CREATE NONCLUSTERED INDEX IX_Sales_Customers_LastEditedBy					ON Sales.Customers (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_Orders_CustomerID						ON Sales.Orders (CustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_Orders_SalespersonPersonID				ON Sales.Orders (SalespersonPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Orders_PickedByPersonID					ON Sales.Orders (PickedByPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Orders_ContactPersonID					ON Sales.Orders (ContactPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Orders_BackorderOrderID					ON Sales.Orders (BackorderOrderID);
CREATE NONCLUSTERED INDEX IX_Sales_Orders_LastEditedBy						ON Sales.Orders (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_OrderLines_OrderID						ON Sales.OrderLines (OrderID);
CREATE NONCLUSTERED INDEX IX_Sales_OrderLines_StockItemID					ON Sales.OrderLines (StockItemID);
CREATE NONCLUSTERED INDEX IX_Sales_OrderLines_PackageTypeID					ON Sales.OrderLines (PackageTypeID);
CREATE NONCLUSTERED INDEX IX_Sales_OrderLines_LastEditedBy					ON Sales.OrderLines (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_CustomerID						ON Sales.Invoices (CustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_BillToCustomerID				ON Sales.Invoices (BillToCustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_OrderID							ON Sales.Invoices (OrderID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_DeliveryMethodID				ON Sales.Invoices (DeliveryMethodID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_ContactPersonID					ON Sales.Invoices (ContactPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_AccountsPersonID				ON Sales.Invoices (AccountsPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_SalespersonPersonID				ON Sales.Invoices (SalespersonPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_PackedByPersonID				ON Sales.Invoices (PackedByPersonID);
CREATE NONCLUSTERED INDEX IX_Sales_Invoices_LastEditedBy					ON Sales.Invoices (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_InvoiceLines_InvoiceID					ON Sales.InvoiceLines (InvoiceID);
CREATE NONCLUSTERED INDEX IX_Sales_InvoiceLines_StockItemID					ON Sales.InvoiceLines (StockItemID);
CREATE NONCLUSTERED INDEX IX_Sales_InvoiceLines_PackageTypeID				ON Sales.InvoiceLines (PackageTypeID);
CREATE NONCLUSTERED INDEX IX_Sales_InvoiceLines_LastEditedBy				ON Sales.InvoiceLines (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerTransactions_CustomerID			ON Sales.CustomerTransactions (CustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerTransactions_TransactionTypeID	ON Sales.CustomerTransactions (TransactionTypeID);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerTransactions_InvoiceID			ON Sales.CustomerTransactions (InvoiceID);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerTransactions_PaymentMethodID		ON Sales.CustomerTransactions (PaymentMethodID);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerTransactions_LastEditedBy		ON Sales.CustomerTransactions (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Sales_SpecialDeals_StockItemID					ON Sales.SpecialDeals (StockItemID);
CREATE NONCLUSTERED INDEX IX_Sales_SpecialDeals_CustomerID					ON Sales.SpecialDeals (CustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_SpecialDeals_BuyingGroupID				ON Sales.SpecialDeals (BuyingGroupID);
CREATE NONCLUSTERED INDEX IX_Sales_SpecialDeals_CustomerCategoryID			ON Sales.SpecialDeals (CustomerCategoryID);
CREATE NONCLUSTERED INDEX IX_Sales_SpecialDeals_StockGroupID				ON Sales.SpecialDeals (StockGroupID);
CREATE NONCLUSTERED INDEX IX_Sales_SpecialDeals_LastEditedBy				ON Sales.SpecialDeals (LastEditedBy);

--\\ Warehouse //--
-------------------
CREATE NONCLUSTERED INDEX IX_Warehouse_Colors_LastEditedBy					ON Warehouse.Colors (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Warehouse_PackageTypes_LastEditedBy			ON Warehouse.PackageTypes (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockGroups_LastEditedBy				ON Warehouse.StockGroups (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItems_SupplierID				ON Warehouse.StockItems (SupplierID);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItems_ColorID					ON Warehouse.StockItems (ColorID);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItems_UnitPackageID				ON Warehouse.StockItems (UnitPackageID);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItems_OuterPackageID			ON Warehouse.StockItems (OuterPackageID);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItems_LastEditedBy				ON Warehouse.StockItems (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItemHoldings_LastEditedBy		ON Warehouse.StockItemHoldings (LastEditedBy);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItemStockGroups_StockItemID		ON Warehouse.StockItemStockGroups (StockItemID);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItemStockGroups_StockGroupID	ON Warehouse.StockItemStockGroups (StockGroupID);
CREATE NONCLUSTERED INDEX IX_Warehouse_StockItemStockGroups_LastEditedBy	ON Warehouse.StockItemStockGroups (LastEditedBy);
GO

PRINT '01_create_objects.sql completed: 5 schemas, 26 sequences, 45 tables, PKs, defaults, FKs, indexes.';
GO 