

		----------------------------------
		/* SQL Practice Session 10 & 11 */
		----------------------------------

	-- Part A — Your first views (Session 10) --

/* A1. Your first view. The dispatch desk keeps re-typing the same carrier-contact query. 
Write a CREATE VIEW statement for a view named CarrierContact that returns 
DOT_NUMBER, LEGAL_NAME, PHY_CITY, PHY_STATE, and PHONE from DimCarrier. 
Then write a separate SELECT statement that uses the view to return every carrier in Texas (PHY_STATE = 'TX'), sorted by LEGAL_NAME. 
In one sentence, explain what the “base table” of this view is and why the view stores no data of its own. */

	
CREATE VIEW dbo.CarrierContact AS	
SELECT DOT_NUMBER, LEGAL_NAME, PHY_CITY, PHY_STATE, PHONE
FROM dbo.DimCarrier;
GO

SELECT * FROM dbo.CarrierContact
WHERE PHY_STATE = 'TX'
/* EXPL: The base table is dbo.DimCarrier because the view gets its data from this table, 
	     and the view stores only the SQL query, not a separate copy of the data. */
		 --------------------------------------------------------------------------------

/* A2. A view that restricts rows for data security. 
The support staff should only ever see carriers that are currently active. 
Create a view named ActiveCarriers that returns DOT_NUMBER, LEGAL_NAME, and PHY_STATE from DimCarrier where STATUS_CODE = 'A'. 
In one sentence, name the benefit of views this illustrates and explain how it protects the inactive and pending rows. */

CREATE VIEW dbo.ActiveCarriers AS
SELECT DOT_NUMBER, LEGAL_NAME, PHY_STATE
FROM dbo.DimCarrier
WHERE STATUS_CODE = 'A';
GO

SELECT * FROM dbo.ActiveCarriers;
	/* EXPL: This view improves data security by showing only active carriers 
			 and hiding inactive and pending carriers from users. */
	----------------------------------------------------------------------------

/* A3. A view that joins and decodes (simplified queries). 
End users find the one-letter codes on DimCarrier hard to read. 
Create a view named CarrierProfile that joins DimCarrier to DimStatus, DimCarrierOperation, and 
DimFleetSize and returns DOT_NUMBER, LEGAL_NAME, PHY_STATE, STATUS_DESC, OPERATION_DESC, and POWER_UNITS_RANGE. 
Use inner joins with ON clauses. 
In one sentence, explain how hiding this join behind a view makes life easier for the people who query it. */

CREATE VIEW dbo.CarrierProfile AS
SELECT 
	c.DOT_NUMBER, 
	c.LEGAL_NAME, 
	c.PHY_STATE, 
	s.STATUS_DESC, 
	o.OPERATION_DESC, 
	f.POWER_UNITS_RANGE
FROM dbo.DimCarrier AS c
INNER JOIN dbo.DimStatus AS s ON c.STATUS_CODE = s.STATUS_CODE
INNER JOIN dbo.DimCarrierOperation AS o ON c.CARRIER_OPERATION = o.CARRIER_OPERATION
INNER JOIN dbo.DimFleetSize AS f ON c.FLEETSIZE = f.FLEETSIZE;
GO

SELECT * FROM dbo.CarrierProfile;
	/* EXPL: A calculated column must be named so SQL Server knows what to call it, 
			 and using AS in the SELECT list is the method used most often. */
	--------------------------------------------------------------------------------

/* A4. A calculated column — named two ways. 
The fleet team wants a single “total vehicle units” figure. 
Write a view named CarrierUnits that returns DOT_NUMBER together with 
TRUCK_UNITS + BUS_UNITS + POWER_UNITS as a calculated column named TotalUnits, from FactCarrierOperation. 
Write it twice: once naming the column in a parenthesised column list after the view name 
in the CREATE VIEW clause, and once naming it with AS in the select list. 
In one sentence, say why a calculated column must be named and which of the two styles the chapter says you’ll use most often. */

/*1*/ CREATE VIEW dbo.CarrierUnits (DOT_NUMBER, TotalUnits) AS
	  SELECT DOT_NUMBER, TRUCK_UNITS + BUS_UNITS + POWER_UNITS AS TotalUnits
	  FROM dbo.FactCarrierOperation;
	  GO

