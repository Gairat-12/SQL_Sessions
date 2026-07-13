
	
	
	/* SQL Practice Session 4 */

-- Part A – Subqueries in search conditions (WHERE / HAVING)
------------------------------------------------------------
/* Q1. Your first subquery in a WHERE clause. Write a SELECT statement against FactCarrierOperation that returns DOT_NUMBER and MCS150_MILEAGE for every carrier whose MCS150_MILEAGE 
is greater than the average MCS150_MILEAGE of all carriers. Use a subquery that returns AVG(MCS150_MILEAGE) in the WHERE clause and sort by MCS150_MILEAGE descending. 
In one sentence, explain why this single-value subquery can be used anywhere an expression is allowed. */
-- The subquery calculates the average MCS150_MILEAGE, and the main query returns only the carriers whose mileage is greater than that average
		-- Mental Flow. SELECT -> FROM -> WHERE -> (Subquery) -> ORDER BY
	SELECT
		DOT_NUMBER,
		MCS150_MILEAGE
	FROM FactCarrierOperation
	WHERE MCS150_MILEAGE > 
		(SELECT AVG(MCS150_MILEAGE) 
		FROM FactCarrierOperation)
	ORDER BY MCS150_MILEAGE DESC 

/* Q2. A subquery with the IN operator. 
Return DOT_NUMBER, LEGAL_NAME, and PHY_STATE from DimCarrier for every carrier physically located in OMC region 9. 
Provide the list of states with a subquery against DimState that returns STATE_CODE WHERE OMC_REGION = 9, used with the IN operator. 
In one sentence, state the rule about how many columns a subquery used with IN may return. */
	-- The subquery must return one column only. The values returned are compared to the outer query's PHY_STATE column using the IN operator.
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE
	FROM DimCarrier
	WHERE PHY_STATE IN 
		(SELECT STATE_CODE 
		FROM DimState 
		WHERE OMC_REGION = 9) 
							
/* Q3. The same query restated as a join. 
Rewrite your Q2 answer so it uses an inner join between DimCarrier and DimState instead of a subquery, returning the same three columns. 
In one sentence, say which version you find more readable here and why the chapter says a join is often the better choice for an existing key relationship. */
	-- Both Q2 and Q3 return the same results. I find the JOIN version more readable because DimCarrier and DimState have an existing relationship through PHY_STATE and STATE_CODE.
	SELECT 
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE
	FROM DimCarrier dc
		INNER JOIN DimState ds ON dc.PHY_STATE = ds.STATE_CODE
	WHERE ds.OMC_REGION = 9

/* Q4. NOT IN with a subquery. Return DOT_NUMBER and LEGAL_NAME from DimCarrier for every carrier that has no row in FactCarrierOperation. 
Use the NOT IN operator with a subquery that returns DISTINCT DOT_NUMBER from FactCarrierOperation, and sort by DOT_NUMBER. 
In one sentence, explain why the chapter says a NOT IN subquery like this can typically be restated as an outer join that tests IS NULL. */
	-- The query returned no rows because all carriers in DimCarrier have matching records in FactCarrierOperation, so no carriers met the NOT IN condition.
-- A NOT IN subquery can be rewritten as a LEFT JOIN with IS NULL because unmatched rows produce NULL values in the joined table. This version returns the same result.
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME
	FROM DimCarrier
	WHERE DOT_NUMBER NOT IN 
		(SELECT DISTINCT DOT_NUMBER 
		FROM FactCarrierOperation)
	ORDER BY DOT_NUMBER

/* Q5. A comparison operator with an aggregate subquery. 
Return DOT_NUMBER, RECORDABLE_CRASH_RATE, and POWER_UNITS from FactCarrierOperation for every carrier 
whose RECORDABLE_CRASH_RATE is below the average crash rate of all carriers that have a crash rate greater than 0. 
Restrict the outer query to rows with RECORDABLE_CRASH_RATE greater than 0, calculate the average in a subquery that applies the same greater than >0 
filter, and sort by RECORDABLE_CRASH_RATE descending. */
	SELECT
		DOT_NUMBER,
		RECORDABLE_CRASH_RATE,
		POWER_UNITS
	FROM FactCarrierOperation
	WHERE RECORDABLE_CRASH_RATE > 0
		AND RECORDABLE_CRASH_RATE < 
		(SELECT AVG(RECORDABLE_CRASH_RATE) 
		FROM FactCarrierOperation 
		WHERE RECORDABLE_CRASH_RATE > 0)
	ORDER BY RECORDABLE_CRASH_RATE DESC

