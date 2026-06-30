

		-----/* Practice Session 3 */------

	------------------------------------------------------
	/* Part A — Aggregate functions (scalar aggregates) */
	------------------------------------------------------
/* Q1. Your first summary query. 
Write a one-row summary query against DimCarrier that returns a single column, TotalCarriers, using COUNT(*). 
In one sentence, explain what COUNT(*) counts and whether it includes rows that contain null values. */
	SELECT 
		COUNT(*) AS TotalCarriers
	FROM DimCarrier;

/* Q2. SUM and AVG together, with a literal label. From FactCarrierOperation, return four columns in a single row: 
the literal text ‘All Carriers’ aliased Scope, the number of carriers that report mileage (COUNT of MCS150_MILEAGE) aliased CarriersReporting, 
the total fleet mileage (SUM of MCS150_MILEAGE) aliased TotalMileage, and the average mileage (AVG of MCS150_MILEAGE) aliased AverageMileage. 
Add a WHERE clause so only rows with MCS150_MILEAGE greater than 0 are included. 
In one sentence, state how SUM and AVG treat the null MCS150_MILEAGE values that remain. */
 -- SUM and AVG ignore NULL values, and this query also removes zero/negative mileage rows using WHERE
	SELECT
		'All Carriers' AS Scope,
		COUNT(fc.MCS150_MILEAGE) AS CarriersReporting,
		SUM(fc.MCS150_MILEAGE) AS TotalMileage, 
		AVG(fc.MCS150_MILEAGE) AS AverageMileage
	FROM FactCarrierOperation fc
	WHERE fc.MCS150_MILEAGE > 0;

/* Q3. MIN and MAX with a calculated expression. 
Using FactCarrierOperation, return the worst and best recordable crash rate (MAX and MIN of RECORDABLE_CRASH_RATE) aliased WorstCrashRate and BestCrashRate, 
the total number of power units across all carriers (SUM of POWER_UNITS) aliased TotalPowerUnits, and the average number of drivers per power unit 
(AVG of TOTAL_DRIVERS) aliased AvgDrivers. Restrict the query with a WHERE clause to rows where POWER_UNITS is greater than 0. */
	SELECT
		MAX(fc.RECORDABLE_CRASH_RATE) AS WorstCrashRate,
		MIN(fc.RECORDABLE_CRASH_RATE) AS BestCrashRate,
		SUM(fc.POWER_UNITS) AS TotalPowerUnits,
		AVG(fc.TOTAL_DRIVERS) AS AvgDrivers
	FROM FactCarrierOperation fc
	WHERE fc.POWER_UNITS > 0; 

/* Q4. COUNT(*) versus COUNT(column) — null handling. Write one query against FactCarrierOperation that returns, side by side, COUNT(*) aliased TotalRows and 
COUNT(SAFETY_RATING) aliased RatedCarriers. Explain in one sentence why the two numbers differ and what that tells you about the SAFETY_RATING column. */
	SELECT
    COUNT(*) AS TotalRows,	-- counts every carrier
    COUNT(fc.SAFETY_RATING) AS RatedCarriers	-- counts only carriers that have a safety rating,
FROM FactCarrierOperation fc;

/* Q5. COUNT with the DISTINCT keyword. Using DimCarrier, return two columns in one row: the number of distinct physical states that carriers are located in 
(COUNT of DISTINCT PHY_STATE) aliased DistinctStates, and the count of carriers that have a non-null state (COUNT of PHY_STATE) aliased CarriersWithState. 
In one sentence, explain when adding DISTINCT changes the result of a COUNT and when it does not. */
	-- DISTINCT changes the count when duplicate values exist, but it does not change the count when all values are unique.
	SELECT
		COUNT(DISTINCT dc.PHY_STATE) AS DistinctStates,
		COUNT(dc.PHY_STATE) AS CarriersWithState
	FROM DimCarrier dc;

