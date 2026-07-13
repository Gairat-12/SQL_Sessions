
		
		
		/* SQL Practice Session 5 */

	-- NOTE:--
	-- The tables and columns used in this practice session are not available in my current database.
	-- To practice the same concepts, existing tables will be copied with _S5 names and used in adapted solutions.
	-- All INSERT, UPDATE, and DELETE statements will be done on the _S5 copies, not the original tables.

	-------------------------------------------------
	-- Part A - Creating test tables with SELECT INTO
	-------------------------------------------------
/* Q1. Your first SELECT INTO (full copy). 
Use a single SELECT INTO statement to create a brand-new table named Carrier_Copy_S5 that is a complete copy of every row and column in Carrier_S5. 
Then run a SELECT to confirm it has the same number of rows. 
In one sentence, explain what SELECT INTO creates for you and why the new table does NOT inherit the primary key, identity property, foreign keys, or defaults of the original. */
	SELECT *
	INTO DimCarrier_S5
	FROM DimCarrier;

	SELECT COUNT(*) AS OriginalRowCount
	FROM DimCarrier;

	SELECT COUNT(*) AS CopyRowCount
	FROM DimCarrier_S5;
-- SELECT INTO creates a new table from the result of a SELECT statement.
-- DimCarrier_S5 has the same rows and columns as DimCarrier, but it does not inherit keys, constraints, identity properties, or default	 values.

/* Q2. A partial copy with selected columns and a WHERE clause. 
Use SELECT INTO to create a table named CACarriers_S5 that contains only 
DotNumber, LegalName, PhyCity, and FleetSize, and only for carriers whose PhyState = 'CA'. 
In one sentence, explain why SELECT INTO is handy for quickly building a small test table you can experiment on without touching the original. */
	SELECT
		DOT_NUMBER AS DotNumber,
		LEGAL_NAME AS LegalName,
		PHY_CITY AS PhyCity,
		FLEETSIZE AS FleetSize
	INTO CACarriers_S5
	FROM DimCarrier_S5
	WHERE PHY_STATE = 'CA';
	
	SELECT COUNT(*) AS CACount
	FROM CACarriers_S5;
	
	SELECT DISTINCT PHY_STATE
	FROM dbo.DimCarrier_S5
	WHERE DOT_NUMBER IN
	(SELECT DotNumber
    FROM dbo.CACarriers_S5);
	-- SELECT INTO is useful because it lets us quickly create a smaller practice table
	-- from selected rows and columns without changing the original table.


/* Q3. A summary table, then clean up. 
Use SELECT INTO to build a table named StateSummary_S5 that, for each PhyState, stores the state code, 
the carrier count (alias CarrierCount), and the average crash rate (alias AvgCrashRate). 
Then write the statement that DROPs the StateSummary_S5 table you just created. 
In one sentence, say why you must give every calculated column (COUNT, AVG) an alias in a SELECT INTO statement. */
	
		-- CREATING A NEW TABLE
	SELECT	
		dc.PHY_STATE AS StateCode,
		COUNT(*) AS CarrierCount,
		AVG(fc.RECORDABLE_CRASH_RATE) AS AvgCrashRate
	INTO StateSummary_S5
	FROM DimCarrier_S5 dc
		JOIN FactCarrierOperation fc ON dc.DOT_NUMBER = fc.DOT_NUMBER
	GROUP BY dc.PHY_STATE;
	 
	 -- DELETING ENTIRE TABLE 
	DROP TABLE StateSummary_S5
	-- Calculated columns such as COUNT and AVG must have aliases because the new table created by SELECT INTO uses those aliases as the column names.

		-------------------------------
		-- Part B - Inserting new rows
		-------------------------------
/*Q4. Insert a single row. Insert one new carrier into Carrier_S5: 
DotNumber 1017, LegalName 'Mountain Pass Freight', DbaName 'MPF', PhyCity 'Los Angeles', PhyState 'CA', FleetSize 35, CrashRate 1.500, 
StatusCode 'A'. Write an explicit column list in the INSERT and a matching VALUES clause, but do NOT include CarrierID or AddDate. 
In one sentence, explain why you leave the CarrierID (an IDENTITY column) out of the column list. */
	
INSERT INTO DimCarrier_S5
    (DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE, STATUS_CODE)
VALUES
    (1017, 'Mountain Pass Freight', 'MPF', 'Los Angeles', 'CA', 35, 'A');

	SELECT
    DOT_NUMBER,
    LEGAL_NAME,
    DBA_NAME,
    PHY_CITY,
    PHY_STATE,
    FLEETSIZE,
    STATUS_CODE
