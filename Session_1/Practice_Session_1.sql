
				
				----------------------------
				/* SQL Practice Session 1 */
				----------------------------

/* Q1. Write a SELECT statement that returns every column and every row from the company_census table. 
Do not use an ORDER BY clause. Why is using SELECT * generally discouraged in production code? */
	SELECT * 
	FROM [usaTrucking].[company].[company_census]; -- Using the full path is better even usaTrucking DB not in use.

/* Q2. Write a SELECT statement that returns three columns for every carrier: LEGAL_NAME, DBA_NAME, and DOT_NUMBER. 
Do not rename the columns and do not filter or sort the rows. */
	SELECT 
		LEGAL_NAME, 
		DBA_NAME, 
		DOT_NUMBER
	FROM [usaTrucking].[company].[company_census];

/*  Q3. Write a SELECT statement that returns the following four columns from the company_census table, using the AS keyword to assign each alias exactly as shown:
		•DOT Number ← alias for DOT_NUMBER
		•Legal Name ← alias for LEGAL_NAME
		•Total Drivers ← alias for TOTAL_DRIVERS
		•Total Power Units ← alias for POWER_UNITS  */
	SELECT 
		DOT_NUMBER AS [Dot Number],
		LEGAL_NAME AS [Legal Name],
		TOTAL_DRIVERS AS [Total Drivers],
		POWER_UNITS AS [Total Power Units]
	FROM [usaTrucking].[company].[company_census];

/* Q4. Write a SELECT statement that returns one column named Full Address. 
Build this column by concatenating PHY_STREET, PHY_CITY, PHY_STATE, and PHY_ZIP with 
appropriate commas and spaces so that the result looks like: “123 Main St, Dallas, TX 75201”. */
	SELECT 
		PHY_STREET +', '+ 
		PHY_CITY +', '+ 
		PHY_STATE +', '+ 
		PHY_ZIP AS [Full Address]
	FROM [usaTrucking].[company].[company_census];


/* Q5. (Dictionary) Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and a calculated column named Total Fleet that is the sum of TRUCK_UNITS, POWER_UNITS, and BUS_UNITS. Use the data dictionary 
to confirm what each of these three unit columns represents before writing the query, and briefly note in a comment which one counts buses. */
	SELECT 
		DOT_NUMBER, 
		LEGAL_NAME,
		TRUCK_UNITS + POWER_UNITS + BUS_UNITS AS [Total Fleet]
	FROM [usaTrucking].[company].[company_census];

/* Q6. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, the company’s officer initials (the first letter of COMPANY_OFFICER_1 followed by no space and then the entire COMPANY_OFFICER_1
column itself), and a column named Report Date that contains today’s date. Use the LEFT function for the initial and the GETDATE function for the date. */
	SELECT 
		DOT_NUMBER, LEGAL_NAME,
		LEFT(COMPANY_OFFICER_1, 1) + COMPANY_OFFICER_1 AS [Officer Initials],
		GETDATE() AS [Report Date]
	FROM [usaTrucking].[company].[company_census];

/* Q7. Write a SELECT statement that returns the distinct list of PHY_STATE values that appear in the company_census table. 
Do not include an ORDER BY clause and explain in one sentence why the rows still come back in alphabetical order. */
	SELECT PHY_STATE								--------------------------------------------------------------------------
	FROM [usaTrucking].[company].[company_census];	/* Even result looks alphabetical but isn't guaranteed without ORDER BY */
													--------------------------------------------------------------------------
/* Q8. Write a SELECT statement that returns the ten carriers with the largest fleets, where fleet size is defined as TOTAL_DRIVERS. 
Show DOT_NUMBER, LEGAL_NAME, and TOTAL_DRIVERS, sorted so that the largest fleet appears first. */
	SELECT TOP 10 
		LEGAL_NAME, 
		DOT_NUMBER, 
		TOTAL_DRIVERS
	FROM [usaTrucking].[company].[company_census]
	ORDER BY TOTAL_DRIVERS DESC;

/* Q9. Write a SELECT statement that returns the top 1 percent of carriers by MCS150_MILEAGE indescending order. 
Include DOT_NUMBER, LEGAL_NAME, and MCS150_MILEAGE. 
Then modify the queryso it also returns any additional carriers that tie with the last row’s mileage value. */
	SELECT TOP 1 PERCENT 
		DOT_NUMBER, 
		LEGAL_NAME, 
		MCS150_MILEAGE
	FROM [usaTrucking].[company].[company_census]
	ORDER BY MCS150_MILEAGE DESC;

