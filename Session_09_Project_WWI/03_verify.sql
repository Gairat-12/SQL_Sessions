

    -- 03_verify.sql
/*==============================================================================

  Project : Rebuild WideWorldImporters with DDL  
  Purpose : Prove the load is correct — compare actual row counts of all 45
            tables against the expected counts published in the data dictionary
            ("rows: N" next to each table name).
  How     : sys.tables + sys.partitions give the row count of every table in
            one query (no 45x COUNT(*)); LEFT JOIN to the expected list flags
            anything missing or mismatched. Result: 45 rows, Status = OK.
==============================================================================*/
USE WWI_Rebuild;
GO

WITH expected (SchemaName, TableName, ExpectedRows) AS (
    SELECT * FROM (VALUES
        (N'Application', N'Cities',                    37940),      (N'Application', N'Cities_Archive',               28),
        (N'Application', N'Countries',                   190),      (N'Application', N'Countries_Archive',            37),
        (N'Application', N'DeliveryMethods',              10),      (N'Application', N'DeliveryMethods_Archive',       1),
        (N'Application', N'PaymentMethods',                4),      (N'Application', N'PaymentMethods_Archive',        1),
        (N'Application', N'People',                     1111),      (N'Application', N'People_Archive',              961),
        (N'Application', N'StateProvinces',               53),      (N'Application', N'StateProvinces_Archive',      104),
        (N'Application', N'SystemParameters',              1),      (N'Application', N'TransactionTypes',             13),
        (N'Application', N'TransactionTypes_Archive',      1),      (N'Purchasing',  N'PurchaseOrderLines',         8367),
        (N'Purchasing',  N'PurchaseOrders',             2074),      (N'Purchasing',  N'SupplierCategories',            9),
        (N'Purchasing',  N'SupplierCategories_Archive',    1),      (N'Purchasing',  N'Suppliers',                    13),
        (N'Purchasing',  N'Suppliers_Archive',            13),      (N'Purchasing',  N'SupplierTransactions',       2438),
        (N'Sales',       N'BuyingGroups',                  2),      (N'Sales',       N'BuyingGroups_Archive',          0),
        (N'Sales',       N'CustomerCategories',            8),      (N'Sales',       N'CustomerCategories_Archive',    1),
        (N'Sales',       N'Customers',                   663),      (N'Sales',       N'Customers_Archive',            51),
        (N'Sales',       N'CustomerTransactions',       97147),     (N'Sales',       N'InvoiceLines',              228265),
        (N'Sales',       N'Invoices',                   70510),     (N'Sales',       N'OrderLines',                231412),
        (N'Sales',       N'Orders',                     73595),     (N'Sales',       N'SpecialDeals',                   2),
        (N'Warehouse',   N'ColdRoomTemperatures',           4),     (N'Warehouse',   N'Colors',                        36),
        (N'Warehouse',   N'Colors_Archive',                 1),     (N'Warehouse',   N'PackageTypes',                  14),
        (N'Warehouse',   N'PackageTypes_Archive',           0),     (N'Warehouse',   N'StockGroups',                   10),
        (N'Warehouse',   N'StockGroups_Archive',            1),     (N'Warehouse',   N'StockItemHoldings',             227),
        (N'Warehouse',   N'StockItems',                    227),    (N'Warehouse',   N'StockItems_Archive',            444),
        (N'Warehouse',   N'StockItemStockGroups',          442)
    ) AS v (SchemaName, TableName, ExpectedRows)
),
actual AS (
    SELECT s.name AS SchemaName,
           t.name AS TableName,
           SUM(p.rows) AS ActualRows
    FROM sys.tables t
    JOIN sys.schemas s    ON s.schema_id = t.schema_id
    JOIN sys.partitions p ON p.object_id = t.object_id
    WHERE p.index_id IN (0, 1)          -- heap or clustered index = base rows
      AND s.name <> N'Staging'          -- ignore leftover staging on failed runs
    GROUP BY s.name, t.name
)
SELECT e.SchemaName + N'.' + e.TableName          AS [Table],
       e.ExpectedRows                              AS Expected,
       ISNULL(a.ActualRows, 0)                     AS Actual,
       CASE WHEN a.ActualRows = e.ExpectedRows THEN N'OK'
            WHEN a.ActualRows IS NULL           THEN N'MISSING TABLE'
            ELSE N'MISMATCH' END                   AS Status
FROM expected e
LEFT JOIN actual a
  ON a.SchemaName = e.SchemaName AND a.TableName = e.TableName