FROM dbo.DimCarrier_S5
WHERE DOT_NUMBER = 1005;
	-- I used an explicit column list so SQL Server knows exactly which columns get values.
	-- My DimCarrier_S5 table does not have CarrierID or CrashRate, so those columns are not included.
	-- ADD_DATE is also left out because this question is practicing inserting only selected columns.


/* Q5. Insert multiple rows in one statement. With a single INSERT statement, add three carriers at once (one VALUES clause with three comma-separated rows): 
DotNumber 1018 'Cactus Line Carriers' in 'AZ' with FleetSize 20; DotNumber 1019 'Gulf Coast Haulers' in 'TX' with FleetSize 80; and DotNumber 1020 
'Great Plains Freight' in 'IL' with FleetSize 65. Leave DbaName and CrashRate as NULL, and let StatusCode default. 
In one sentence, state why inserting multiple rows in one statement is preferable to running three separate INSERT statements. */
	
	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_STATE, FLEETSIZE)
	VALUES
		(1016, 'Cactus Line Carriers', NULL, 'AZ', 'A'),
		(1019, 'Gulf Coast Haulers', NULL, 'TX', 'C'),
		(1020, 'Great Plains Freight', NULL, 'IL', 'B');
	-- I'm using DOT_NUMBER 1016 instead of 1018 because its already existed in my DimCarrier_S5 table.
	-- This avoids creating duplicate carrier records with the same DOT_NUMBER.
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		DBA_NAME,
		PHY_STATE,
		FLEETSIZE,
		STATUS_CODE
	FROM DimCarrier_S5
	WHERE DOT_NUMBER IN (1016, 1019, 1020)
	ORDER BY DOT_NUMBER;
	-- Since my FLEETSIZE column uses codes A, B, C, not numbers 20 or 80, I’ll adapt the FleetSizes to valid codes.
	-- Inserting multiple rows in one INSERT statement is better than three separate INSERT statements
	-- because the code is shorter, easier to read, and SQL Server can process the rows as one set.


/*Q6. Insert default values. Insert carrier DotNumber 1021, LegalName 'Default Test Lines', PhyState 'OH', FleetSize 10 - 
but do NOT supply StatusCode or AddDate, so both pick up their column DEFAULTs. 
Then write a second version of the same insert that supplies the DEFAULT keyword explicitly for StatusCode instead of omitting the column. 
In one sentence, explain the difference between omitting a column entirely and writing the DEFAULT keyword for it. */
	
	-- 1: omit STATUS_CODE and ADD_DATE. 
	-- If defaults exist, SQL Server applies them automatically.
	INSERT INTO DimCarrier_S5 (DOT_NUMBER, LEGAL_NAME, PHY_STATE, FLEETSIZE)
	VALUES (1021, 'Default Test Lines', 'OH', 'A');

	-- 2: explicitly use DEFAULT for STATUS_CODE.
	-- DON'T EXC this after Version 1 unless you change DOT_NUMBER or reset the table,
	-- because DOT_NUMBER 1021 was already inserted above.
	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, PHY_STATE, FLEETSIZE, STATUS_CODE)
	VALUES
		(1021, 'Default Test Lines', 'OH', 'A', DEFAULT);

	-- Omitting a column means SQL Server will use the column default if one exists.
	-- Writing DEFAULT means I am explicitly asking SQL Server to use the default for that column.
	-- Because DimCarrier_S5 was created with SELECT INTO, it may not have inherited default values,
	-- so STATUS_CODE and ADD_DATE may show NULL instead of an automatic default.


/*Q7. Insert null values. Insert carrier DotNumber 1022, LegalName 'Null Test Transport', PhyState 'GA', FleetSize 15, 
with DbaName and CrashRate explicitly set to NULL. 
In one sentence, explain when you may simply leave a nullable column out of the column list versus when you must list it and pass NULL. */
	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_STATE, FLEETSIZE)
	VALUES
		(1022, 'Null Test Transport', NULL, 'GA', 'A');
	-- EXPL: A nullable column may be omitted when NULL is acceptable, 
	-- but it must be included in the INSERT statement when NULL needs to be assigned explicitly.


/*Q8. Insert rows selected from another table (INSERT ... SELECT). Copy the brand-new carriers from CarrierStaging_S5 into Carrier_S5 - that is, 
insert only the staging rows whose DotNumber does not already exist in Carrier_S5 (DotNumbers 2001-2004). Use INSERT ... SELECT with a NOT EXISTS 
(or NOT IN) subquery so already-present carriers are skipped, mapping the staging columns to DotNumber, LegalName, DbaName, PhyCity, PhyState, FleetSize, and CrashRate. 
In one sentence, explain why the column list of the INSERT must line up, in order and data type, with the columns the SELECT returns. */

	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE)
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.DBA_NAME,
		dc.PHY_CITY,
		dc.PHY_STATE,
		dc.FLEETSIZE
	FROM dbo.DimCarrier AS dc
	WHERE NOT EXISTS (SELECT 1
    FROM DimCarrier_S5 AS s5
    WHERE s5.DOT_NUMBER = dc.DOT_NUMBER);