/* Q10. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and PHY_STATE for all California carriers, sorted alphabetically by LEGAL_NAME. Skip the first 20 rows and return only the next 10 rows.
Use OFFSET and FETCH. */
	SELECT 
		DOT_NUMBER, 
		LEGAL_NAME, 
		PHY_STATE
	FROM [usaTrucking].[company].[company_census]
	WHERE PHY_STATE = 'CA'
	ORDER BY LEGAL_NAME
	OFFSET 20 ROWS
	FETCH NEXT 10 ROWS ONLY

/* Q11. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and PHY_STATE for everycarrier physically located in Texas. Then explain in one sentence why the query would also match rows
where PHY_STATE = 'tx' or PHY_STATE = 'Tx'. */
	SELECT											
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE
	FROM [usaTrucking].[company].[company_census]  ------------------------------------------------------------------------------------
	WHERE PHY_STATE = 'Tx';							/* SQL Server case insensetive by default so TX, Tx, tx will display same result */
	                                               ------------------------------------------------------------------------------------

/* Q12. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and STATUS_CODE for everycarrier whose status code indicates the carrier is currently active. Use the data dictionary to determine
which single-character value of STATUS_CODE represents an active carrier. */
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		STATUS_CODE
	FROM [usaTrucking].[company].[company_census]
	WHERE STATUS_CODE = 'A';

/* Q13. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, TOTAL_DRIVERS, and POWER_UNITS for every carrier that has more than 50 drivers AND more than 25 power units. Sort the
result by TOTAL_DRIVERS in descending order. */
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		TOTAL_DRIVERS,
		POWER_UNITS
	FROM [usaTrucking].[company].[company_census]
	WHERE TOTAL_DRIVERS > 50 AND POWER_UNITS >25;

/* Q14. Rewrite the following WHERE clause to remove the NOT operator while keeping the result set identical. Explain briefly why the rewritten version is easier to read:
WHERE NOT (TOTAL_DRIVERS < 10 OR NOT PHY_STATE = 'CA') */
	SELECT 
		LEGAL_NAME,
		TOTAL_DRIVERS,
		PHY_STATE
	FROM [usaTrucking].[company].[company_census]
	WHERE TOTAL_DRIVERS >10 AND PHY_STATE = 'CA';

/* Q15. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and PHY_STATE for carriersphysically located in California, Nevada, Arizona, or Oregon. */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE
	FROM [usaTrucking].[company].[company_census]
	WHERE PHY_STATE IN ('CA','NV','AZ','OR');

/* Q16. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and PHY_STATE for carriers physically located in every U.S. state EXCEPT California, Nevada, Arizona, or Oregon. */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE		
	FROM [usaTrucking].[company].[company_census]
	WHERE PHY_STATE NOT IN ('CA','NV','AZ','OR')

/* Q17. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and TOTAL_DRIVERS for carriers whose total driver count is between 100 and 500, inclusive. 
Use the BETWEEN operator and sortthe result by TOTAL_DRIVERS ascending. */
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		TOTAL_DRIVERS
	FROM [usaTrucking].[company].[company_census]
	WHERE TOTAL_DRIVERS BETWEEN 100 AND 500
	ORDER BY TOTAL_DRIVERS;

/* Q18. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and MCS150_DATE for carriers whose most recent MCS-150 update fell in the first quarter of 2025 (January 1, 2025 through March 31,
2025, inclusive). Use the data dictionary to confirm which column stores the most recent MCS-150 update date, and use BETWEEN with date literals. In a comment, note the warning from the textbook 
about comparing dates that include a time portion. */
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		MCS150_DATE
	FROM [usaTrucking].[company].[company_census]
	WHERE MCS150_DATE BETWEEN '2025-01-01' AND '2025-03-31';
