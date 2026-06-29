
		----------------------------
		/* SQL Practice Session 2 */
		----------------------------

/* Q1. Inner-join FactCarrierOperation to DimCarrier on DOT_NUMBER and return LEGAL_NAME, MCS150_MILEAGE, and TOTAL_DRIVERS for every carrier that has a matching row 
in both tables. Because DOT_NUMBER exists in both tables, qualify it with the table name in the join condition. In one sentence, explain what an inner join 
does to rows that have no match. */
-----------------------------------------------------------------------------------------------------------
/* EXPL: An INNER JOIN shows only rows that match in 2 or more tables. Rows with no match are not shown. */
-----------------------------------------------------------------------------------------------------------
	SELECT  -- OPTION 1: Without aliases.
		DimCarrier.DOT_NUMBER,
		LEGAL_NAME,
		MCS150_MILEAGE,
		TOTAL_DRIVERS
	FROM FactCarrierOperation
	INNER JOIN DimCarrier
	ON FactCarrierOperation.DOT_NUMBER = DimCarrier.DOT_NUMBER;

	SELECT  -- OPTION 2: With aliases.
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		f.MCS150_MILEAGE,
		f.TOTAL_DRIVERS
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER;

/* Q2. Rewrite the query from Q1 using correlation names (table aliases): assign f to FactCarrierOperation and c to DimCarrier with the AS keyword. 
Return the carrier name and RECORDABLE_CRASH_RATE, aliased as Crash Rate, and sort so the highest crash rate appears first. */
	SELECT  -- OPTION 1: Without aliases.
		DimCarrier.LEGAL_NAME,
		FactCarrierOperation.RECORDABLE_CRASH_RATE AS [Crash Rate]
	FROM FactCarrierOperation
	INNER JOIN DimCarrier
	ON FactCarrierOperation.DOT_NUMBER = DimCarrier.DOT_NUMBER
	ORDER BY FactCarrierOperation.RECORDABLE_CRASH_RATE DESC;
	
	SELECT  -- OPTION 2: With aliases.
		c.LEGAL_NAME,
		f.RECORDABLE_CRASH_RATE AS [Crash Rate]
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	ORDER BY f.RECORDABLE_CRASH_RATE DESC;

/* Q3. Decode a code with a lookup join. Inner-join DimCarrier to DimStatus and return DOT_NUMBER, LEGAL_NAME, and STATUS_DESC. 
Then add a WHERE clause that keeps only the carriers whose status description is Inactive (filter on the description column from DimStatus, not on the raw code). */
	SELECT
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		s.STATUS_DESC
	FROM DimCarrier AS c
	INNER JOIN DimStatus AS s
	ON c.STATUS_CODE = s.STATUS_CODE
	WHERE s.STATUS_DESC = 'Inactive';

/* Q4. Inner-join DimCarrier to DimCarrierOperation to return DOT_NUMBER, LEGAL_NAME, and OPERATION_DESC for interstate carriers only. 
Combine this with a Session 1 skill: also require that LEGAL_NAME contains the word “TRANS”. Sort by LEGAL_NAME. */
	SELECT
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		o.OPERATION_DESC
	FROM DimCarrier AS c
	INNER JOIN DimCarrierOperation AS o
	ON c.CARRIER_OPERATION = o.CARRIER_OPERATION
	WHERE o.OPERATION_DESC = 'Interstate'
	AND c.LEGAL_NAME LIKE '%TRANS%'
	ORDER BY c.LEGAL_NAME;

/* Q5. Three-table inner join. Join FactCarrierOperation, DimCarrier, and DimState to return LEGAL_NAME, STATE_NAME, and MCS150_MILEAGE 
for carriers physically located in FMCSA region 5 (DimState.OMC_REGION = 5). Return only the 20 carriers with the highest mileage, largest first. */
	SELECT TOP 20
		c.LEGAL_NAME,
		s.STATE_NAME,
		f.MCS150_MILEAGE
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	INNER JOIN DimState AS s
	ON c.PHY_STATE = s.STATE_CODE
	WHERE s.OMC_REGION = 5
	ORDER BY f.MCS150_MILEAGE DESC