DROP VIEW dbo.CarrierUnits; GO

	
/*2*/ CREATE VIEW dbo.CarrierUnits AS
	  SELECT DOT_NUMBER, TRUCK_UNITS + BUS_UNITS + POWER_UNITS AS TotalUnits
	  FROM dbo.FactCarrierOperation;
	  GO
SELECT * FROM dbo.CarrierUnits;
	/* EXPL: A calculated column must be named so SQL Server knows what to call it, 
			 and using AS in the SELECT list is the method used most often. */
	--------------------------------------------------------------------------------

/* A5. A view that summarises (aggregate + GROUP BY). 
Management wants a per-state rollup. 
Create a view named StateCarrierSummary that joins FactCarrierOperation to DimCarrier, 
groups by PHY_STATE, and returns PHY_STATE, COUNT(*) as CarrierCount, and SUM(MCS150_MILEAGE) as TotalMileage. 
  Then write a SELECT that uses the view to list the states in descending TotalMileage order. */

CREATE VIEW dbo.StateCarrierSummary AS
SELECT c.PHY_STATE,
	COUNT(*) AS CarrierCount,
	SUM(f.MCS150_MILEAGE) AS TotalMileage
FROM dbo.FactCarrierOperation AS f
INNER JOIN dbo.DimCarrier AS c 
ON f.DOT_NUMBER = c.DOT_NUMBER
GROUP BY c.PHY_STATE;
GO

SELECT * FROM dbo.StateCarrierSummary
ORDER BY TotalMileage DESC;
	/* EXPL: This view summarizes carrier information by state, 
			 making reporting easier without repeating the GROUP BY query. */
	-------------------------------------------------------------------------
	
/* A6. A view that uses TOP with ORDER BY. 
Create a view named Top10Carriers that returns the ten carriers with the greatest 
MCS150_MILEAGE — DOT_NUMBER, LEGAL_NAME, and MCS150_MILEAGE — using TOP 10 with ORDER BY MCS150_MILEAGE DESC. 
In one sentence, explain why the ORDER BY is allowed here even though a view normally can’t contain one, and note 
where you would still add an ORDER BY if you wanted the rows guaranteed to come back sorted when you query the view. */

CREATE VIEW dbo.Top10Carriers AS
SELECT TOP 10
	c.DOT_NUMBER, 
	c.LEGAL_NAME, 
	f.MCS150_MILEAGE
FROM dbo.FactCarrierOperation AS f
JOIN dbo.DimCarrier AS c
ON f.DOT_NUMBER = c.DOT_NUMBER
ORDER BY f.MCS150_MILEAGE DESC;
GO	

SELECT * FROM dbo.Top10Carriers
ORDER BY MCS150_MILEAGE DESC;
	/* EXPL: ORDER BY is allowed because it is used with TOP, but you should still 
			 use ORDER BY when querying the view to guarantee the result order. */
	------------------------------------------------------------------------------

	/* Part B — Managing, updating, and securing views (Session 10) 
	--============================================================--
B7. Modify a view with ALTER VIEW. Policy has changed: the support staff should now see both Active and Pending carriers. 
	Using ALTER VIEW, modify your ActiveCarriers view from A2 so its WHERE clause keeps STATUS_CODE IN ('A','P'). 
	In one sentence, give one reason the chapter prefers ALTER VIEW over dropping and recreating the view.*/

ALTER VIEW dbo.ActiveCarriers AS
SELECT DOT_NUMBER, LEGAL_NAME, PHY_STATE
FROM dbo.DimCarrier
WHERE STATUS_CODE IN ('A', 'P');
GO
SELECT * FROM dbo.ActiveCarriers;

	/* EXPL: ALTER VIEW modifies an existing view without dropping and recreating it, 
		so dependent objects and permissions are preserved. */
	---------------------------------------------------------------------------------

/* B8. An updatable view with WITH CHECK OPTION. 
The Texas compliance officer maintains only Texas carriers and must never accidentally move a row out of her worklist. 
Create an updatable view named TexasCarriers that returns DOT_NUMBER, LEGAL_NAME, PHY_STATE, and PHONE 
from DimCarrier where PHY_STATE = 'TX', and add WITH CHECK OPTION. 
Then write an UPDATE through the view that tries to change one carrier’s PHY_STATE to 'OK', run it, and record the error message. 
In one sentence, explain what WITH CHECK OPTION prevented. */ 