ORDER BY CASE WHEN a.ActualRows = e.ExpectedRows THEN 1 ELSE 0 END,  -- problems first
         e.SchemaName, e.TableName;

-- One-line summary 
SELECT COUNT(*)                                                     AS TablesChecked,
       SUM(CASE WHEN a.ActualRows = e.ExpectedRows THEN 1 ELSE 0 END) AS Passed
FROM (SELECT * FROM (VALUES
        (N'Application',N'Cities',37940),               (N'Application',N'Cities_Archive',28),
        (N'Application',N'Countries',190),              (N'Application',N'Countries_Archive',37),
        (N'Application',N'DeliveryMethods',10),         (N'Application',N'DeliveryMethods_Archive',1), 
        (N'Application',N'PaymentMethods',4),           (N'Application',N'PaymentMethods_Archive',1),
        (N'Application',N'People',1111),                (N'Application',N'People_Archive',961),
        (N'Application',N'StateProvinces',53),          (N'Application',N'StateProvinces_Archive',104),
        (N'Application',N'SystemParameters',1),         (N'Application',N'TransactionTypes',13),
        (N'Application',N'TransactionTypes_Archive',1), (N'Purchasing',N'PurchaseOrderLines',8367),
        (N'Purchasing',N'PurchaseOrders',2074),         (N'Purchasing',N'SupplierCategories',9),
        (N'Purchasing',N'SupplierCategories_Archive',1),(N'Purchasing',N'Suppliers',13),
        (N'Purchasing',N'Suppliers_Archive',13),        (N'Purchasing',N'SupplierTransactions',2438),
        (N'Sales',N'BuyingGroups',2),                   (N'Sales',N'BuyingGroups_Archive',0),
        (N'Sales',N'CustomerCategories',8),             (N'Sales',N'CustomerCategories_Archive',1),
        (N'Sales',N'Customers',663),                    (N'Sales',N'Customers_Archive',51),
        (N'Sales',N'CustomerTransactions',97147),       (N'Sales',N'InvoiceLines',228265),
        (N'Sales',N'Invoices',70510),                   (N'Sales',N'OrderLines',231412),
        (N'Sales',N'Orders',73595),                     (N'Sales',N'SpecialDeals',2),
        (N'Warehouse',N'ColdRoomTemperatures',4),       (N'Warehouse',N'Colors',36),
        (N'Warehouse',N'Colors_Archive',1),             (N'Warehouse',N'PackageTypes',14),
        (N'Warehouse',N'PackageTypes_Archive',0),       (N'Warehouse',N'StockGroups',10),
        (N'Warehouse',N'StockGroups_Archive',1),        (N'Warehouse',N'StockItemHoldings',227),
        (N'Warehouse',N'StockItems',227),               (N'Warehouse',N'StockItems_Archive',444),
        (N'Warehouse',N'StockItemStockGroups',442)
      ) AS v (SchemaName, TableName, ExpectedRows)) e
LEFT JOIN (
    SELECT s.name AS SchemaName, t.name AS TableName, SUM(p.rows) AS ActualRows
    FROM sys.tables t
    JOIN sys.schemas s    ON s.schema_id = t.schema_id
    JOIN sys.partitions p ON p.object_id = t.object_id
    WHERE p.index_id IN (0, 1) AND s.name <> N'Staging'
    GROUP BY s.name, t.name
) a ON a.SchemaName = e.SchemaName AND a.TableName = e.TableName;
GO

    -- UNION ALL OPTION: one merged result grid --
    -----------------------------------------------