/* Q6. The ALL keyword (then rewrite it). 
Join FactCarrierOperation to DimCarrier and return DOT_NUMBER, LEGAL_NAME, and POWER_UNITS for every carrier whose POWER_UNITS is greater than ALL of the POWER_UNITS 
values reported by carriers in California (PHY_STATE = 'CA'). Then, below it, write the equivalent query that replaces > ALL with a single comparison to MAX(POWER_UNITS), 
and note in one sentence which the chapter recommends. */
	SELECT	-- QRY USING ALL
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		fc.POWER_UNITS
	FROM DimCarrier AS dc
		INNER JOIN FactCarrierOperation AS fc 
	ON dc.DOT_NUMBER = fc.DOT_NUMBER
	WHERE fc.POWER_UNITS > ALL 
		(SELECT POWER_UNITS
		FROM FactCarrierOperation AS fc2
		INNER JOIN DimCarrier AS dc2 ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.PHY_STATE = 'CA')
	ORDER BY fc.POWER_UNITS DESC
	-- The chapter recommends using MAX() instead of > ALL because it is easier to read and maintain.
	SELECT	-- QUERY USING MAX
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		fc.POWER_UNITS
	FROM FactCarrierOperation AS fc
		INNER JOIN DimCarrier AS dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.POWER_UNITS >
		(SELECT MAX(fc2.POWER_UNITS)
		FROM FactCarrierOperation AS fc2
		INNER JOIN DimCarrier AS dc2 ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.PHY_STATE = 'CA')
	ORDER BY fc.POWER_UNITS DESC;

/* Q7. The ANY / SOME keyword. 
Join FactCarrierOperation to DimCarrier and return DOT_NUMBER, LEGAL_NAME, and TOTAL_DRIVERS for every carrier whose 
TOTAL_DRIVERS is less than ANY of the TOTAL_DRIVERS values reported by carriers in fleet size 'Z' (Over 5000 power units). 
In one sentence, explain what < ANY means in terms of the maximum value returned by the subquery, and why an equivalent query with MAX is usually clearer. */
	-- < ANY means less than at least one value returned by the subquery
	-- MAX() usually clearer because comparing to a single maximum value is easier to understand.
	SELECT 
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		fc.TOTAL_DRIVERS
	FROM FactCarrierOperation AS fc
		JOIN DimCarrier AS dc
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.TOTAL_DRIVERS < ANY
		(SELECT fc2.TOTAL_DRIVERS 
		FROM FactCarrierOperation fc2
		JOIN DimCarrier dc2 ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.FLEETSIZE = 'Z')
	ORDER BY fc.TOTAL_DRIVERS DESC;

	SELECT		-- QRY USING SOME
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		fc.TOTAL_DRIVERS
	FROM FactCarrierOperation AS fc
		JOIN DimCarrier AS dc
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.TOTAL_DRIVERS < SOME
		(SELECT fc2.TOTAL_DRIVERS 
		FROM FactCarrierOperation fc2
		JOIN DimCarrier dc2 ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.FLEETSIZE = 'Z')
	ORDER BY fc.TOTAL_DRIVERS DESC;