CREATE VIEW dbo.TexasCarriers AS
SELECT DOT_NUMBER, LEGAL_NAME, PHY_STATE, PHONE
FROM dbo.DimCarrier
WHERE PHY_STATE = 'TX'
WITH CHECK OPTION;
GO
SELECT * FROM dbo.TexasCarriers;

-- Attempt to update through the view
UPDATE dbo.TexasCarriers
SET PHY_STATE = 'OK'
WHERE DOT_NUMBER = 296; -- Replace with an actual DOT_NUMBER from the view
	/* ERROR MESSAGE WILL BE EXPL:
	The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies 
	WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint. */

/* B9. Update, insert, and delete through a view. 
Using an updatable single-table view (TexasCarriers from B8 is fine), write three statements that go through the view: 
an UPDATE that corrects one carrier’s PHONE, an INSERT that adds a new Texas carrier 
(supply DOT_NUMBER, LEGAL_NAME, PHY_STATE = 'TX', and PHONE), and a DELETE that removes it again. 
In one sentence, explain why a view built on a join or one that contains an aggregate could not be used this way. */
UPDATE dbo.TexasCarriers
SET PHONE = '83241467497'
WHERE DOT_NUMBER = 296; -- Replace with an actual DOT_NUMBER from the view

SELECT * FROM dbo.TexasCarriers;

INSERT INTO dbo.TexasCarriers
(DOT_NUMBER, LEGAL_NAME, PHY_STATE, PHONE)
VALUES
(123456, 'New Texas Carrier', 'TX', '5551234567');

DELETE FROM dbo.TexasCarriers
WHERE DOT_NUMBER = 123456;
	/* A view that contains joins or aggregate functions is not directly updatable 
	because SQL Server cannot determine how to modify the underlying data correctly. */

/* B10. A production view WITH SCHEMABINDING. 
CarrierProfile from A3 is going into production and must not silently break when someone changes a base table. 
Recreate it (ALTER VIEW or DROP then CREATE) adding WITH SCHEMABINDING. Make the two changes schema binding requires: 
qualify every table with its schema (dbo.) and replace any * with an explicit column list. 
Then try to run an ALTER TABLE that drops or retypes one of the bound columns and record what happens. 
In one sentence, explain what schema binding guarantees for a production database. */

ALTER VIEW dbo.CarrierProfile
WITH SCHEMABINDING AS
SELECT 
	c.DOT_NUMBER, 
	c.LEGAL_NAME, 
	c.PHY_STATE, 
	s.STATUS_DESC, 
	o.OPERATION_DESC, 
	f.POWER_UNITS_RANGE
FROM dbo.DimCarrier AS c
INNER JOIN dbo.DimStatus AS s ON c.STATUS_CODE = s.STATUS_CODE
INNER JOIN dbo.DimCarrierOperation AS o ON c.CARRIER_OPERATION = o.CARRIER_OPERATION
INNER JOIN dbo.DimFleetSize AS f ON c.FLEETSIZE = f.FLEETSIZE;
GO
SELECT * FROM dbo.CarrierProfile;

ALTER TABLE dbo.DimCarrier
DROP COLUMN PHY_STATE; -- This will fail due to SCHEMABINDING.
-- EXPL: SCHEMABINDING prevented the LEGAL_NAME column from being dropped because dbo.CarrierProfile depends on that column.

/* B11. A nested view (view built on a view). 
Create a view named ActiveCarrierProfile that selects from your CarrierProfile view 
(not from the base tables) and keeps only the rows where STATUS_DESC = 'Active'. 
In one sentence, explain why the chapter recommends avoiding nested views even though SQL Server allows them up to 32 levels deep. */

CREATE VIEW dbo.ActiveCarrierProfile AS
SELECT * FROM dbo.CarrierProfile
WHERE STATUS_DESC = 'Active';
GO
SELECT * FROM  dbo.ActiveCarrierProfile
-- EXPL: Nested views are supported, but too many layers make queries harder to understand, maintain, and troubleshoot.

/* B12. Inspect your views with the catalog views. 
(Dictionary) You’ve created several views — now document them from the catalog. 
First, write a SELECT against sys.views that lists the name of every view in the database. */
SELECT name FROM sys.views;

-- Second, join sys.views to sys.columns to list each view together with its column names. 
SELECT 
	v.name AS ViewName, 
	c.name AS ColumnName