/* Q6. MIN and MAX on date and string columns. From DimCarrier, return the earliest and latest ADD_DATE (MIN and MAX) aliased FirstCarrierAdded and LastCarrierAdded, 
plus the alphabetically first and last LEGAL_NAME (MIN and MAX of LEGAL_NAME) aliased FirstName and LastName. 
In one sentence, note why MIN and MAX work here even though LEGAL_NAME and ADD_DATE are not numeric. */
	-- MIN and MAX work on dates and text because SQL can compare date order and alphabetical order.
	SELECT
		MIN(dc.ADD_DATE) AS FirstCarrierAdded,
		MAX(dc.ADD_DATE) AS LastCarrierAdded,
		MIN(dc.LEGAL_NAME) AS FirstName,
		MAX(dc.LEGAL_NAME) AS LastName
	FROM DimCarrier dc;

	-------------------------------------------------------------
	-- Part B — Grouping and summarizing with GROUP BY and HAVING
	-------------------------------------------------------------
/* Q7. Your first GROUP BY. Group FactCarrierOperation by SAFETY_RATING and return SAFETY_RATING together with 
a count of carriers (COUNT(*)) aliased CarrierCount for each rating. Sort so the most common rating appears first. 
In one sentence, explain why SAFETY_RATING is allowed in the SELECT clause even though the query is summarized. */
	-- SAFETY_RATING is allowed in SELECT because it is also listed in the GROUP BY.
	SELECT
		fc.SAFETY_RATING,
		COUNT(*) AS CarrierCount
	FROM FactCarrierOperation fc
	GROUP BY fc.SAFETY_RATING
	ORDER BY CarrierCount DESC;

/* Q8. (Dictionary) Group by a decoded value with a lookup join. 
Join FactCarrierOperation to DimSafetyRating and group by the description column so the result is readable. 
Return SAFETY_RATING_DESC and COUNT(*) aliased CarrierCount, one row per rating. Sort by CarrierCount descending. 
Use the data dictionary to confirm what the S, C, and U codes mean. */
	-- This query groups carriers by the readable safety rating name instead of the code.
	-- Dictionary meaning
	-- S = Satisfactory
	-- C = Conditional
	-- U = Unsatisfactory
	SELECT
		sr.SAFETY_RATING_DESC,
		COUNT(*) AS CarrierCount
	FROM FactCarrierOperation fc
		JOIN DimSafetyRating sr
    ON fc.SAFETY_RATING = sr.SAFETY_RATING
	GROUP BY sr.SAFETY_RATING_DESC
	ORDER BY CarrierCount DESC;

/* Q9. GROUP BY a key with SUM and AVG across a join. Join FactCarrierOperation to DimCarrier and group by DimCarrier.PHY_STATE. 
Return PHY_STATE, COUNT(*) aliased CarrierCount, SUM(TOTAL_DRIVERS) aliased TotalDrivers, and AVG(TOTAL_DRIVERS) aliased AvgDrivers. 
Sort by TotalDrivers descending. This is a vector aggregate — explain in one sentence how that differs from the scalar aggregates in Part A. */
	-- VECTOR = returns one result per group. 
	-- SCALAR = returns one result for whole table. (Part A: Q1-Q6)
	SELECT
		dc.PHY_STATE,
		COUNT(*) AS CarrierCount,
		SUM(fc.TOTAL_DRIVERS) AS TotalDrivers,
		AVG(fc.TOTAL_DRIVERS) AS AvgDrivers
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	GROUP BY dc.PHY_STATE
	ORDER BY TotalDrivers DESC;

/* Q10. Group by two columns. Join DimCarrier to DimStatus and DimState. 
Group by STATE_NAME and STATUS_DESC and return STATE_NAME, STATUS_DESC, and COUNT(*) aliased CarrierCount. 
Sort by STATE_NAME, then STATUS_DESC. 
In one sentence, explain how many rows the query returns relative to the number of state/status combinations in the data. */
	-- The query returns one row for each unique state and status combination.
	SELECT
		st.STATE_NAME,
		ds.STATUS_DESC,
		COUNT(*) AS CarrierCount
	FROM DimCarrier dc
		JOIN DimStatus ds
    ON dc.STATUS_CODE = ds.STATUS_CODE
		JOIN DimState st
    ON dc.PHY_STATE = st.STATE_CODE
	GROUP BY st.STATE_NAME, ds.STATUS_DESC
	ORDER BY st.STATE_NAME, ds.STATUS_DESC;