/* Q8. A subquery in a HAVING clause. 
Join FactCarrierOperation to DimCarrier, group by PHY_STATE, and return PHY_STATE with AVG(TOTAL_DRIVERS) aliased AvgDrivers. 
Use a HAVING clause whose search condition compares the group's AVG(TOTAL_DRIVERS) with a subquery that returns the overall AVG(TOTAL_DRIVERS) across all carriers, 
keeping only the states whose average exceeds the national average. Sort by AvgDrivers descending. */
	-- HAVING is required because the query filters grouped averages, and aggregate values can't be used in the WHERE clause.
	SELECT 
		dc.PHY_STATE,
		AVG(fc.TOTAL_DRIVERS) AS AvgDrivers
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc 
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	GROUP BY dc.PHY_STATE
	HAVING AVG(fc.TOTAL_DRIVERS) >
		(SELECT AVG(TOTAL_DRIVERS)
		FROM FactCarrierOperation)
	ORDER BY AvgDrivers DESC;

	---------------------------------------------------------
	-- Part B – Correlated subqueries and the EXISTS operator
	---------------------------------------------------------

	SELECT -- NONCORRELATED (INDEPENDENT) 
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		fc.TOTAL_DRIVERS
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.TOTAL_DRIVERS >
		(SELECT AVG(fc2.TOTAL_DRIVERS)	-- INNER QRY EXC 1ST
		FROM FactCarrierOperation fc2)
	ORDER BY fc.TOTAL_DRIVERS DESC;

	SELECT -- CORRELATED (DEPENDENT)
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		fc.TOTAL_DRIVERS
	FROM FactCarrierOperation fc	-- OUTER QRY EXC 1ST
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.TOTAL_DRIVERS >
		(SELECT AVG(fc2.TOTAL_DRIVERS)
		FROM FactCarrierOperation fc2
			JOIN DimCarrier dc2
        ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.PHY_STATE = dc.PHY_STATE)
	ORDER BY fc.TOTAL_DRIVERS DESC;


/* Q9. Your first correlated subquery. 
Join FactCarrierOperation to DimCarrier and return DOT_NUMBER, PHY_STATE, and MCS150_MILEAGE for every carrier whose MCS150_MILEAGE is greater than the average MCS150_MILEAGE of all carriers 
in the same state. Code a correlated subquery whose WHERE clause matches the inner carrier's PHY_STATE to the outer carrier's PHY_STATE, using correlation names (aliases) to remove ambiguity. 
In one sentence, explain why this subquery runs once for each row of the outer query. */
		-- This is a correlated subquery because the inner query uses dc.PHY_STATE
		-- from the outer query, so it calculates a different state average for each row.
	SELECT
		fc.DOT_NUMBER,
		dc.PHY_STATE,
		fc.MCS150_MILEAGE
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc 
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.MCS150_MILEAGE >
		(SELECT AVG(fc2.MCS150_MILEAGE)
		FROM FactCarrierOperation fc2
			JOIN DimCarrier dc2
		ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.PHY_STATE = dc.PHY_STATE)
	ORDER BY dc.PHY_STATE, fc.MCS150_MILEAGE DESC;

/* Q10. The EXISTS operator. 
Return DOT_NUMBER and LEGAL_NAME from DimCarrier for every carrier that DOES have at least one row in FactCarrierOperation, using EXISTS with a correlated subquery 
that selects an asterisk and matches DOT_NUMBER. In one sentence, explain why it does not matter what columns the subquery lists in its SELECT clause. */
	-- It does not matter what columns are listed in the subquery's SELECT clause
	-- because EXISTS only checks whether any matching rows exist.
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME
	FROM DimCarrier dc
	WHERE EXISTS
		(SELECT *
		FROM FactCarrierOperation fc
		WHERE fc.DOT_NUMBER = dc.DOT_NUMBER)
	ORDER BY dc.DOT_NUMBER

/* Q11. NOT EXISTS (compare with Q4). Rewrite your Q4 answer (carriers with no fact row) so it uses NOT EXISTS with a correlated subquery instead of NOT IN. 
Return DOT_NUMBER and LEGAL_NAME and sort by DOT_NUMBER. In one sentence, state why the chapter says an EXISTS query like this usually runs more quickly than the equivalent 
IN or outer-join version. */
	-- EXISTS does not actually return a result set; it only checks whether matching rows exist, so queries using EXISTS execute more quickly.
	-- This query returns the same result as Q4 because both queries answer the same question using different techniques.
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME
	FROM DimCarrier dc
	WHERE NOT EXISTS
		(SELECT *
		FROM FactCarrierOperation fc
		WHERE fc.DOT_NUMBER = dc.DOT_NUMBER)
	ORDER BY dc.DOT_NUMBER