/* Q19. Write three SELECT statements, each returning DOT_NUMBER and LEGAL_NAME, that demonstrate three different uses of the LIKE operator:
	-----------------------------------------------------------------------
	• (A) All carriers whose LEGAL_NAME starts with the letters “TRANS”. */
	-----------------------------------------------------------------------
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME
	FROM [usaTrucking].[company].[company_census]
	WHERE LEGAL_NAME LIKE 'TRANS%';
	-----------------------------------------------------------------------------------
	/* (B) All carriers whose LEGAL_NAME contains the word “EXPRESS” anywhere in it. */
	-----------------------------------------------------------------------------------
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME
	FROM [usaTrucking].[company].[company_census]
	WHERE LEGAL_NAME LIKE '%EXPRESS%';
	---------------------------------------------------------------------------------------------------------------------
	/* (C) All carriers whose PHY_ZIP starts with any digit from 7 through 9, followed by exactly four more characters.*/
	---------------------------------------------------------------------------------------------------------------------
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_ZIP
	FROM [usaTrucking].[company].[company_census]
	WHERE PHY_ZIP LIKE '[7-9]____';
	
/* Q20. Some carriers have not yet received a safety rating. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and SAFETY_RATING for every carrier whose SAFETY_RATING is missing. 
Then write a second SELECT statement that returns the same columns but only for carriers whose SAFETY_RATING is NOT missing. Consult the data dictionary to confirm what values SAFETY_RATING 
can take, and explain in one sentence why you cannot use “WHERE SAFETY_RATING = NULL”. */
	SELECT 
		DOT_NUMBER,
		LEGAL_NAME,
		SAFETY_RATING
	FROM [usaTrucking].[company].[company_census]
	WHERE SAFETY_RATING IS NULL;
		
			SELECT
				DOT_NUMBER,
				LEGAL_NAME,
				SAFETY_RATING
			FROM [usaTrucking].[company].[company_census]
			WHERE SAFETY_RATING IS NOT NULL;

/* Q21. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, PHY_STATE, and PHY_CITY for every carrier, sorted 1st by PHY_STATE ascending, then by PHY_CITY ascending, then by LEGAL_NAME descending. */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		PHY_CITY
	FROM [usaTrucking].[company].[company_census]
	ORDER BY PHY_STATE, PHY_CITY ASC, LEGAL_NAME DESC; 
/* Q22. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, and a calculated column named Full Address (built the same way as in question 4). 
Sort the result set by the Full Address alias, then by LEGAL_NAME. */
	SELECT	
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STREET +', '+ 
		PHY_CITY +', '+
		PHY_STATE +' '+ 
		PHY_ZIP AS [Full Address]
	FROM [usaTrucking].[company].[company_census];

/*  Q23. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, TOTAL_DRIVERS, and POWER_UNITS for every carrier, and sort the result set so that carriers with the highest driver-to-power-unit 
ratio appear first. Be careful with carriers whose POWER_UNITS column is zero or NULL — exclude those rows in the WHERE clause so the sort expression cannot fail. */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		TOTAL_DRIVERS,
		POWER_UNITS
	FROM [usaTrucking].[company].[company_census]
	WHERE POWER_UNITS > 0 AND POWER_UNITS IS NOT NULL
	ORDER BY TOTAL_DRIVERS / POWER_UNITS DESC; /* This will work but may perform integer division if both columns are integers, which could lead to incorrect sorting */

/* Q24. Write a SELECT statement that returns the following columns for the 25 carriers based in Illinois with the most total drivers:
	• DOT_NUMBER
	• A column named Carrier Name that uses LEGAL_NAME, or, when LEGAL_NAME is NULL, falls back to DBA_NAME (look up both columns in the data dictionary to confirm what they represent — for this exercise, 
	  simply use LEGAL_NAME and do not handle NULL fallback yet; note in a comment that you would normally handle this case in a later chapter).
	• A column named City State Zip that concatenates PHY_CITY, PHY_STATE, and PHY_ZIP, formatted like “Chicago, IL 60601”.
	• TOTAL_DRIVERS
	• A column named Years Since MCS150 Update that uses DATEDIFF and GETDATE to compute the integer number of years between MCS150_DATE and today. */
	SELECT TOP 25
		DOT_NUMBER,
		LEGAL_NAME AS [Carrier Name],
		PHY_CITY + ', ' + PHY_STATE + ' ' + PHY_ZIP AS [City State Zip],
		TOTAL_DRIVERS,
		DATEDIFF(YEAR, MCS150_DATE, GETDATE()) AS [Years Since MCS150 Update]
	FROM [usaTrucking].[company].[company_census]
	WHERE PHY_STATE = 'IL'
	ORDER BY TOTAL_DRIVERS DESC;