/* Q6. Four-table inner join. Join DimCarrier to DimStatus, DimCarrierOperation, and DimFleetSize to produce a fully decoded row: 
DOT_NUMBER, LEGAL_NAME, STATUS_DESC, OPERATION_DESC, and POWER_UNITS_RANGE. Limit the result to active interstate carriers, and sort by LEGAL_NAME. */
	SELECT
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		s.STATUS_DESC,
		o.OPERATION_DESC,
		f.POWER_UNITS_RANGE
	FROM DimCarrier AS c
	INNER JOIN DimStatus AS s
	ON c.STATUS_CODE = s.STATUS_CODE
	INNER JOIN DimCarrierOperation AS o
	ON c.CARRIER_OPERATION = o.CARRIER_OPERATION
	INNER JOIN DimFleetSize AS f
	ON c.FLEETSIZE = f.FLEETSIZE
	WHERE s.STATUS_DESC = 'Active'
	AND o.OPERATION_DESC = 'Interstate'
	ORDER BY c.LEGAL_NAME;

/* Q7. Compound conditions — ON vs. WHERE. Join FactCarrierOperation and DimCarrier on DOT_NUMBER and return only carriers with TOTAL_DRIVERS greater than 100. 
Write the query twice: (a) with the driver test coded inside the ON clause together with the join condition, and (b) with the join condition in ON and 
the driver test in a WHERE clause. State which version the textbook recommends for readability. */
-- (a) Driver test in ON clause
	SELECT
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		f.TOTAL_DRIVERS
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	AND f.TOTAL_DRIVERS > 100;
-- (b) Driver test in WHERE clause
	SELECT
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		f.TOTAL_DRIVERS
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	WHERE f.TOTAL_DRIVERS > 100;

/* Q8. Implicit syntax. Rewrite the inner join from Q1 using the older implicit syntax (list both tables in the FROM clause separated by a comma and put the join 
condition in the WHERE clause). Then explain, in one sentence, the common mistake that this syntax makes easy and why the book recommends the explicit syntax instead. */
	---------------------------------------------------------------------------------------------------------------------------------
	/* EXPL: Implicit join is the old way of joining tables by listing tables in FROM and writing the matching condition in WHERE. */
	---------------------------------------------------------------------------------------------------------------------------------
	SELECT
		c.LEGAL_NAME,
		f.MCS150_MILEAGE
	FROM FactCarrierOperation f, DimCarrier c
	WHERE f.DOT_NUMBER = c.DOT_NUMBER;

/* Q9. (Dictionary) Self-join on a key. Some carriers were issued a new USDOT number after a prior one was revoked. Join DimCarrier to itself so that the second copy
is matched on cur.PRIOR_REVOKE_DOT_NUMBER = prior.DOT_NUMBER. Return the current carrier’s DOT_NUMBER and LEGAL_NAME alongside the prior (revoked) carrier’s 
DOT_NUMBER and LEGAL_NAME. Use the data dictionary to confirm the meaning of PRIOR_REVOKE_FLAG and PRIOR_REVOKE_DOT_NUMBER. */
	SELECT
		cur.DOT_NUMBER AS Current_DOT,
		cur.LEGAL_NAME AS Current_Legal_Name,
		prior.DOT_NUMBER AS Prior_DOT,
		prior.LEGAL_NAME AS Prior_Legal_Name
	FROM DimCarrier AS cur
	INNER JOIN DimCarrier AS prior
	ON cur.PRIOR_REVOKE_DOT_NUMBER = prior.DOT_NUMBER
	WHERE cur.PRIOR_REVOKE_FLAG = 'Y';

/* Q10. Self-join on a shared attribute. Using a self-join on DimCarrier, return the DISTINCT list of carriers that share the same 
PHY_CITY and PHY_STATE as at least one OTHER carrier. The join condition needs three comparisons: equal city, equal state, and unequal DOT_NUMBER. 
Show LEGAL_NAME, PHY_CITY, and PHY_STATE, sorted by state then city. Explain why DISTINCT is needed here. */
	SELECT DISTINCT
		c1.LEGAL_NAME,
		c1.PHY_CITY,
		c1.PHY_STATE
	FROM DimCarrier AS c1
	INNER JOIN DimCarrier AS c2
	ON c1.PHY_CITY = c2.PHY_CITY
	AND c1.PHY_STATE = c2.PHY_STATE
	AND c1.DOT_NUMBER <> c2.DOT_NUMBER
	ORDER BY c1.PHY_STATE, c1.PHY_CITY;