/* Q12. (Dictionary) A correlated subquery against a lookup. 
Join FactCarrierOperation to DimCarrier and return DOT_NUMBER, LEGAL_NAME, and RECORDABLE_CRASH_RATE for every carrier whose crash rate is greater than 
the average crash rate for its own CARRIER_OPERATION group (Interstate, Intrastate Hazmat, or Intrastate Non-Hazmat). Use a correlated subquery that matches 
CARRIER_OPERATION between the inner and outer queries, and use the data dictionary to confirm what the A, B, and C operation codes mean. 
	-- CARRIER OPERATION CODES :	A = Interstate
									B = Intrastate Hazmat
									C = Intrastate Non-Hazmat */
	SELECT
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.CARRIER_OPERATION + ' - ' + co.OPERATION_DESC AS CarrierOperationGroup,
		fc.RECORDABLE_CRASH_RATE
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
		JOIN DimCarrierOperation co ON dc.CARRIER_OPERATION = co.CARRIER_OPERATION
	WHERE fc.RECORDABLE_CRASH_RATE >
		(SELECT AVG(fc2.RECORDABLE_CRASH_RATE)
		FROM FactCarrierOperation fc2
			JOIN DimCarrier dc2 
		ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
		WHERE dc2.CARRIER_OPERATION = dc.CARRIER_OPERATION)
	ORDER BY dc.CARRIER_OPERATION, fc.RECORDABLE_CRASH_RATE DESC;

/* Q13. A correlated subquery over the self-referencing column. 
Return DOT_NUMBER, LEGAL_NAME, and PRIOR_REVOKE_DOT_NUMBER from DimCarrier for every carrier whose PRIOR_REVOKE_DOT_NUMBER points to a DOT_NUMBER that actually exists 
in the DimCarrier table. Use EXISTS with a correlated subquery that looks the prior carrier up in a second reference to DimCarrier, and sort by DOT_NUMBER. */
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PRIOR_REVOKE_DOT_NUMBER
	FROM DimCarrier dc
	WHERE EXISTS
		(SELECT *
		FROM DimCarrier dc2
		WHERE dc2.DOT_NUMBER = dc.PRIOR_REVOKE_DOT_NUMBER)
	ORDER BY dc.DOT_NUMBER

	-----------------------------------------------------
	-- Part C – Subqueries in the FROM and SELECT clauses
	-----------------------------------------------------
/* Q14. Your first derived table. Write a subquery in the FROM clause that groups FactCarrierOperation joined to DimCarrier by PHY_STATE and returns the TOP 5 states 
by SUM(TOTAL_DRIVERS) (aliased StateDrivers, ORDER BY StateDrivers DESC). Give the derived table an alias, then in the outer query return its PHY_STATE and StateDrivers. 
In one sentence, explain why the derived table must be given an alias and why its calculated column must be named. */
	-- This query uses a derived table to create a temporary result set containing the top 5 states by total drivers, which the outer query then selects from.
	SELECT
		PHY_STATE,
		StateDrivers
	FROM
		(SELECT TOP 5 dc.PHY_STATE,
        SUM(fc.TOTAL_DRIVERS) AS StateDrivers
		FROM FactCarrierOperation fc
		JOIN DimCarrier dc
        ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE
		ORDER BY StateDrivers DESC) AS TopStates
	ORDER BY StateDrivers DESC;

/* Q15. Join a derived table back to detail. 
Extend Q14: join the TOP 5 derived table back to FactCarrierOperation / DimCarrier on PHY_STATE, group the result by PHY_STATE, and return PHY_STATE, COUNT(*) aliased 
CarrierCount, and AVG(RECORDABLE_CRASH_RATE) aliased AvgCrashRate for each of those five states. Sort by CarrierCount descending. 
In one sentence, say why derived tables are described as most useful for further summarizing a summary query. */
	SELECT
		dc.PHY_STATE,
		COUNT(*) AS CarrierCount,
		AVG(fc.RECORDABLE_CRASH_RATE) AS AvgCrashRate
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
	ON fc.DOT_NUMBER = dc.DOT_NUMBER
		JOIN
		(SELECT TOP 5 dc.PHY_STATE,
		SUM(fc.TOTAL_DRIVERS) AS StateDrivers
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc
		ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE
		ORDER BY StateDrivers DESC) AS TopStates
	ON dc.PHY_STATE = TopStates.PHY_STATE
	GROUP BY dc.PHY_STATE
	ORDER BY CarrierCount DESC