/* Q25. Write a SELECT statement that returns DOT_NUMBER, LEGAL_NAME, PHY_STATE, and CARRIER_OPERATION for active interstate carriers (consult the data dictionary to determine which value of 
CARRIER_OPERATION represents interstate operations and which value of STATUS_CODE represents an active carrier) that are physically located in any of the following states: TX, CA, FL, NY, IL — AND 
whose LEGAL_NAME does NOT begin with the letter “A”, “B”, or “C”. Sort by PHY_STATE ascending and then LEGAL_NAME ascending, then use OFFSET/FETCH to skip the first 50 rows and return the next 25. */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		CARRIER_OPERATION
	FROM [usaTrucking].[company].[company_census]
	WHERE STATUS_CODE = 'A'
	AND CARRIER_OPERATION = 'A'
	AND PHY_STATE IN ('TX', 'CA', 'FL', 'NY', 'IL')
	AND LEGAL_NAME NOT LIKE '[A-C]%'
	ORDER BY PHY_STATE ASC, LEGAL_NAME ASC
	OFFSET 50 ROWS
	FETCH NEXT 25 ROWS ONLY;

/* Q26. Is DOT number just randomly generated number or ever-increasing number as time passes? 

   A-26. DOT numbers are not random. They're issuing sequentially, meaning that newer companies will have higher DOT numbers than older companies. 
   This is because the DOT number is assigned when a company registers with the DOT and they are issued in the order that companies register. 

   DICTIONARY PROOF: Numbers are issued sequentially as entities are added to the system. */
	SELECT TOP 50 DOT_NUMBER
	FROM [usaTrucking].[company].[company_census]
	ORDER BY DOT_NUMBER DESC; /* This will show the most recently issued DOT numbers at the top, confirming that they are sequential and not random. */

/* Q27. How many MC Numbers were registered in January, in February, in March and in April of 2026? Do not use count function or some crazy solution AI offers. Use some logic. */
	SELECT
		DOCKET1PREFIX, 
		DOCKET1, 
		ADD_DATE
	FROM [usaTrucking].[company].[company_census]
	WHERE DOCKET1PREFIX = 'MC'
	AND ADD_DATE BETWEEN '2026-01-01' AND '2026-05-01';

/* Q28. In which county are there more active hazmat carriers: in Cook County or in Dupage County? How many in each county and what is the difference? */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		PHY_CNTY,
		HM_Ind,
		STATUS_CODE
	FROM [usaTrucking].[company].[company_census]
	WHERE  STATUS_CODE = 'A' AND HM_Ind = 'Y' AND PHY_STATE = 'IL' AND PHY_CNTY = 31; --Cook County 1643--

		SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		PHY_STATE,
		PHY_CNTY,
		HM_Ind,
		STATUS_CODE
	FROM [usaTrucking].[company].[company_census]
	WHERE  STATUS_CODE = 'A' AND HM_Ind = 'Y' AND PHY_STATE = 'IL' AND PHY_CNTY = 43; --Dupage County 453--

/* Q29. There might be some fraudulent truck companies, and you must investigate some of those companies. From where will you start? Support your argument with SQL code. */

/* I would investigate active carriers that are missing important operational and safety information, such as driver counts, phone numbers, and safety ratings. 
Multiple missing fields in an active carrier record may indicate incomplete registration data or possible compliance issues that require further review. */
	SELECT
		DOT_NUMBER,
		LEGAL_NAME,
		TOTAL_DRIVERS,
		POWER_UNITS,
		PHONE,
		SAFETY_RATING,
		STATUS_CODE
	FROM [usaTrucking].[company].[company_census]
	WHERE STATUS_CODE = 'A' AND TOTAL_DRIVERS IS NULL AND SAFETY_RATING IS NULL AND PHONE IS NULL;

/* Q30. Can you find uzbek owned truck companies? How do you approach? */
	--APPROACH: 
/* I would look for company officers with surnames that are commonly associated. 
However, this query doesn't prove Uzbek nationality or ownership. 
It only helps identify possible Uzbek-related trucking companies for further manual review based on 
common surname naming patterns.*/
	SELECT
    DOT_NUMBER,
    LEGAL_NAME,
    COMPANY_OFFICER_1,
    PHY_CITY,
    PHY_STATE
FROM [usaTrucking].[company].[company_census]

WHERE COMPANY_OFFICER_1 LIKE '%OV' OR COMPANY_OFFICER_1 LIKE '%OVA'
OR COMPANY_OFFICER_1 LIKE '%EV' OR COMPANY_OFFICER_1 LIKE '%EVA'
ORDER BY COMPANY_OFFICER_1;