-- INSERT SELECT copies rows from another table.
-- NOT EXISTS skips rows that already have the same columns in DimCarrier_S5.
-- The INSERT columns and SELECT columns must match in the same order and compatible data types.
-- This may insert 0 rows if all source rows already exist, but it still practices the concept.
	SELECT @@ROWCOUNT AS RowsInserted;

/*Q9. INSERT ... SELECT into the child table. 
For every carrier whose StatusCode is 'I' (inactive), add one row to Review_S5 with ReviewType 'A', 
ReviewDate of today (use CAST(SYSDATETIME() AS date) or a literal), and the carrier's current CrashRate. 
Use INSERT ... SELECT that reads CarrierID and CrashRate from Carrier_S5 with the appropriate WHERE clause. 
In one sentence, explain why this is safer and faster than looking up each inactive carrier and inserting its review by hand. */
	-- EXPL: INSERT ... SELECT is safer and faster than inserting rows one at a time because it processes all matching rows in one statement.

	-- Creating FactCarrierOperation_S5 is a practice copy of FactCarrierOperation.
	SELECT *
	INTO FactCarrierOperation_S5
	FROM FactCarrierOperation;

	INSERT INTO FactCarrierOperation_S5
	 (DOT_NUMBER, REVIEW_TYPE, REVIEW_DATE, RECORDABLE_CRASH_RATE)
	SELECT
		dc.DOT_NUMBER,'A',
    CAST(SYSDATETIME() AS date),
    fco.RECORDABLE_CRASH_RATE
	FROM DimCarrier_S5 AS dc
		JOIN FactCarrierOperation_S5 AS fco ON dc.DOT_NUMBER = fco.DOT_NUMBER
	WHERE dc.STATUS_CODE = 'I';

SELECT COUNT(*) AS InsertedRows
FROM FactCarrierOperation_S5
WHERE REVIEW_TYPE = 'A'
  AND REVIEW_DATE = CAST(SYSDATETIME() AS date);
	-- EXPL: 
	-- INSERT ... SELECT is safer and faster than inserting rows one at a time because it processes all matching rows in one statement.
	-- JOIN is used because STATUS_CODE is in DimCarrier_S5 and RECORDABLE_CRASH_RATE is in FactCarrierOperation_S5.

/*Q10. Capture the generated identity value. Insert carrier DotNumber 1023, LegalName 'Identity Capture Co', PhyState 'PA', FleetSize 50. 
Then, in the same batch, return the CarrierID that SQL Server generated for it - do this two ways: 
(a) by selecting SCOPE_IDENTITY(), and (b) by adding an OUTPUT clause (OUTPUT inserted.CarrierID) to the INSERT itself. 
In one sentence, explain why SCOPE_IDENTITY() is preferred over @@IDENTITY for getting back the value you just inserted. */
	
	-- CarrierID is an IDENTITY column in the PDF, but DimCarrier_S5 does not have it.
	-- DOT_NUMBER is used as the available carrier identifier, so the identity-capture part cannot be demonstrated.
	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, PHY_STATE, FLEETSIZE)
	VALUES (1023, 'Identity Capture Co', 'PA', 'A');

	-- VERIFYING
	SELECT *
	FROM DimCarrier_S5
	WHERE DOT_NUMBER = 1023;
	-- EXPL: SCOPE_IDENTITY() is used only when SQL Server generates an identity value.
	-- DimCarrier_S5 does not have an identity column, so DOT_NUMBER is inserted and checked directly.


	-- Part C - Modifying existing rows with UPDATE
	------------------------------------------------
/* Q11. A basic single-column update. Set the StatusCode of the carrier whose DotNumber is 1005 to 'A'. 
First write the SELECT that shows that one row, then write the UPDATE with the same WHERE clause. 
In one sentence, explain why writing the SELECT first is a safety habit for every UPDATE. */
	
	-- Writing the SELECT first is a safety habit because it shows exactly which row will be changed before running the UPDATE.
	-- First check whether DOT_NUMBER 1005 exists.
	SELECT *
	FROM DimCarrier_S5
	WHERE DOT_NUMBER = 1005;

	-- DOT_NUMBER 1005 did not exist in DimCarrier_S5.
	-- Insert it first so Q11 can practice updating STATUS_CODE from 'I' to 'A'.
	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, PHY_STATE, FLEETSIZE, STATUS_CODE)
	VALUES (1005, 'Test Carrier', 'CA', 'A', 'I');

	-- Update row
	UPDATE DimCarrier_S5
	SET STATUS_CODE = 'A'
	WHERE DOT_NUMBER = 1005;

	-- Verifying
	SELECT DOT_NUMBER, LEGAL_NAME, DBA_NAME, STATUS_CODE
	FROM DimCarrier_S5
	WHERE DOT_NUMBER = 1005;