/* Q16. A correlated subquery in the SELECT clause. 
From DimCarrier, return DISTINCT LEGAL_NAME together with a correlated subquery in the SELECT clause that returns MAX(REVIEW_DATE) from FactCarrierOperation for that carrier, 
aliased LatestReview. Sort by LatestReview descending. 
In one sentence, state why a subquery in a SELECT clause must return a single value. */
	-- A subquery in the SELECT clause must return one value because each outer row needs a single column value.
	SELECT DISTINCT
		LEGAL_NAME,
		(SELECT MAX(REVIEW_DATE)
		FROM FactCarrierOperation fc
		WHERE fc.DOT_NUMBER = dc.DOT_NUMBER) AS LatestReview
	FROM DimCarrier dc
	ORDER BY LatestReview DESC

/* Q17. Restate Q16 as a join. Rewrite Q16 so it uses a LEFT JOIN between DimCarrier and FactCarrierOperation with GROUP BY and MAX(REVIEW_DATE) 
instead of a subquery in the SELECT clause. Return LEGAL_NAME and LatestReview, sorted by LatestReview descending. 
In one sentence, explain why the chapter says this join version is both easier to read and faster to run. */
-- The join version is easier to read and faster to run because it avoids executing a subquery for each outer row.
	SELECT
		dc.LEGAL_NAME,
		MAX(fc.REVIEW_DATE) AS LatestReview
	FROM DimCarrier dc
		LEFT JOIN FactCarrierOperation fc ON dc.DOT_NUMBER = fc.DOT_NUMBER
	GROUP BY dc.LEGAL_NAME
	ORDER BY LatestReview DESC

/* Q18. A subquery that feeds a derived table its threshold. Build a derived table that groups FactCarrierOperation by DOT_NUMBER's PHY_STATE and returns 
PHY_STATE with SUM(MCS150_MILEAGE) aliased StateMileage. In the outer query, return only the states whose StateMileage is greater than the average StateMileage across all states, 
using a second subquery to supply that average. Sort by StateMileage descending. */
	-- The second subquery supplies a single average value that the outer query uses as a threshold to filter the summarized state mileage rows.
	SELECT
		PHY_STATE,
		StateMileage
	FROM
		(SELECT dc.PHY_STATE,
		SUM(fc.MCS150_MILEAGE) AS StateMileage
		FROM FactCarrierOperation fc
		JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE) AS StateMileageByState
	WHERE StateMileage > 
		(SELECT AVG(StateMileage)
		FROM
			(SELECT dc.PHY_STATE,
			SUM(fc.MCS150_MILEAGE) AS StateMileage
			FROM FactCarrierOperation fc
			JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
			GROUP BY dc.PHY_STATE) AS AllStateMileage)
	ORDER BY StateMileage DESC;

	--------------------------------------------------------
	-- Part D – Complex queries and common table expressions
	--------------------------------------------------------