/* Q11. Group by an expression. From DimCarrier, return the calendar year each carrier filed its 
MCS-150 (YEAR(MCS150_DATE)) aliased FilingYear, together with COUNT(*) aliased FilingsCount. 
Group by the YEAR(MCS150_DATE) expression and sort by FilingYear. 
Exclude rows where MCS150_DATE is null with a WHERE clause. */
	-- This query counts how many carriers filed MCS-150 in each year.
	SELECT
		YEAR(dc.MCS150_DATE) AS FilingYear,
		COUNT(*) AS FilingsCount
	FROM DimCarrier dc
	WHERE dc.MCS150_DATE IS NOT NULL
	GROUP BY YEAR(dc.MCS150_DATE)
	ORDER BY FilingYear;

/* Q12. HAVING — filter the groups, not the rows. 
Starting from the Q9 query (FactCarrierOperation joined to DimCarrier, grouped by PHY_STATE), return PHY_STATE and AVG(TOTAL_DRIVERS) aliased AvgDrivers, 
but add a HAVING clause that keeps only the states whose average number of drivers is greater than 50. 
Sort by AvgDrivers descending. */
	-- HAVING is used because we are filtering states after the average drivers are calculated.
	SELECT
		dc.PHY_STATE,
		AVG(fc.TOTAL_DRIVERS) AS AvgDrivers
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	GROUP BY dc.PHY_STATE
	HAVING AVG(fc.TOTAL_DRIVERS) > 50
	ORDER BY AvgDrivers DESC; 

/* Q13. HAVING with COUNT. Join DimCarrier to DimState, group by STATE_NAME, and return STATE_NAME with COUNT(*) aliased CarrierCount. 
Use a HAVING clause to keep only the states that have at least 100 carriers. 
Explain in one sentence why this COUNT(*) >= 100 test cannot be written in the WHERE clause instead. */
	SELECT
		st.STATE_NAME,
		COUNT(*) AS CarrierCount
	FROM DimCarrier dc
		JOIN DimState st
    ON dc.PHY_STATE = st.STATE_CODE
	GROUP BY st.STATE_NAME
	HAVING COUNT(*) >= 100;	--> must be in HAVING because it filters groups after counting, not rows before grouping.

/* Q14. WHERE and HAVING in the same query. Join FactCarrierOperation to DimReviewType and group by REVIEW_TYPE_DESC. 
Use a WHERE clause to include only the fact rows whose REVIEW_DATE is on or after 2015-01-01 (a filter applied before grouping), 
then use a HAVING clause to keep only the review types that have more than 5 carriers. 
Return REVIEW_TYPE_DESC and COUNT(*) aliased ReviewCount, sorted by ReviewCount descending. 
In one sentence, describe the difference between what the WHERE clause filters and what the HAVING clause filters. */
	SELECT
		rt.REVIEW_TYPE_DESC,
		COUNT(*) AS ReviewCount
	FROM FactCarrierOperation fc
		JOIN DimReviewType rt
    ON fc.REVIEW_TYPE = rt.REVIEW_TYPE
	WHERE fc.REVIEW_DATE >= '2015-01-01' --> filters rows before grouping
	GROUP BY rt.REVIEW_TYPE_DESC
	HAVING COUNT(*) > 5
	ORDER BY ReviewCount DESC;

/* Q15. Compound HAVING condition. Join FactCarrierOperation to DimCarrier and group by PHY_STATE. 
Return PHY_STATE, COUNT(*) aliased CarrierCount, SUM(POWER_UNITS) aliased TotalPowerUnits, and AVG(RECORDABLE_CRASH_RATE) aliased AvgCrashRate. 
In a single HAVING clause, keep only the states that satisfy all three conditions: 
more than 50 carriers AND more than 1000 total power units AND an average crash rate greater than 0. Sort by AvgCrashRate descending. */
	SELECT
		dc.PHY_STATE,
		COUNT(*) AS CarrierCount,
		SUM(fc.POWER_UNITS) AS TotalPowerUnits,
		AVG(fc.RECORDABLE_CRASH_RATE) AS AvgCrashRate
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
		ON fc.DOT_NUMBER = dc.DOT_NUMBER
	GROUP BY dc.PHY_STATE
	HAVING COUNT(*) > 50 --> HAVING keeps only the state groups that pass all three aggregate conditions.
		AND SUM(fc.POWER_UNITS) > 1000 
		AND AVG(fc.RECORDABLE_CRASH_RATE) > 0
	ORDER BY AvgCrashRate DESC;