/* Q12. Update several columns at once. 
For the carrier whose DotNumber is 1003, update three columns in a single UPDATE: 
set DbaName to 'Sunset Express', set FleetSize to 40, and set StatusCode to 'A'. 
In one sentence, state why you separate the assignments in the SET clause with commas rather than writing three UPDATE statements. */
	-- EXPL: Commas let one UPDATE change several columns in the same row at once.
		UPDATE DimCarrier_S5
	SET DBA_NAME = 'Sunset Express',
		FLEETSIZE = 'A',
		STATUS_CODE = 'A'
	WHERE DOT_NUMBER = 1005;

	-- This works, but it updates the same row three separate times.
		UPDATE DimCarrier_S5
	SET DBA_NAME = 'Sunset Express'
	WHERE DOT_NUMBER = 1005;

		UPDATE DimCarrier_S5
	SET FLEETSIZE = 'A'
	WHERE DOT_NUMBER = 1005;

		UPDATE DimCarrier_S5
	SET STATUS_CODE = 'A'
	WHERE DOT_NUMBER = 1005;

/* Q13. Update using an expression. 
Increase FleetSize by 10 percent (rounded to a whole number) for every carrier whose PhyState is 'TX'. 
Use an expression in the SET clause that refers to the column's current value. 
In one sentence, explain why SET FleetSize = FleetSize * 1.10 works even though it reads and writes the same column. */

		UPDATE fco
	SET POWER_UNITS = ROUND(POWER_UNITS * 1.10, 0)
	FROM FactCarrierOperation_S5 AS fco
		JOIN DimCarrier_S5 AS dc
    ON fco.DOT_NUMBER = dc.DOT_NUMBER
	WHERE dc.PHY_STATE = 'TX';
	-- ROUND is required because Q13 says rounded to a whole number.
	-- POWER_UNITS is used because FLEETSIZE is not numeric in this database.
	-- JOIN is used because POWER_UNITS is in FactCarrierOperation_S5 and PHY_STATE is in DimCarrier_S5.


/* Q14. Update driven by a subquery. 
Set CrashRate to 0 for every carrier whose current CrashRate is greater than the overall average CrashRate of all carriers. 
Use a subquery in the WHERE clause that returns AVG(CrashRate). 
In one sentence, explain why the subquery that supplies the average must return a single value. */

	SELECT AVG(RECORDABLE_CRASH_RATE)
	FROM FactCarrierOperation_S5

		UPDATE FactCarrierOperation_S5
	SET RECORDABLE_CRASH_RATE = 0
	WHERE RECORDABLE_CRASH_RATE >
	(
    SELECT AVG(RECORDABLE_CRASH_RATE)
    FROM FactCarrierOperation_S5
	);
	-- EXPL: The subquery calculates one average crash rate.
	-- Rows greater than that average are updated to 0.


/* Q15. Update driven by a join (apply the staging feed). 
Update the carriers that exist in BOTH Carrier_S5 and CarrierStaging_S5 
(DotNumbers 1004, 1007, 1010, 1013) so that their LegalName, FleetSize, and CrashRate take the new values from the staging table. 
Use the UPDATE ... FROM ... JOIN form, joining Carrier_S5 to CarrierStaging_S5 on DotNumber. 
In one sentence, explain why a join-driven update is the natural way to copy matching values from one table into another. */
		UPDATE s5
	SET
		s5.LEGAL_NAME = dc.LEGAL_NAME,
		s5.FLEETSIZE = dc.FLEETSIZE,
		s5.STATUS_CODE = dc.STATUS_CODE
	FROM DimCarrier_S5 AS s5
		JOIN DimCarrier AS dc
    ON s5.DOT_NUMBER = dc.DOT_NUMBER
	WHERE s5.DOT_NUMBER IN (1007, 1013);

	-- EXPL:
	-- DimCarrier_S5 is the target table being updated.
	-- DimCarrier is used as the source table with the values to copy.
	-- The JOIN matches rows by DOT_NUMBER.
	-- The WHERE clause limits the update to the DOT_NUMBER rows used for this adapted Q15.