/* Q19. A complex query with two derived tables. 
Following the chapter's “which vendor in each state” pattern, write a query that returns, for each state, the carrier with the largest total MCS150_MILEAGE. 
Build a Summary derived table (PHY_STATE, LEGAL_NAME, SUM(MCS150_MILEAGE) aliased SumMileage) and a TopInState derived table (PHY_STATE, MAX(SumMileage)) 
nested from a second copy of the summary, join them on PHY_STATE and the matching mileage, and sort by PHY_STATE. Outline the query in pseudocode first. */
	SELECT		-- DERIVED TABLE VERSION
		s.PHY_STATE,
		s.LEGAL_NAME,
		s.SumMileage
	FROM
		(SELECT 
			dc.PHY_STATE,
			dc.LEGAL_NAME,
		SUM(fc.MCS150_MILEAGE) AS SumMileage
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE, dc.LEGAL_NAME) AS s
			JOIN
		(SELECT PHY_STATE, 
		MAX(s2.SumMileage) AS SumMileage
		FROM
			(SELECT dc2.PHY_STATE, dc2.LEGAL_NAME,
			SUM(fc2.MCS150_MILEAGE) AS SumMileage
			FROM FactCarrierOperation fc2
			JOIN DimCarrier dc2 ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
			GROUP BY dc2.PHY_STATE, dc2.LEGAL_NAME) AS s2
	GROUP BY s2.PHY_STATE) AS TopInState
	ON s.PHY_STATE = TopInState.PHY_STATE AND s.SumMileage = TopInState.SumMileage
	ORDER BY s.PHY_STATE;

	WITH Summary AS	-- CTE VERSION
		(SELECT
			dc.PHY_STATE,
			dc.LEGAL_NAME,
			SUM(fc.MCS150_MILEAGE) AS SumMileage
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE, dc.LEGAL_NAME),TopInState AS
			(SELECT
			PHY_STATE,
			MAX(SumMileage) AS SumMileage
			FROM Summary
			GROUP BY PHY_STATE)
				SELECT
					s.PHY_STATE,
					s.LEGAL_NAME,
					s.SumMileage
				FROM Summary s
			JOIN TopInState t 
			ON s.PHY_STATE = t.PHY_STATE AND s.SumMileage = t.SumMileage
			ORDER BY s.PHY_STATE;

/* Q20. Your first CTE. Write a single common table expression named StateMileage that returns PHY_STATE and SUM(MCS150_MILEAGE) aliased SumMileage 
(FactCarrierOperation joined to DimCarrier, grouped by PHY_STATE). After the WITH clause, query the CTE to return the states whose SumMileage is greater 
than the average SumMileage across all states, sorted by SumMileage descending. In one sentence, explain how a CTE differs from a derived table coded directly in the FROM clause. */
	-- A CTE is defined with a WITH clause before the main query, whereas a derived table is written directly in the FROM clause.
	WITH StateMileage AS
		(SELECT dc.PHY_STATE,
		SUM(fc.MCS150_MILEAGE) AS SumMileage
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE)
		SELECT
			PHY_STATE,
			SumMileage
		FROM StateMileage
		WHERE SumMileage > 
		(SELECT AVG(SumMileage) 
		FROM StateMileage)
		ORDER BY SumMileage DESC;

/* Q21. Two CTEs that build on each other. Rewrite the complex Q19 query using two CTEs instead of nested derived tables: a Summary CTE (PHY_STATE, LEGAL_NAME, SumMileage) 
and a TopInState CTE that selects from Summary to return PHY_STATE with MAX(SumMileage). Join the two CTEs in the final SELECT to return the top carrier per state, sorted by PHY_STATE. 
In one sentence, explain why the two CTEs must be coded in this order and not the reverse. */
	-- TopInState must be coded after Summary because it uses the results returned by Summary.
	WITH Summary AS
		(SELECT
			dc.PHY_STATE,
			dc.LEGAL_NAME,
			SUM(fc.MCS150_MILEAGE) AS SumMileage
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE, dc.LEGAL_NAME),TopInState AS
			(SELECT
			PHY_STATE,
			MAX(SumMileage) AS SumMileage
			FROM Summary
			GROUP BY PHY_STATE)
				SELECT
					s.PHY_STATE,
					s.LEGAL_NAME,
					s.SumMileage
				FROM Summary s
			JOIN TopInState t 
			ON s.PHY_STATE = t.PHY_STATE AND s.SumMileage = t.SumMileage
			ORDER BY s.PHY_STATE;