/* Q11. Left outer join to find missing matches. Starting from DimState and LEFT JOINing DimCarrier on the state code, return the STATE_CODE and STATE_NAME 
of every state or territory that has NO carrier physically located in it. (Hint: keep the rows where the carrier side is NULL.) */
	SELECT
		s.STATE_CODE,
		s.STATE_NAME
	FROM DimState AS s
	LEFT JOIN DimCarrier AS c
	ON s.STATE_CODE = c.PHY_STATE
	WHERE c.PHY_STATE IS NULL;

/* Q12. Left outer join that keeps unmatched fact rows. Join FactCarrierOperation to DimCarrier (for the name) and LEFT JOIN DimSafetyRating so that carriers 
which have never been rated still appear, with their SAFETY_RATING_DESC shown as NULL. Return LEGAL_NAME, SAFETY_RATING, and SAFETY_RATING_DESC. 
Explain why an inner join would have hidden the never-rated carriers. */
---------------------------------------------------------------------
-- GOAL: show carriers even if safety rating description is missing
-- EXPL: LEFT JOIN keeps carriers even when no safety rating match.
----------------------------------------------------------------------
	SELECT
		c.LEGAL_NAME,
		f.SAFETY_RATING,
		s.SAFETY_RATING_DESC
		FROM FactCarrierOperation AS f
		INNER JOIN DimCarrier AS c
		ON f.DOT_NUMBER = c.DOT_NUMBER
		LEFT JOIN DimSafetyRating AS s
		ON f.SAFETY_RATING = s.SAFETY_RATING;

/* Q13. Right outer join, then convert it. Write a RIGHT JOIN that lists every safety rating in DimSafetyRating together with the carriers that hold it, 
including any rating that no carrier currently has (those rows show NULL on the carrier side). Then rewrite the exact same result using a LEFT JOIN 
by swapping the table order, and explain why the book recommends preferring LEFT joins. */
	SELECT  -- RIGHT JOIN version
		s.SAFETY_RATING_DESC,
		c.LEGAL_NAME
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	RIGHT JOIN DimSafetyRating AS s
	ON f.SAFETY_RATING = s.SAFETY_RATING;

	SELECT  -- LEFT JOIN version EXPL: LEFT JOIN is preferred because it is easier to read from left to right.
		s.SAFETY_RATING_DESC,
		c.LEGAL_NAME
	FROM DimSafetyRating AS s
	LEFT JOIN FactCarrierOperation AS f
	ON s.SAFETY_RATING = f.SAFETY_RATING
	LEFT JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER;

/* Q14. Full outer join. FULL JOIN DimState to StateGovernment2026 on the state code and return DimState.STATE_CODE, STATE_NAME, and GOVERNOR. 
Identify (you may add a WHERE) the rows that exist in DimState but have no governor row, and note whether any governor rows have no matching DimState row. */
	SELECT
		ds.STATE_CODE,
		ds.STATE_NAME,
		sg.GOVERNOR
	FROM DimState AS ds
	FULL OUTER JOIN StateGovernment2026 AS sg
	ON ds.STATE_CODE = sg.STATE_CODE;

	SELECT  -- query to identify rows with no governor
		ds.STATE_CODE,
		ds.STATE_NAME,
		sg.GOVERNOR
	FROM DimState AS ds
	FULL OUTER JOIN StateGovernment2026 AS sg
	ON ds.STATE_CODE = sg.STATE_CODE
	WHERE sg.GOVERNOR IS NULL;

/* Q15. Combine an inner and an outer join in one statement. Inner-join DimCarrier to DimState (so only carriers with a valid state are kept), then LEFT JOIN 
StateGovernment2026 so a carrier located in a U.S. territory with no governor row still appears. Return LEGAL_NAME, STATE_NAME, and GOVERNOR (which may be NULL). */
	SELECT
		c.LEGAL_NAME,
		ds.STATE_NAME,
		sg.GOVERNOR
	FROM DimCarrier AS c
	INNER JOIN DimState AS ds
	ON c.PHY_STATE = ds.STATE_CODE
	LEFT JOIN StateGovernment2026 AS sg
	ON ds.STATE_CODE = sg.STATE_CODE

/* Q16. Cross join. Write a CROSS JOIN of DimStatus and DimSafetyRating that lists every possible (STATUS_DESC, SAFETY_RATING_DESC) combination. 
How many rows does it return, and why? Describe one legitimate use for such a Cartesian product. */
	-------------------------------------------------------------------------------
	-- CROSS JOIN returns every possible combination of rows from 2 or more tables.
	-- ROW COUNT: 3 STATUS_DESC x 3 SAFETY_RATING_DESC = 9 rows.
	-- LEGITIMATE USE: Creating all possible comb for testing or reporting.
	--------------------------------------------------------------------------------
	SELECT  
		s.STATUS_DESC,
		sr.SAFETY_RATING_DESC
	FROM DimStatus AS s
	CROSS JOIN DimSafetyRating AS sr;