/* Q16. The danger of a missing WHERE clause. 
Suppose you meant to deactivate just the Florida carriers but accidentally ran UPDATE Carrier_S5 SET StatusCode = 'I'; with no WHERE clause. 
Write the CORRECT statement (deactivate only PhyState = 'FL'), and then - to demonstrate the safe pattern - 
rewrite it wrapped in BEGIN TRAN ... (run a SELECT to verify) ... ROLLBACK so nothing is permanently changed. 
In one sentence, explain what a missing WHERE clause does to an UPDATE and how a transaction lets you recover. */

	-- Update only Florida carriers because WHERE PHY_STATE = 'FL'.
	-- 1. Correct update statement: changes only Florida carriers to inactive.
		UPDATE DimCarrier_S5
	SET STATUS_CODE = 'I'
	WHERE PHY_STATE = 'FL';

	-- 2. Starts a transaction so the next changes can be checked before saving.
	BEGIN TRAN;

	-- 3. Runs the Florida-only update inside the transaction.
	UPDATE DimCarrier_S5
	SET STATUS_CODE = 'I'
	WHERE PHY_STATE = 'FL';

	-- 4. Shows the Florida rows after the update so the result can be checked.
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		STATUS_CODE
	FROM DimCarrier_S5
	WHERE PHY_STATE = 'FL';
	-- 5. Undoes the transaction, so the update is not permanently saved.
	ROLLBACK;
	-- EXPL: Without a WHERE clause, UPDATE changes every row.
	-- A transaction lets the update be checked and rolled back before it becomes permanent.


	-- Part D - Deleting rows with DELETE
	--------------------------------------
/* Q17. A basic delete. 
Delete the single carrier whose DotNumber is 1016. (It has no child reviews, so the foreign key will not block you.) 
Write the verifying SELECT first, then the DELETE with the same WHERE clause. 
In one sentence, explain why a DELETE removes whole rows while an UPDATE changes only the columns you name. */
	-- Verify row before deleting
	SELECT *
	FROM DimCarrier_S5
	WHERE DOT_NUMBER = 1016;

	-- Delete row
	DELETE FROM DimCarrier_S5
	WHERE DOT_NUMBER = 1016;

	-- Verify row was deleted
	SELECT *
	FROM DimCarrier_S5
	WHERE DOT_NUMBER = 1016;
	-- EXPL: DELETE removes the whole row from the table.
	-- UPDATE keeps the row and changes only the columns listed in SET.

/* Q18. Delete driven by a subquery. Delete every carrier that has NO rows in Review_S5 (an "orphan" carrier). 
Use DELETE with a NOT EXISTS (or NOT IN) subquery against Review_S5. 
Note: run this AFTER any inserts you made, and be aware some seeded carriers such as 1003, 1008, and 1013 have no reviews. 
In one sentence, explain why a correlated NOT EXISTS subquery is a clear way to express "rows in this table with no match in that one." */
	-- Show carriers where no matching DOT_NUMBER exists in FactCarrierOperation_S5.
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME
	FROM DimCarrier_S5 AS dc
	WHERE NOT EXISTS
	(SELECT 1
    FROM FactCarrierOperation_S5 AS fco
    WHERE fco.DOT_NUMBER = dc.DOT_NUMBER);

	-- Delete carriers from DimCarrier_S5 when no matching DOT_NUMBER exists in FactCarrierOperation_S5.
	DELETE dc
	FROM DimCarrier_S5 AS dc
	WHERE NOT EXISTS
	(SELECT 1
    FROM FactCarrierOperation_S5 AS fco
    WHERE fco.DOT_NUMBER = dc.DOT_NUMBER);
	-- EXPL: NOT EXISTS finds rows in DimCarrier_S5 that have no matching DOT_NUMBER in FactCarrierOperation_S5.
	-- DELETE removes those unmatched carrier rows.

/* Q19. Delete driven by a join (respect the foreign key). 
Delete every review in Review_S5 that belongs to an INACTIVE carrier (Carrier_S5.StatusCode = 'I'). 
Use the DELETE ... FROM ... JOIN form, joining Review_S5 to Carrier_S5 on CarrierID and filtering on the status. 
In one sentence, explain why you must delete the matching child rows in Review_S5 before you could delete those carriers from Carrier_S5. */

	-- Preview rows that would be deleted.
	SELECT
		fco.DOT_NUMBER,
		fco.REVIEW_TYPE,
		fco.REVIEW_DATE,
		dc.STATUS_CODE
	FROM FactCarrierOperation_S5 AS fco
		JOIN DimCarrier_S5 AS dc
    ON fco.DOT_NUMBER = dc.DOT_NUMBER
	WHERE dc.STATUS_CODE = 'I';

	DELETE fco
	FROM FactCarrierOperation_S5 AS fco
		JOIN DimCarrier_S5 AS dc
    ON fco.DOT_NUMBER = dc.DOT_NUMBER
	WHERE dc.STATUS_CODE = 'I';
	-- EXPL: The JOIN finds review rows that belong to inactive carriers.
	-- DELETE removes those rows from FactCarrierOperation_S5 only.
	-- Child/review rows are deleted first so they don't remain connected to carriers that may be deleted later.