FROM sys.views AS v
INNER JOIN sys.columns AS c ON v.object_id = c.object_id
ORDER BY v.name, c.column_id;

-- Third, run EXEC sp_helptext 'CarrierProfile'; to display the stored definition of one view. 
EXEC sp_helptext 'dbo.CarrierProfile';

/* In one sentence, explain why the chapter recommends querying the catalog views instead of the underlying system tables directly. 
EXPL: Catalog views are recommended because they provide a safe and supported way 
	  to read database metadata instead of querying internal system tables directly. */

	/* Part C — Coding scripts: variables and control of flow (Session 11) */
	--=====================================================================--
/* C13. Your first script — batches, USE, and PRINT. 
Write a short script whose first statement is USE usaTrucking; that then uses a PRINT statement 
to send a greeting such as 'Carrier reporting script starting…' to the Messages tab. 
Add a GO command to end the batch. In one sentence, explain what the GO command does and why it is not itself a Transact-SQL statement. */

USE usaTrucking;
GO
PRINT 'Carrier reporting script starting…';
GO -- GO ends a batch and is recognized by SSMS, not by SQL Server as a Transact-SQL statement.

/* C14. Scalar variables with DECLARE and SET. 
Write a script that DECLAREs a money (or decimal) variable named @AvgMileage, uses SET 
with a subquery to assign it AVG(MCS150_MILEAGE) from FactCarrierOperation, and PRINTs a sentence 
such as 'Average carrier mileage is …' — use CONVERT to turn the number into text for the message. 
In one sentence, state what value a variable holds before you assign one and why the name must start with @. */

DECLARE @AvgMileage DECIMAL(18, 2);
SET @AvgMileage = 
(SELECT AVG(MCS150_MILEAGE) 
FROM dbo.FactCarrierOperation);
PRINT 'Average carrier mileage is ' + CONVERT(VARCHAR(20), @AvgMileage);
	-- SQL Server Returns: 
	-- Warning: Null value is eliminated by an aggregate or other SET operation. Average carrier mileage is 263260.00
	-- EXPL: A variable starts as NULL until you assign a value, and its name must begin with @.

/* C15. Assigning several variables in one SELECT. Extend C14: using the alternate select-list syntax, assign three variables at once — @MinMileage, @MaxMileage, and @CarrierCount — from a single SELECT over FactCarrierOperation (MIN, MAX, and COUNT(*)). PRINT all three. In one sentence, give the advantage of the SELECT-assignment syntax over three separate SET statements. */

DECLARE @MinMileage DECIMAL(18, 2), 
		@MaxMileage DECIMAL(18, 2), 
		@CarrierCount INT;

SELECT 
	@MinMileage = MIN(MCS150_MILEAGE),
	@MaxMileage = MAX(MCS150_MILEAGE),
	@CarrierCount = COUNT(*)
FROM dbo.FactCarrierOperation; 
	-- EXPL: SELECT assigns values to multiple variables in one statement, while SET assigns one variable at a time.

/* C16. Conditional processing with IF … ELSE and BEGIN … END. 
Compliance wants a quick flag. 
Write a script that assigns to a variable the average TOTAL_DRIVERS 
for carriers in Texas and, separately, the national average TOTAL_DRIVERS. 
Use an IF … ELSE statement so that, when the Texas average is greater than the national average, a BEGIN … END block PRINTs 
two lines (a headline and the two figures); otherwise a single PRINT reports that Texas is at or below the national average. 
In one sentence, say when you must use BEGIN … END rather than a single statement. */

DECLARE @TexasAvgDrivers DECIMAL(18, 2), 
		@NationalAvgDrivers DECIMAL(18, 2);
SELECT @TexasAvgDrivers = AVG(TOTAL_DRIVERS)
FROM dbo.FactCarrierOperation AS f
JOIN dbo.DimCarrier AS c ON f.DOT_NUMBER = c.DOT_NUMBER
WHERE c.PHY_STATE = 'TX';

SELECT @NationalAvgDrivers = AVG(TOTAL_DRIVERS)
FROM dbo.FactCarrierOperation;

IF @TexasAvgDrivers > @NationalAvgDrivers
BEGIN
	PRINT 'Texas average is above the national average.';
	PRINT 'Texas = ' + CONVERT(VARCHAR(20), @TexasAvgDrivers) + ', National = ' + CONVERT(VARCHAR(20), @NationalAvgDrivers);