/* Q22. A recursive CTE over the revoke chain. 
Using the self-referencing DimCarrier.PRIOR_REVOKE_DOT_NUMBER column, write a recursive CTE that walks the prior-revoke chain. 
Code an anchor member that returns carriers whose PRIOR_REVOKE_DOT_NUMBER IS NULL with a Level of 1, then a recursive member joined by UNION ALL 
that adds 1 to Level for each carrier that points at the previous level. Return DOT_NUMBER, LEGAL_NAME, and Level, sorted by Level then DOT_NUMBER. 
In one sentence, name the two required parts of a recursive CTE and the operator that must connect them. */
	-- A recursive CTE has an anchor member and a recursive member, connected by UNION ALL.
	WITH RevokeChain AS
		(SELECT	-- Anchor member
			DOT_NUMBER,
			LEGAL_NAME, 1 AS Level
		FROM DimCarrier dc
		WHERE dc.PRIOR_REVOKE_DOT_NUMBER IS NULL
		UNION ALL	
		SELECT	-- Recursive member
			dc.DOT_NUMBER,
			dc.LEGAL_NAME,
			rc.Level + 1 AS Level
		FROM DimCarrier dc
			JOIN RevokeChain rc ON dc.PRIOR_REVOKE_DOT_NUMBER = rc.DOT_NUMBER)
		SELECT
			DOT_NUMBER,
			LEGAL_NAME,
			Level
		FROM RevokeChain
		ORDER BY Level, DOT_NUMBER;

/* Q23. A recursive CTE that generates a series. 
Write a recursive CTE that generates the integers 1 through 12 (a Months column) with an anchor member of SELECT 1 and a recursive member that adds 1 until it reaches 12. 
Left join that series to a per-month count of FactCarrierOperation rows whose MONTH(REVIEW_DATE) equals the generated number, returning every month 1–12 even when no reviews occurred in it. 
In one sentence, explain how this shows a recursive CTE can build a result set that is not stored in any table. */
	-- This recursive CTE creates the month numbers 1 through 12 even though those values are not stored in any table.
	WITH Months AS
		(SELECT 1 AS Months	-- Anchor member
		UNION ALL
		SELECT Months + 1
		FROM Months
		WHERE Months < 12)
		SELECT m.Months, 
			COUNT(fc.REVIEW_DATE) AS ReviewCount
		FROM Months m
			LEFT JOIN FactCarrierOperation fc 
		ON MONTH(fc.REVIEW_DATE) = m.Months
		GROUP BY m.Months
		ORDER BY m.Months;

	---------------------------------------
	-- Part E – Investigation (open-ended)
	---------------------------------------
/* Q24. (Dictionary) Investigation – outliers, three ways. 
Identify the carriers whose RECORDABLE_CRASH_RATE is well above their peers, and answer the same question three different ways: 
	1. With a correlated subquery comparing each carrier to its own state's average. 
	2. With a derived table or CTE that pre-computes the state averages and joins back. 
	3. With the OVER clause from Session 3. 
Decide a reasonable “well above” threshold, justify it, use the data dictionary to confirm the safety codes, and write a few sentences on which of the 
three approaches you found clearest and which you would expect to run fastest – and on what the numbers do and do not prove. */
------------------------------------------------------------------------------------------------------------------------------------------------
	/* I defined “well above” as a carrier having a RECORDABLE_CRASH_RATE more than twice the average crash rate for carriers in the same state. 
This is a reasonable threshold because it compares each carrier to its own local peer group instead of comparing all carriers nationally. 
The data dictionary confirms the safety rating codes: 
		S -Satisfactory.
		C - Conditional.  
		U - Unsatisfactory.
Of the three approaches, the OVER clause version was clearest to me because it shows the state average beside each carrier row. */
-------------------------------------------------------------------------------------------------------------------------------------------------
	-- 1. CORRELATED SUBQUERY may calculate the state average again and again for many rows.
	-- This correlated subquery compares each carrier's crash rate to twice the average crash rate of carriers in the same state.