/* Q20. DELETE versus TRUNCATE. 
First, write a DELETE statement that empties the CarrierStaging_S5 table (all rows). 
Then write the TRUNCATE TABLE statement that does the same thing. 
In two or three sentences, contrast the two: which is faster and minimally logged, which can be filtered with a WHERE clause, 
which resets an IDENTITY seed, and why TRUNCATE TABLE will fail on a table that is referenced by a foreign key. */

	SELECT COUNT(*) AS CACarriersCount
	FROM CACarriers_S5;

	DELETE FROM CACarriers_S5;

	TRUNCATE TABLE CACarriers_S5;
	-- EXPL: DELETE removes rows and can use a WHERE clause.
	-- TRUNCATE removes all rows, is usually faster, and cannot use a WHERE clause.
	-- Neither command deletes the table itself; DROP TABLE deletes the table.


/* Q21. Delete with an OUTPUT audit trail. 
Delete every carrier whose StatusCode is 'P' (pending) - but only those with no child reviews - and use an OUTPUT clause to capture deleted.
CarrierID, deleted.DotNumber, deleted.LegalName, deleted.PhyState, and deleted.StatusCode INTO CarrierAudit_S5. 
Then SELECT from CarrierAudit_S5 to confirm what was removed. 
In one sentence, explain why the OUTPUT clause is more reliable than running a separate SELECT after the delete to record what you removed. */
	
	-- Create CarrierAudit_S5 to store deleted carrier rows for Q21.
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		STATUS_CODE
	INTO CarrierAudit_S5
	FROM DimCarrier_S5
	WHERE 1 = 0; 
	
	-- Preview pending carriers with no matching row in FactCarrierOperation_S5.
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		dc.STATUS_CODE
	FROM DimCarrier_S5 AS dc
	WHERE dc.STATUS_CODE = 'P'
		AND NOT EXISTS
		(SELECT 1
		FROM FactCarrierOperation_S5 AS fco
		WHERE fco.DOT_NUMBER = dc.DOT_NUMBER);

	-- Delete the pending carriers and save deleted rows into CarrierAudit_S5.
	DELETE dc
	OUTPUT
		deleted.DOT_NUMBER,
		deleted.LEGAL_NAME,
		deleted.PHY_STATE,
		deleted.STATUS_CODE
	INTO CarrierAudit_S5
		(DOT_NUMBER, LEGAL_NAME, PHY_STATE, STATUS_CODE)
	FROM DimCarrier_S5 AS dc
	WHERE dc.STATUS_CODE = 'P'
		AND NOT EXISTS
		(SELECT 1
		FROM FactCarrierOperation_S5 AS fco
		WHERE fco.DOT_NUMBER = dc.DOT_NUMBER);
	-- EXPL: OUTPUT saves the deleted rows into CarrierAudit_S5 during the DELETE.
	-- This is more reliable than selecting after the delete because the rows are already gone.


	-- Part E - Merging rows with MERGE
	------------------------------------
/* Q22. A basic merge (upsert). 
Re-run tables_session5_practice.sql first so the sandbox is clean. 
Then write ONE MERGE statement that synchronizes Carrier_S5 (the target) from CarrierStaging_S5 (the source) on DotNumber: 
WHEN MATCHED, update the target's LegalName, FleetSize, and CrashRate from the source; 
WHEN NOT MATCHED BY TARGET, insert the new carrier (DotNumber, LegalName, DbaName, PhyCity, PhyState, FleetSize, CrashRate). 
In one sentence, explain what "matched" and "not matched by target" mean and why MERGE is called an "upsert." */
	
	-- Create CarrierMergeSource_S5 as the source table for the MERGE.
	SELECT TOP 10
		DOT_NUMBER,
		LEGAL_NAME,
		DBA_NAME,
		PHY_CITY,
		PHY_STATE,
		FLEETSIZE
	INTO CarrierMergeSource_S5
	FROM DimCarrier;

	-- Merge QRY
	MERGE DimCarrier_S5 AS target
	USING CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	WHEN MATCHED THEN
		UPDATE SET
        target.LEGAL_NAME = source.LEGAL_NAME,
        target.FLEETSIZE = source.FLEETSIZE
	WHEN NOT MATCHED BY TARGET THEN
    INSERT (DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE)
    VALUES (source.DOT_NUMBER, source.LEGAL_NAME, source.DBA_NAME, source.PHY_CITY, source.PHY_STATE, source.FLEETSIZE);

	-- Verify matching source rows in DimCarrier_S5 after the MERGE.
	SELECT
    target.DOT_NUMBER,
    target.LEGAL_NAME,
    target.FLEETSIZE
	FROM DimCarrier_S5 AS target
		JOIN CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	ORDER BY target.DOT_NUMBER;
	-- EXPL: MATCHED means the DOT_NUMBER exists in both source and target, so the row is updated.
	-- NOT MATCHED BY TARGET means the source row is missing from DimCarrier_S5, so it is inserted.
	-- MERGE is called an upsert because it can update and insert in one statement.