/* Q16. Summarize across the political data. 
Join DimCarrier to StateGovernment2026 on the state code and group by SENATE_CONTROL to find how many carriers are based in states under each kind of senate control. 
Return SENATE_CONTROL and COUNT(*) aliased CarrierCount, sorted by CarrierCount descending. 
Note in one sentence what a NULL or blank SENATE_CONTROL group would represent. */
	-- A NULL or blank SENATE_CONTROL group means those carriers are in states with missing senate-control data.
	SELECT
		sg.SENATE_CONTROL,
		COUNT(*) AS CarrierCount
	FROM DimCarrier dc
		JOIN StateGovernment2026 sg
		ON dc.PHY_STATE = sg.STATE_CODE
	GROUP BY sg.SENATE_CONTROL
	ORDER BY CarrierCount DESC;
	
	-----------------------------------------------------------------------
	-- Part C — SQL Server summary extensions (ROLLUP, CUBE, GROUPING SETS)
	-----------------------------------------------------------------------
/* Q17. ROLLUP on a single column. 
Take the count-by-rating query from Q8 (FactCarrierOperation joined to DimSafetyRating, grouped by SAFETY_RATING_DESC) and add the ROLLUP operator 
so that a final grand-total row is appended to the result set. Return SAFETY_RATING_DESC and COUNT(*) aliased CarrierCount. 
In one sentence, explain what value appears in SAFETY_RATING_DESC on the summary row and why. */
	SELECT
		sr.SAFETY_RATING_DESC,
		COUNT(*) AS CarrierCount
	FROM FactCarrierOperation fc
		JOIN DimSafetyRating sr
	ON fc.SAFETY_RATING = sr.SAFETY_RATING
	GROUP BY ROLLUP(sr.SAFETY_RATING_DESC); --> The grand-total row shows NULL for SAFETY_RATING_DESC because it represents all ratings combined.

/* Q18. ROLLUP on two columns. Join DimCarrier to DimState and group with ROLLUP on OMC_REGION and STATUS_CODE. 
Return OMC_REGION, STATUS_CODE, and COUNT(*) aliased CarrierCount. 
Sort by OMC_REGION descending, then STATUS_CODE descending, so each summary row (which carries nulls) appears after the detail rows it summarizes. 
Point out which rows are per-region subtotals and which single row is the grand total. */
	-- Rows with an OMC_REGION value and NULL STATUS_CODE are region subtotals; the row with NULL in both columns is the grand total.
	SELECT
		st.OMC_REGION,
		dc.STATUS_CODE,
		COUNT(*) AS CarrierCount
	FROM DimCarrier dc
		JOIN DimState st
	ON dc.PHY_STATE = st.STATE_CODE
	GROUP BY ROLLUP(st.OMC_REGION, dc.STATUS_CODE)
	ORDER BY st.OMC_REGION DESC, dc.STATUS_CODE DESC;

/* Q19. CUBE versus ROLLUP. Rewrite the Q18 query using the CUBE operator instead of ROLLUP, keeping the same columns and sort. 
In one or two sentences, describe how the CUBE result differs from the ROLLUP result — specifically, what additional summary rows CUBE adds for STATUS_CODE across all regions. */
	-- CUBE includes the same region subtotals as ROLLUP, but also adds status-code totals across all regions.
	SELECT
		st.OMC_REGION,
		dc.STATUS_CODE,
		COUNT(*) AS CarrierCount
	FROM DimCarrier dc
	JOIN DimState st
	ON dc.PHY_STATE = st.STATE_CODE
	GROUP BY CUBE(st.OMC_REGION, dc.STATUS_CODE)
	ORDER BY st.OMC_REGION DESC, dc.STATUS_CODE DESC;

/* Q20. GROUPING SETS. Using DimCarrier joined to DimState, write a GROUPING SETS query that produces only three kinds of summary rows: 
one set grouped by OMC_REGION alone, one set grouped by STATUS_CODE alone, and one grand-total row from an empty set of parentheses. 
Return OMC_REGION, STATUS_CODE, and COUNT(*) aliased CarrierCount. 
In one sentence, explain how GROUPING SETS lets you get exactly these rows without the extra combinations that CUBE would add. */
	-- GROUPING SETS returns only the summary groups list, while CUBE returns all possible group combinations above.
	SELECT
		st.OMC_REGION,
		dc.STATUS_CODE,
		COUNT(*) AS CarrierCount
	FROM DimCarrier dc
		JOIN DimState st
    ON dc.PHY_STATE = st.STATE_CODE
	GROUP BY GROUPING SETS
	(
		(st.OMC_REGION),
		(dc.STATUS_CODE),
		()
	);

	-----------------------------------------------
	-- Part D — The OVER clause (window aggregates)
	-----------------------------------------------