END 
ELSE
	PRINT 'Texas is at or below the national average.';
	-- EXPL: BEGIN...END is required when an IF or ELSE block contains more than one statement. 
		
/* C17. Test for existence before you create. 
Rerunning a build script shouldn’t fail just because an object already exists. 
Write the guard code, two ways: 
	(a) DROP VIEW IF EXISTS dbo.CarrierContact; and 
	(b) an older-style check using IF OBJECT_ID('dbo.
CarrierContact') IS NOT NULL DROP VIEW dbo.CarrierContact; . 
In one sentence, explain what the OBJECT_ID function returns when the object does not exist. */
	-- Modern Syntax:
DROP VIEW IF EXISTS dbo.CarrierContact;
GO
	-- Older Syntax:
IF OBJECT_ID('dbo.CarrierContact') IS NOT NULL
DROP VIEW dbo.CarrierContact;
GO
	-- EXPL: OBJECT_ID returns NULL when the object does not exist.

/* C18. Store a result set in a table variable. 
The risk team wants an in-memory shortlist. 
Declare a table variable named @HighRiskCarriers with columns DOT_NUMBER int and CrashRate decimal(6,3), INSERT into it 
every carrier whose RECORDABLE_CRASH_RATE is greater than 5, then SELECT from the table variable ordered by CrashRate descending. 
In one sentence, state the scope of a table variable — how long it stays available. */
DECLARE @HighRiskCarriers TABLE
	(DOT_NUMBER INT,CrashRate DECIMAL(6, 3));

INSERT INTO @HighRiskCarriers (DOT_NUMBER, CrashRate)
SELECT DOT_NUMBER, RECORDABLE_CRASH_RATE
FROM dbo.FactCarrierOperation
WHERE RECORDABLE_CRASH_RATE > 5;

SELECT * FROM @HighRiskCarriers
ORDER BY CrashRate DESC;
	-- EXPL: A table variable is available only within the batch, procedure, or function in which it is declared.

/* C19. A temporary table, and when to prefer a derived table. 
Write a script that uses SELECT … INTO to build a local temporary table named #StateMileage 
holding PHY_STATE and SUM(MCS150_MILEAGE) as TotalMileage (FactCarrierOperation joined to DimCarrier, 
grouped by PHY_STATE), then queries #StateMileage for the states above the average of TotalMileage. 
Below it, write the same result using a CTE / derived table instead. In one sentence each, explain the difference between 
a local (#) and a global (##) temporary table, and say which of your two versions the chapter tells you to prefer and why. */

	-- Create local temp table
 SELECT c.PHY_STATE, 
	SUM(f.MCS150_MILEAGE) AS TotalMileage
 INTO #StateMileage
 FROM dbo.FactCarrierOperation AS f
 JOIN dbo.DimCarrier AS c ON f.DOT_NUMBER = c.DOT_NUMBER
 GROUP BY c.PHY_STATE;

	-- QRY the temp table
SELECT * FROM #StateMileage
WHERE TotalMileage > (
	SELECT AVG(TotalMileage) 
	FROM #StateMileage
)
ORDER BY TotalMileage DESC;

	-- CTE / derived table version
WITH StateMileage AS (
	SELECT c.PHY_STATE,
	SUM(f.MCS150_MILEAGE) AS TotalMileage
	FROM dbo.FactCarrierOperation AS f
	JOIN dbo.DimCarrier AS c ON f.DOT_NUMBER = c.DOT_NUMBER
	GROUP BY c.PHY_STATE
	)
SELECT * FROM StateMileage
WHERE TotalMileage > (
	SELECT AVG(TotalMileage) 
	FROM StateMileage
	)
ORDER BY TotalMileage DESC;
	-- EXPL: A temporary table can be reused, while a CTE exists only for a single statement.

/* C20. Repetitive processing with a WHILE loop. 
Write a script that uses a WHILE loop to build a small calendar helper: 
starting from a counter variable set to 1, PRINT the month number and loop while the counter is ≤ 12, adding 1 each pass. 
Inside the loop, use an IF with a BREAK to stop early if the counter ever exceeds 12, and a CONTINUE to return to the top. 
In one sentence, say what BREAK and CONTINUE each do to the loop. */