SELECT 'Application.Cities' AS TableName, COUNT(*) AS [RowCount] FROM Application.Cities
UNION ALL
SELECT 'Application.Cities_Archive', COUNT(*) FROM Application.Cities_Archive
UNION ALL
SELECT 'Application.Countries', COUNT(*) FROM Application.Countries
UNION ALL
SELECT 'Application.Countries_Archive', COUNT(*) FROM Application.Countries_Archive
UNION ALL
SELECT 'Application.DeliveryMethods', COUNT(*) FROM Application.DeliveryMethods
UNION ALL
SELECT 'Application.DeliveryMethods_Archive', COUNT(*) FROM Application.DeliveryMethods_Archive
UNION ALL
SELECT 'Application.PaymentMethods', COUNT(*) FROM Application.PaymentMethods
UNION ALL
SELECT 'Application.PaymentMethods_Archive', COUNT(*) FROM Application.PaymentMethods_Archive
UNION ALL
SELECT 'Application.People', COUNT(*) FROM Application.People
UNION ALL
SELECT 'Application.People_Archive', COUNT(*) FROM Application.People_Archive
UNION ALL
SELECT 'Application.StateProvinces', COUNT(*) FROM Application.StateProvinces
UNION ALL
SELECT 'Application.StateProvinces_Archive', COUNT(*) FROM Application.StateProvinces_Archive
UNION ALL
SELECT 'Application.SystemParameters', COUNT(*) FROM Application.SystemParameters
UNION ALL
SELECT 'Application.TransactionTypes', COUNT(*) FROM Application.TransactionTypes
UNION ALL
SELECT 'Application.TransactionTypes_Archive', COUNT(*) FROM Application.TransactionTypes_Archive
UNION ALL
SELECT 'Purchasing.PurchaseOrderLines', COUNT(*) FROM Purchasing.PurchaseOrderLines
UNION ALL
SELECT 'Purchasing.PurchaseOrders', COUNT(*) FROM Purchasing.PurchaseOrders
UNION ALL
SELECT 'Purchasing.SupplierCategories', COUNT(*) FROM Purchasing.SupplierCategories
UNION ALL
SELECT 'Purchasing.SupplierCategories_Archive', COUNT(*) FROM Purchasing.SupplierCategories_Archive
UNION ALL
SELECT 'Purchasing.Suppliers', COUNT(*) FROM Purchasing.Suppliers
UNION ALL
SELECT 'Purchasing.Suppliers_Archive', COUNT(*) FROM Purchasing.Suppliers_Archive
UNION ALL
SELECT 'Purchasing.SupplierTransactions', COUNT(*) FROM Purchasing.SupplierTransactions
UNION ALL
SELECT 'Sales.BuyingGroups', COUNT(*) FROM Sales.BuyingGroups
UNION ALL
SELECT 'Sales.BuyingGroups_Archive', COUNT(*) FROM Sales.BuyingGroups_Archive
UNION ALL
SELECT 'Sales.CustomerCategories', COUNT(*) FROM Sales.CustomerCategories
UNION ALL
SELECT 'Sales.CustomerCategories_Archive', COUNT(*) FROM Sales.CustomerCategories_Archive
UNION ALL
SELECT 'Sales.Customers', COUNT(*) FROM Sales.Customers
UNION ALL
SELECT 'Sales.Customers_Archive', COUNT(*) FROM Sales.Customers_Archive
UNION ALL
SELECT 'Sales.CustomerTransactions', COUNT(*) FROM Sales.CustomerTransactions
UNION ALL
SELECT 'Sales.InvoiceLines', COUNT(*) FROM Sales.InvoiceLines
UNION ALL
SELECT 'Sales.Invoices', COUNT(*) FROM Sales.Invoices
UNION ALL
SELECT 'Sales.OrderLines', COUNT(*) FROM Sales.OrderLines
UNION ALL
SELECT 'Sales.Orders', COUNT(*) FROM Sales.Orders
UNION ALL
SELECT 'Sales.SpecialDeals', COUNT(*) FROM Sales.SpecialDeals
UNION ALL
SELECT 'Warehouse.ColdRoomTemperatures', COUNT(*) FROM Warehouse.ColdRoomTemperatures
UNION ALL
SELECT 'Warehouse.Colors', COUNT(*) FROM Warehouse.Colors
UNION ALL
SELECT 'Warehouse.Colors_Archive', COUNT(*) FROM Warehouse.Colors_Archive
UNION ALL
SELECT 'Warehouse.PackageTypes', COUNT(*) FROM Warehouse.PackageTypes
UNION ALL
SELECT 'Warehouse.PackageTypes_Archive', COUNT(*) FROM Warehouse.PackageTypes_Archive
UNION ALL
SELECT 'Warehouse.StockGroups', COUNT(*) FROM Warehouse.StockGroups
UNION ALL
SELECT 'Warehouse.StockGroups_Archive', COUNT(*) FROM Warehouse.StockGroups_Archive
UNION ALL
SELECT 'Warehouse.StockItemHoldings', COUNT(*) FROM Warehouse.StockItemHoldings
UNION ALL
SELECT 'Warehouse.StockItems', COUNT(*) FROM Warehouse.StockItems
UNION ALL
SELECT 'Warehouse.StockItems_Archive', COUNT(*) FROM Warehouse.StockItems_Archive
UNION ALL
SELECT 'Warehouse.StockItemStockGroups', COUNT(*) FROM Warehouse.StockItemStockGroups
ORDER BY TableName;
GO