/* Q21. OVER with PARTITION BY. 
Join FactCarrierOperation to DimCarrier and return DOT_NUMBER, LEGAL_NAME, PHY_STATE, TOTAL_DRIVERS, and SUM(TOTAL_DRIVERS) OVER (PARTITION BY PHY_STATE) aliased StateDriverTotal. 
Restrict the result to carriers in a single state of your choice (for example PHY_STATE = 'TX') so the output is easy to read. 
In one sentence, explain how this differs from a GROUP BY version of the same totals. */
	-- This query returns a row for each carrier, with a total drivers count for the state repeated on each row, while a GROUP BY version would return one row per state with the total drivers for that state.
	SELECT
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		fc.TOTAL_DRIVERS,
		SUM(fc.TOTAL_DRIVERS) OVER (PARTITION BY dc.PHY_STATE) AS StateDriverTotal 
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc 
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE dc.PHY_STATE = 'TX'; 

/* Q22. OVER for a cumulative total and a moving average. 
Join FactCarrierOperation to DimCarrier, restricting to one state (for example PHY_STATE = 'CA') and to rows where MCS150_MILEAGE is greater than 0. 
Return LEGAL_NAME, MCS150_DATE, MCS150_MILEAGE, a running total SUM(MCS150_MILEAGE) OVER (ORDER BY MCS150_DATE) aliased CumulativeMileage, 
and AVG(MCS150_MILEAGE) OVER (ORDER BY MCS150_DATE) aliased MovingAvg. In one sentence, define what a cumulative total and a moving average are. */
	-- A cumulative total keeps adding values as rows go down, and a moving average shows the average up to the current row.
	SELECT
		dc.LEGAL_NAME,
		dc.MCS150_DATE,
		fc.MCS150_MILEAGE,
		SUM(fc.MCS150_MILEAGE) OVER (ORDER BY dc.MCS150_DATE) AS CumulativeMileage,
		AVG(fc.MCS150_MILEAGE) OVER (ORDER BY dc.MCS150_DATE) AS MovingAvg
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc 
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE dc.PHY_STATE = 'CA' AND fc.MCS150_MILEAGE > 0;

/* Q23. OVER with PARTITION BY and ORDER BY together. 
Extend Q22 across all states: return LEGAL_NAME, PHY_STATE, MCS150_DATE, MCS150_MILEAGE, and a per-state running total 
SUM(MCS150_MILEAGE) OVER (PARTITION BY PHY_STATE ORDER BY MCS150_DATE) aliased StateCumulativeMileage. 
In one sentence, explain what happens to the running total when the PHY_STATE value changes from one row to the next. */
	-- When the PHY_STATE value changes, the running total resets for each new state, creating a separate cumulative total for each state.
	-- 1. QUERY OPTION. matches Q23 broadly; Option 2 is cleaner for reading, but adds extra filters not clearly required by Q23.
	SELECT
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		dc.MCS150_DATE,
		fc.MCS150_MILEAGE,
		SUM(fc.MCS150_MILEAGE) 
		OVER 
		(PARTITION BY dc.PHY_STATE ORDER BY dc.MCS150_DATE) AS StateCumulativeMileage
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc 
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	-- 2. QUERY OPTION. Keeps only positive mileage rows and removes NULL state/date rows for cleaner output.
	SELECT
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		dc.MCS150_DATE,
		fc.MCS150_MILEAGE,
		SUM(fc.MCS150_MILEAGE) 
		OVER 
		(PARTITION BY dc.PHY_STATE ORDER BY dc.MCS150_DATE) AS StateCumulativeMileage
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.MCS150_MILEAGE > 0
	 AND dc.PHY_STATE IS NOT NULL
	 AND dc.MCS150_DATE IS NOT NULL;

	--------------------------------------
	-- Part E — Investigation (open-ended)
	--------------------------------------