DECLARE @Month INT = 1;
WHILE @Month <= 12
BEGIN
	PRINT 'Month: ' + CONVERT(VARCHAR(2), @Month);
	SET @Month = @Month +1;
	IF @Month > 12
		BREAK;
	CONTINUE;
END;
	-- EXPL: BREAK exits the loop, while CONTINUE skips to the next loop iteration.

/* C21. Row-by-row processing with a cursor (and the set-based alternative). 
For teaching purposes, write a script that DECLAREs a cursor over DOT_NUMBER and RECORDABLE_CRASH_RATE 
from FactCarrierOperation for carriers whose crash rate is greater than 0, OPENs it, and uses 
a WHILE @@FETCH_STATUS = 0 loop with FETCH NEXT … INTO to count how many carriers have 
a crash rate above 10, PRINTing the count at the end; CLOSE and DEALLOCATE the cursor. 
Then, below it, write the single set-based SELECT that produces the same count. 
In one sentence, explain why the chapter tells you to prefer the set-based version. */

DECLARE 
	@DOT_NUMBER INT,
	@CrashRate DECIMAL (6, 3),
	@Count INT = 0;

DECLARE CarrierCursor CURSOR FOR
SELECT
	DOT_NUMBER, 
	RECORDABLE_CRASH_RATE
FROM dbo.FactCarrierOperation
WHERE RECORDABLE_CRASH_RATE > 0;

OPEN CarrierCursor;

FETCH NEXT FROM CarrierCursor 
INTO @DOT_NUMBER, @CrashRate;

WHILE @@FETCH_STATUS = 0
BEGIN
	IF @CrashRate > 10
		SET @Count = @Count + 1;
	FETCH NEXT FROM CarrierCursor
	INTO @DOT_NUMBER, @CrashRate;
END;

PRINT 'Carriers with crash rate above 10: ' + CONVERT(VARCHAR(10), @Count);
CLOSE CarrierCursor;
DEALLOCATE CarrierCursor;

SELECT COUNT(*) AS CarrierCount
FROM dbo.FactCarrierOperation
WHERE RECORDABLE_CRASH_RATE > 10;
	-- EXPL: The set-based query is preferred because it is simpler and usually performs faster than a cursor.

/* C22. Error handling with TRY … CATCH. 
(Dictionary) Write a script with a BEGIN TRY … END TRY block that attempts to INSERT a row into DimCarrier 
using a STATUS_CODE that is not one of the valid dictionary codes (for example 'Z'), so the foreign key to 
DimStatus is violated, followed by a PRINT that would announce success. In the BEGIN CATCH … END CATCH block, 
PRINT a failure message plus ERROR_NUMBER() and ERROR_MESSAGE(). 
In one sentence, explain what control does when the INSERT raises the error. */

BEGIN TRY
	INSERT INTO dbo.DimCarrier
	(
		DOT_NUMBER,
		LEGAL_NAME,
		STATUS_CODE
	)
	VALUES
	(
		999999999,
		'Test Carrier',
		'Z'
	);
	PRINT 'Insert completed successfully.';
END TRY

BEGIN CATCH
	PRINT 'Insert failed.';
	PRINT 'Error number: ' + CONVERT(VARCHAR(10), ERROR_NUMBER());
	PRINT 'Error message: ' + ERROR_MESSAGE();
END CATCH;
	-- SQL Server returns: 
	-- (0 rows affected)
	-- Insert failed.
	-- Error number: 547
	-- Error message: The INSERT statement conflicted with the FOREIGN KEY constraint "FK_DimCarrier_Status".
	-- The conflict occurred in database "usaTrucking", table "dbo.DimStatus", column 'STATUS_CODE'.
	-- EXPL: When the INSERT causes an error, control immediately moves from the TRY block to the CATCH block.

/* C23. System functions — @@ROWCOUNT and SYSTEM_USER. 
Write a script that runs an UPDATE (for example, setting PHONE to itself for carriers in one state so no data really changes), 
then immediately captures @@ROWCOUNT into a variable and PRINTs how many rows were affected together with the value of SYSTEM_USER. 
In one sentence, explain why the chapter recommends storing @@ROWCOUNT in a variable right after the statement rather than using it later. */

DECLARE @RowsAffected INT;

UPDATE dbo.DimCarrier
SET PHONE = PHONE
WHERE PHY_STATE = 'TX';

SET @RowsAffected = @@ROWCOUNT;