-------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		fc.RECORDABLE_CRASH_RATE
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
	WHERE fc.RECORDABLE_CRASH_RATE >
		(SELECT AVG(fc2.RECORDABLE_CRASH_RATE) * 2
		FROM FactCarrierOperation fc2
			JOIN DimCarrier dc2
        ON fc2.DOT_NUMBER = dc2.DOT_NUMBER
    WHERE dc2.PHY_STATE = dc.PHY_STATE)
	ORDER BY
    dc.PHY_STATE,
    fc.RECORDABLE_CRASH_RATE DESC;
	------------------------------------------------------------------------------------------------------------------------------------------------------
		-- 2. CTE calculates state averages first, then joins back.
	-- This CTE calculates the average crash rate for each state once and joins it back to carriers to find crash rates more than twice the state average.
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	WITH StateAvg AS
		(SELECT
        dc.PHY_STATE,
        AVG(fc.RECORDABLE_CRASH_RATE) AS AvgCrashRate
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc
        ON fc.DOT_NUMBER = dc.DOT_NUMBER
		GROUP BY dc.PHY_STATE)
	SELECT
		fc.DOT_NUMBER,
		dc.LEGAL_NAME,
		dc.PHY_STATE,
		fc.RECORDABLE_CRASH_RATE
	FROM FactCarrierOperation fc
		JOIN DimCarrier dc
    ON fc.DOT_NUMBER = dc.DOT_NUMBER
		JOIN StateAvg sa
    ON dc.PHY_STATE = sa.PHY_STATE
	WHERE fc.RECORDABLE_CRASH_RATE > sa.AvgCrashRate * 2
	ORDER BY dc.PHY_STATE, fc.RECORDABLE_CRASH_RATE DESC;
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- 3. OVER() calculates state average across partitions while keeping detail rows.
	-- This query uses a window function to calculate the average crash rate for each state without needing a separate CTE or derived table, and filters for rates more than twice the state average.
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		RECORDABLE_CRASH_RATE,
		StateAvgCrashRate
	FROM 
		(SELECT
			fc.DOT_NUMBER,
			dc.LEGAL_NAME,
			dc.PHY_STATE,
			fc.RECORDABLE_CRASH_RATE,
			AVG(fc.RECORDABLE_CRASH_RATE) OVER 
		   (PARTITION BY dc.PHY_STATE) AS StateAvgCrashRate
		FROM FactCarrierOperation fc
			JOIN DimCarrier dc ON fc.DOT_NUMBER = dc.DOT_NUMBER) AS CarrierCrashRates
		WHERE CarrierCrashRates.RECORDABLE_CRASH_RATE > StateAvgCrashRate * 2
		ORDER BY PHY_STATE, RECORDABLE_CRASH_RATE DESC;

/* Q25. Investigation – when a subquery earns its keep. 
The chapter says most subqueries can be restated as joins and a join usually runs faster, so a subquery is justified mainly 
when it cannot be restated as a join or when it makes the query clearer. Pick two of your earlier answers in this session, 
restate each as a join, and decide whether the join or the subquery version is better. 
Then describe one realistic question about this trucking data that genuinely requires a subquery for 
(example, passing an aggregate into a search condition, or a NOT EXISTS test, and could not be answered by joins alone). */
	--------------------------------------------------------------------------------------------------------------------------------------
	-- I prefer the LEFT JOIN version because it clearly shows carriers from DimCarrier that have no matching row in FactCarrierOperation.
	--------------------------------------------------------------------------------------------------------------------------------------
	SELECT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME
	FROM DimCarrier dc
		LEFT JOIN FactCarrierOperation fc
    ON dc.DOT_NUMBER = fc.DOT_NUMBER
	WHERE fc.DOT_NUMBER IS NULL
	ORDER BY dc.DOT_NUMBER;
	---------------------------------------------------------------------------------------------------------------------------
	-- I prefer the INNER JOIN version here because it is simple to read and directly shows the matching rows between the two tables.
	---------------------------------------------------------------------------------------------------------------------------
	SELECT DISTINCT
		dc.DOT_NUMBER,
		dc.LEGAL_NAME
	FROM DimCarrier dc
		JOIN FactCarrierOperation fc
    ON dc.DOT_NUMBER = fc.DOT_NUMBER
	ORDER BY dc.DOT_NUMBER;

	-- A realistic question that needs a subquery is:
	-- Which carriers have a RECORDABLE_CRASH_RATE greater than the overall average RECORDABLE_CRASH_RATE?
	-- This needs a subquery because the AVG() value must be calculated first and then used as a search condition in the WHERE clause.