/* Q17. Union from the same tables with a label column. Build one result set with two SELECTs joined by UNION. 
The first returns carriers with TOTAL_DRIVERS > 100 and a literal column Fleet Class containing ‘Large’; the second returns carriers with 
TOTAL_DRIVERS <= 100 and Fleet Class ‘Small or Mid’. Each SELECT returns Fleet Class, DOT_NUMBER, and LEGAL_NAME (join FactCarrierOperation to DimCarrier). 
Sort the combined result by Fleet Class then LEGAL_NAME. */
	SELECT
		'Large' AS [Fleet Class],
		c.DOT_NUMBER,
		c.LEGAL_NAME
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	WHERE f.TOTAL_DRIVERS > 100
		UNION  --> combines results from multiple SELECT statements into one result set.
	SELECT
		'Small or Mid' AS [Fleet Class],
		c.DOT_NUMBER,
		c.LEGAL_NAME
	FROM FactCarrierOperation AS f
	INNER JOIN DimCarrier AS c
	ON f.DOT_NUMBER = c.DOT_NUMBER
	WHERE f.TOTAL_DRIVERS <= 100
	ORDER BY [Fleet Class], LEGAL_NAME;

/* Q18. Union across different tables. Produce a two-column list of State Code and Source where the first SELECT returns the distinct PHY_STATE 
values that appear in DimCarrier (Source = ‘Has Carriers’) and the second returns the STATE_CODE values from StateGovernment2026 (Source = ‘Has Governor’). 
Then explain the difference between UNION and UNION ALL and which one you used. */
	---------------------------------------------------------------------------------------------------------------------------------------------------------
	-- UNION removes duplicate rows, while UNION ALL keeps them. However, both queries returns same result cause there's no duplicate rows in the result set.
	---------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT DISTINCT
		PHY_STATE AS [State Code],
		'Has Carriers' AS [Source]
	FROM DimCarrier
	UNION
	SELECT
		STATE_CODE AS [State Code],
		'Has Governor' AS [Source]
	FROM StateGovernment2026
	ORDER BY [State Code];

/* Q19. EXCEPT. Return the state/territory codes that exist in DimState but do NOT appear in StateGovernment2026, using the EXCEPT operator. 
In a comment, describe how you could get the same answer with a LEFT OUTER JOIN instead. */
	SELECT
		STATE_CODE
	FROM DimState
	EXCEPT  --> returns rows from 1st SELECT that don't exist in 2nd SELECT.
	SELECT
		STATE_CODE
	FROM StateGovernment2026
--Same result could be done with LEFT JOIN and WHERE StateGovernment2026.STATE_CODE IS NULL.
	SELECT
		ds.STATE_CODE
	FROM DimState AS ds
	LEFT JOIN StateGovernment2026 AS sg  
	ON ds.STATE_CODE = sg.STATE_CODE	
	WHERE sg.STATE_CODE IS NULL;

/* Q20. INTERSECT. Return the state codes that appear in BOTH StateGovernment2026 and USCities (that is, states that have a governor row and at least one city), 
using the INTERSECT operator. Sort the result. */
	SELECT
		STATE_CODE
	FROM StateGovernment2026
	INTERSECT  --> returns rows that exist in both SELECT statements.
	SELECT
		state_id AS STATE_CODE
	FROM USCities
	ORDER BY STATE_CODE;

/* Q21. Join to the date dimension. Join DimCarrier to DimDate by matching CAST(DimCarrier.MCS150_DATE AS date) to DimDate.FullDate, and return LEGAL_NAME, 
DimDate.MonthName, DimDate.[Year], and DimDate.QuarterName for carriers whose MCS-150 was filed in federal fiscal Q1 of fiscal year 2026 
(DimDate.FiscalYear = 2026 AND DimDate.FiscalQuarter = 1). Sort by FullDate. */
	SELECT
		c.LEGAL_NAME,
		d.MonthName,
		d.[Year],
		d.QuarterName
	FROM DimCarrier AS c
	INNER JOIN DimDate AS d
	ON CAST(c.MCS150_DATE AS date) = d.FullDate
	WHERE d.FiscalYear = 2026 AND d.FiscalQuarter = 1
	ORDER BY d.FullDate;