PRINT 'Rows affected: ' + CONVERT(VARCHAR(10), @RowsAffected);
PRINT 'User: ' + SYSTEM_USER;
	-- EXPL: Store @@ROWCOUNT immediately because its value changes after the next SQL statement.

/* C24. Dynamic SQL with EXEC. 
Write a script that puts a table name into a varchar variable (for example SET @TableName = 'FactCarrierOperation';), 
builds a SELECT COUNT(*) statement by concatenating that variable into a string, and runs it with EXEC. 
In one sentence, describe a realistic situation in which dynamic SQL is the only way 
to solve the problem — something you could not do by hard-coding the table name. */

DECLARE @TableName VARCHAR(50);
DECLARE @SQL VARCHAR(100);

SET @TableName = 'FactCarrierOperation';
SET @SQL = 'SELECT COUNT(*) AS TotalRows FROM dbo.' + @TableName;
EXEC (@SQL);
	-- EXPL: Dynamic SQL is useful when the table name is not known until the script runs.

	/* Part D — Putting it together and choosing the right tool */
	--==========================================================--
/* D25. A complete, re-runnable reporting script. 
Deliver a single script the reporting team can run on demand. 
It should: (1) USE usaTrucking and set SET NOCOUNT ON; (2) drop the view if it already exists, then CREATE a view 
named StateRiskReport that returns, per state, PHY_STATE, COUNT(*) as CarrierCount, and AVG(RECORDABLE_CRASH_RATE) 
as AvgCrashRate (remember CREATE VIEW must be alone in its batch, so use GO); (3) in a later batch, wrap a query of the view 
in a TRY … CATCH, using an IF to PRINT how many states came back above a crash-rate threshold you choose, and reporting 
any error from the CATCH block. 
Add a comment header (purpose, author, date) like the scripts in the chapter. */

/*==================================================
Purpose: Create and run a reusable state risk report
Author: Ghayrat
Date: 2026-07-08
===================================================*/
USE usaTrucking;
GO

SET NOCOUNT ON;
GO

DROP VIEW IF EXISTS dbo.StateRiskReport;
GO

CREATE VIEW dbo.StateRiskReport AS
SELECT
	c.PHY_STATE,
	COUNT(*) AS CarrierCount,
	AVG(f.RECORDABLE_CRASH_RATE) AS AvgCrashRate
FROM dbo.FactCarrierOperation AS f
JOIN dbo.DimCarrier AS c ON f.DOT_NUMBER = c.DOT_NUMBER
GROUP BY c.PHY_STATE;
GO

BEGIN TRY
	DECLARE @Threshold DECIMAL(6,3) = 5.000;
	DECLARE @StateCount INT;

	SELECT @StateCount = COUNT(*)
	FROM dbo.StateRiskReport
	WHERE AvgCrashRate > @Threshold;

	IF @StateCount > 0
	BEGIN
		PRINT CONVERT(VARCHAR(10), @StateCount) + ' states are above the crash-rate threshold.';
	END
	ELSE
	BEGIN
		PRINT 'No states are above the crash-rate threshold.';
	END

	SELECT * FROM dbo.StateRiskReport
	WHERE AvgCrashRate > @Threshold
	ORDER BY AvgCrashRate DESC;
END TRY

BEGIN CATCH 
	PRINT 'Report failed.';
	PRINT 'Error number: ' + CONVERT(VARCHAR(10), ERROR_NUMBER());
	PRINT 'Error message: ' + ERROR_MESSAGE();
END CATCH;

/* D26. Choosing among the five table objects. 
(Reflection) The chapter compares five ways to hold table data 
— a standard table, 
- a view, 
- a temporary table, 
- a table variable, and 
- a derived table / CTE — by scope, storage, and performance. 
For each of these three needs, name the object you would use and justify it in one or two sentences: 
(a) a per-state risk summary that many analysts and applications must query for months to come; 
	A view is best because many users can reuse the same query without storing duplicate data.

(b) a scratch result you need only inside one multi-batch build script
	A temporary table is best because it can be reused during the current session and is deleted automatically when the session ends.

(c) a one-off summary of a summary used inside	a single SELECT. 
	A CTE is best because it exists only for a single statement and does not store data.
Then state the one rule of thumb the chapter gives for when you should reach for a view instead of creating	a table.
Rule of thumb:
Use a view when you need to save and reuse a query without storing duplicate data. */