/* Q24. (Dictionary) Investigation. 
Which states look like safety outliers? Using GROUP BY with aggregate functions and a HAVING clause, write at least one supporting query that surfaces states 
with an unusually high average RECORDABLE_CRASH_RATE or a large number of Unsatisfactory (U) safety ratings relative to their carrier count. 
Decide a reasonable threshold, justify it, and use the data dictionary to confirm the meaning of the safety codes. 
State your reasoning about what the numbers do and do not prove. */
	---------------------------------------
	-- 1. What am I investigating? Safety
	-- 2. What group am I comparing? States
	-- 3. What evidence will I use? Average Crash Rate
	-- 4. Which states look unusual? States with the highest average crash rates
	-- 5. What is my conclusion? Mississippi looks like a safety outlier because it has the highest average crash rate in the data
	------------------------------------------------------------------------------------------------------------------------------
	SELECT	-- 1. OPTION
		dc.PHY_STATE,
		AVG(fc.RECORDABLE_CRASH_RATE) AS AvgCrashRate
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	GROUP BY dc.PHY_STATE
	ORDER BY AvgCrashRate DESC;

	SELECT	-- 2. OPTION
		dc.PHY_STATE,
		COUNT(*) AS CarrierCount,
		AVG(fc.RECORDABLE_CRASH_RATE) AS AvgCrashRate
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
		JOIN DimState st
    ON dc.PHY_STATE = st.STATE_CODE
	GROUP BY dc.PHY_STATE
	HAVING COUNT(*) >= 100
		AND AVG(fc.RECORDABLE_CRASH_RATE) > 0
	ORDER BY AvgCrashRate DESC;

/* Q25. Investigation — what GROUP BY unlocks. 
In Session 2 you answered several “how many” questions by returning rows and reading the row count SSMS reported. 
Pick two of those questions and rewrite them as true summary queries using COUNT, SUM, or AVG with GROUP BY. 
Then describe, in a few sentences, what kinds of business questions about the trucking data you can now answer with summary queries 
that you could not answer with joins alone in Session 2, and name one question that would still require a technique beyond this chapter. */
	-- I PICKED Q3 AND Q5 FROM SESSION 2 
	-----------------------------------------------------------------------------------------------------------------------------
	-- EXPL: Session 2 listed carriers. Session 3 summarizes carriers by status using COUNT and GROUP BY.
	SELECT	-- QUERY FROM SESSION 2 --> Q3. RESULT 1 ROW PER CARRIER
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		s.STATUS_DESC
	FROM DimCarrier AS c
	INNER JOIN DimStatus AS s
	ON c.STATUS_CODE = s.STATUS_CODE
	WHERE s.STATUS_DESC = 'Inactive';

	SELECT	-- This query counts carriers in each status and sorts the results from highest to lowest count.
    ds.STATUS_DESC,
    COUNT(*) AS CarrierCount
FROM DimCarrier dc
JOIN DimStatus ds
    ON dc.STATUS_CODE = ds.STATUS_CODE
GROUP BY ds.STATUS_DESC
ORDER BY CarrierCount DESC;

	----------------------------------------------------------------------------------------------------------------------
	-- EPL: First query lists individual carriers. Second query groups by state and shows average mileage per state.
	SELECT TOP 20	-- QUERY FROM SESSION 2 --> Q5. Shows the top 20 carriers with the highest mileage in OMC Region 5.
		c.LEGAL_NAME,
		s.STATE_NAME,
		f.MCS150_MILEAGE
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	INNER JOIN DimState AS s
	ON c.PHY_STATE = s.STATE_CODE
	WHERE s.OMC_REGION = 5
	ORDER BY f.MCS150_MILEAGE DESC;

	SELECT	-- Since Q25 wants a summary query, I'll summarize Region 5 instead of listing carriers using AVG because it's different from COUNT.
		s.STATE_NAME,
		AVG(f.MCS150_MILEAGE) AS AvgMileage
	FROM FactCarrierOperation f
		JOIN DimCarrier c
    ON f.DOT_NUMBER = c.DOT_NUMBER
		JOIN DimState s
    ON c.PHY_STATE = s.STATE_CODE
	WHERE s.OMC_REGION = 5
	GROUP BY s.STATE_NAME
	ORDER BY AvgMileage DESC;
	-----------------------------------------------------------------------------------------------------------------------------
		-- SUMMARIZED DESCRIPTION.
	-- In Session 2, joins helped me view individual carrier records. In Session 3, summary queries let me count carriers by status and calculate average mileage by state. 
	-- This makes it easier to compare groups and identify trends. A question beyond this chapter would be predicting future crash rates or safety ratings.