/* Q22. Multi-table join with the political data. List carriers located in states whose Senate is Republican-controlled with a supermajority 
(StateGovernment2026.SENATE_CONTROL = ‘R’ AND SENATE_SUPERMAJORITY = 1). Join DimCarrier to StateGovernment2026 on the state code, and also join USCities
on state_id AND city_ascii to bring in the county_name. Return LEGAL_NAME, PHY_CITY, county_name, STATE_NAME (from StateGovernment2026), and GOVERNOR. */
	SELECT
		c.LEGAL_NAME,
		c.PHY_CITY,
		u.county_name,
		sg.STATE_NAME,
		sg.GOVERNOR
	FROM DimCarrier AS c
	INNER JOIN StateGovernment2026 AS sg
	ON c.PHY_STATE = sg.STATE_CODE
	INNER JOIN USCities AS u
	ON c.PHY_STATE = u.state_id AND c.PHY_CITY = u.city_ascii
	WHERE sg.SENATE_CONTROL = 'R' AND sg.SENATE_SUPERMAJORITY = 1;

/* Q23. Outer join for data quality. LEFT JOIN DimCarrier to USCities on PHY_STATE = state_id AND PHY_CITY = city_ascii, and return the carriers 
whose city/state combination does NOT match any row in USCities (the USCities side is NULL). Return DOT_NUMBER, LEGAL_NAME, PHY_CITY, and 
PHY_STATE. Explain in one or two sentences why this list is worth a closer look. */
	SELECT
		c.DOT_NUMBER,
		c.LEGAL_NAME,
		c.PHY_CITY,
		c.PHY_STATE
	FROM DimCarrier AS c
	LEFT JOIN USCities AS u
	ON c.PHY_STATE = u.state_id AND c.PHY_CITY = u.city_ascii
	WHERE u.city_ascii IS NULL;
	-------------------------------------------------------------------------------------------------------
	-- This list is worth checking because some carriers van be wrong or misspelled city/state information.
	-------------------------------------------------------------------------------------------------------

/* Q24. Investigation (open-ended). You suspect a handful of carriers may be fraudulent or misregistered. Using only joins (no aggregates), 
describe where you would start and write at least one supporting query. Ideas to consider: carriers that were re-issued after a revoked DOT 
(self-join from Q9), active carriers with large fleets whose PHY_CITY/PHY_STATE does not exist in USCities (Q23), or carriers whose state shows 
unusual patterns. State your reasoning. */
	SELECT 
		cur.DOT_NUMBER AS Current_DOT,
		cur.LEGAL_NAME AS Current_Legal_Name,
		prior.DOT_NUMBER AS Prior_DOT,
		prior.LEGAL_NAME AS Prior_Legal_Name
	FROM DimCarrier AS cur
	INNER JOIN DimCarrier AS prior
	ON cur.PRIOR_REVOKE_DOT_NUMBER = prior.DOT_NUMBER
	WHERE cur.PRIOR_REVOKE_FLAG = 'Y';

/* Q25. Investigation (open-ended). Is there any relationship between where the largest carriers are based and the political control of that state? 
Write a join that lists high-driver carriers together with their state’s GOVERNOR, SENATE_CONTROL, and HOUSE_CONTROL 
(DimCarrier → StateGovernment2026, optionally → DimState for region). 
Describe what you can and cannot conclude using only the techniques from Sessions 1 and 2, and what you would need GROUP BY for. */
	SELECT
		c.LEGAL_NAME,
		f.TOTAL_DRIVERS,
		sg.STATE_NAME,
		sg.GOVERNOR,
		sg.SENATE_CONTROL,
		sg.HOUSE_CONTROL
	FROM DimCarrier AS c
	INNER JOIN FactCarrierOperation AS f ON c.DOT_NUMBER = f.DOT_NUMBER
	INNER JOIN StateGovernment2026 AS sg ON c.PHY_STATE = sg.STATE_CODE
	WHERE f.TOTAL_DRIVERS > 100
	ORDER BY f.TOTAL_DRIVERS DESC;
	-- This query helps compare large carriers with the political control of their states.
	-- Using only Sessions 1 and 2 techniques, we can list and inspect the data, but we cannot calculate totals or averages by political party.

	