/* Q23. A more complex merge with a third clause and OUTPUT. 
Extend the Q22 merge with a WHEN NOT MATCHED BY SOURCE clause that sets StatusCode = 'I' for any target carrier that has no matching source row 
(a carrier the feed no longer mentions), and add OUTPUT $action so you can see whether each row was an INSERT, UPDATE, or no-action change. 
In one or two sentences, explain what WHEN NOT MATCHED BY SOURCE does, and why you would mark such rows inactive rather than delete them outright in real data. */

	-- Q23 uses CarrierMergeSource_S5 as the source table and DimCarrier_S5 as the target table.
	BEGIN TRAN;

	MERGE DimCarrier_S5 AS target
	USING CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	WHEN MATCHED THEN
		UPDATE SET
			target.LEGAL_NAME = source.LEGAL_NAME,
			target.FLEETSIZE = source.FLEETSIZE
	WHEN NOT MATCHED BY TARGET THEN
    INSERT (DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE)
    VALUES (source.DOT_NUMBER, source.LEGAL_NAME, source.DBA_NAME, source.PHY_CITY, source.PHY_STATE, source.FLEETSIZE)
	WHEN NOT MATCHED BY SOURCE THEN
		UPDATE SET
			target.STATUS_CODE = 'I'
	OUTPUT
		$action AS MergeAction,
		inserted.DOT_NUMBER,
		inserted.LEGAL_NAME,
		inserted.STATUS_CODE;

	ROLLBACK;
	-- EXPL: NOT MATCHED BY SOURCE means the target row does not exist in the source table.
	-- Those rows are marked inactive instead of deleted to keep history.
	-- OUTPUT shows what action MERGE performed for each affected row.
	-- ROLLBACK keeps this practice MERGE from being permanently saved.

	-- Part F - Investigation (open-ended)
	--------------------------------------
/* Q24. Apply the same change three ways - and decide which you trust. 
Goal: bring Carrier_S5 fully up to date with CarrierStaging_S5 (update the four matching carriers, insert the four new ones). 
Implement this THREE different ways, re-running the setup script before each so you start clean: 
(a) two separate statements - an UPDATE ... FROM ... JOIN for the matches plus an INSERT ... SELECT with NOT EXISTS for the new rows; 
(b) a single MERGE
(c) wrap whichever you prefer in BEGIN TRAN, run row-count and spot-check SELECTs, then COMMIT (or ROLLBACK). 
Write a few sentences on which approach you found clearest, which you would trust most in production, and how you proved each one 
produced the same final data (compare row counts and a few specific rows). */
		
		-- Method A: UPDATE matching rows, then INSERT missing rows.
		BEGIN TRAN;

		UPDATE target
	SET
		target.LEGAL_NAME = source.LEGAL_NAME,
		target.FLEETSIZE = source.FLEETSIZE
	FROM DimCarrier_S5 AS target
		JOIN CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER;

	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE)
	SELECT
		source.DOT_NUMBER,
		source.LEGAL_NAME,
		source.DBA_NAME,
		source.PHY_CITY,
		source.PHY_STATE,
		source.FLEETSIZE
	FROM CarrierMergeSource_S5 AS source
	WHERE NOT EXISTS
	(SELECT 1
    FROM DimCarrier_S5 AS target
    WHERE target.DOT_NUMBER = source.DOT_NUMBER);

	SELECT
		target.DOT_NUMBER,
		target.LEGAL_NAME,
		target.FLEETSIZE
	FROM DimCarrier_S5 AS target
		JOIN CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	ORDER BY target.DOT_NUMBER;

	ROLLBACK;
	
		-- Method B: Use one MERGE statement.
	BEGIN TRAN;

	MERGE DimCarrier_S5 AS target
	USING CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	WHEN MATCHED THEN
		UPDATE SET
        target.LEGAL_NAME = source.LEGAL_NAME,
        target.FLEETSIZE = source.FLEETSIZE
	WHEN NOT MATCHED BY TARGET THEN
    INSERT (DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE)
    VALUES (source.DOT_NUMBER, source.LEGAL_NAME, source.DBA_NAME, source.PHY_CITY, source.PHY_STATE, source.FLEETSIZE);

	SELECT
		target.DOT_NUMBER,
		target.LEGAL_NAME,
		target.FLEETSIZE
	FROM DimCarrier_S5 AS target
		JOIN CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	ORDER BY target.DOT_NUMBER;

	ROLLBACK;
	
		-- Method C: Preferred safe method with checks.
	BEGIN TRAN;

		UPDATE target
	SET
		target.LEGAL_NAME = source.LEGAL_NAME,
		target.FLEETSIZE = source.FLEETSIZE
	FROM DimCarrier_S5 AS target
		JOIN CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER;

	INSERT INTO DimCarrier_S5
		(DOT_NUMBER, LEGAL_NAME, DBA_NAME, PHY_CITY, PHY_STATE, FLEETSIZE)
	SELECT
		source.DOT_NUMBER,
		source.LEGAL_NAME,
		source.DBA_NAME,
		source.PHY_CITY,
		source.PHY_STATE,
		source.FLEETSIZE
	FROM CarrierMergeSource_S5 AS source
	WHERE NOT EXISTS
		(SELECT 1
		FROM DimCarrier_S5 AS target
		WHERE target.DOT_NUMBER = source.DOT_NUMBER);

	SELECT COUNT(*) AS TargetRows
	FROM DimCarrier_S5;

	SELECT
		target.DOT_NUMBER,
		target.LEGAL_NAME,
		target.FLEETSIZE
	FROM DimCarrier_S5 AS target
		JOIN CarrierMergeSource_S5 AS source
    ON target.DOT_NUMBER = source.DOT_NUMBER
	ORDER BY target.DOT_NUMBER;

	ROLLBACK;
	-- EXPL: Method A uses two separate statements: UPDATE matching rows, then INSERT missing rows.
	-- Method B uses one MERGE statement to do both actions.
	-- Method C is safest because the changes are inside a transaction and can be checked before COMMIT or ROLLBACK.
	-- In this run, 10 rows were updated and 0 rows were inserted because all source DOT_NUMBER rows already existed in DimCarrier_S5.


/* Q25. Design a safe data-fix runbook. 
Imagine you have been asked to permanently deactivate (StatusCode = 'I') and then archive-and-remove every carrier in one state, including its reviews. 
Write the ordered script you would actually run: 
(1) a SELECT that previews exactly which carriers and reviews are affected; 
(2) BEGIN TRAN; 
(3) the DELETE of the child Review_S5 rows (with OUTPUT into an audit table if you wish); 
(4) the DELETE of the parent Carrier_S5 rows (with OUTPUT into CarrierAudit_S5); 
(5) verifying SELECTs; 
(6) COMMIT or ROLLBACK. 
In a few sentences, justify the order of operations (why children before parents), explain where the foreign key protects you, and describe one mistake this runbook is designed to prevent. */

	-- (1) a SELECT that previews exactly which carriers and reviews are affected; 
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		dc.STATUS_CODE,
		fco.REVIEW_ID,
		fco.REVIEW_TYPE,
		fco.REVIEW_DATE
	FROM DimCarrier_S5 AS dc
		LEFT JOIN FactCarrierOperation_S5 AS fco
    ON dc.DOT_NUMBER = fco.DOT_NUMBER
	WHERE dc.PHY_STATE = 'FL'
	ORDER BY dc.DOT_NUMBER;

	-- (2) BEGIN TRAN; 
	BEGIN TRAN;

	-- (3) the DELETE of the child Review_S5 rows (with OUTPUT into an audit table if you wish); 
	DELETE fco
	FROM FactCarrierOperation_S5 AS fco
		JOIN DimCarrier_S5 AS dc
    ON fco.DOT_NUMBER = dc.DOT_NUMBER
	WHERE dc.PHY_STATE = 'FL';

	-- (4) the DELETE of the parent Carrier_S5 rows (with OUTPUT into CarrierAudit_S5); 
	DELETE dc
	OUTPUT
		deleted.DOT_NUMBER,
		deleted.LEGAL_NAME,
		deleted.PHY_STATE,
		deleted.STATUS_CODE
	INTO CarrierAudit_S5
    (DOT_NUMBER, LEGAL_NAME, PHY_STATE, STATUS_CODE)
	FROM DimCarrier_S5 AS dc
	WHERE dc.PHY_STATE = 'FL';

	-- (5) verifying SELECTs; 
	SELECT *
	FROM DimCarrier_S5
	WHERE PHY_STATE = 'FL';

	-- (6) COMMIT or ROLLBACK. 
	SELECT *
	FROM CarrierAudit_S5
	WHERE PHY_STATE = 'FL';

	-- EXPL: Child rows are deleted before parent rows because review/operation rows depend on the carrier row.
	-- The foreign key protects the database by blocking a parent delete while child rows still exist.
	-- The preview SELECT and transaction help prevent deleting the wrong state or saving changes before checking them.


