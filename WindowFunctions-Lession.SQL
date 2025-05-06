/*
Explaining Window Functions
 
Window functions are very useful for analysis.  Examples include rolling totals, moving averages and ranking per category.
A window function is a computation that returns a single value applied to a set of rows defined by a window specification.
Each column can independently calculate a window function.
Each row has its own window
 
Syntax: window_function(...) OVER (window specification)
 
We use a small table, PatientStay,  in these examples.
*/
 
SELECT
	ps.PatientId
	, ps.AdmittedDate
	, ps.Hospital
	, ps.Ward
	, ps.Ethnicity
	, ps.Tariff
FROM
	dbo.PatientStay ps;
 
/*
* Write a SQL query to show the number of patients admitted each day
The resultset should have two columns:
* AdmittedDate
*NumberOfPatients
It should be sorted by AdmittedDate (earliest first)
*/
 
 
/*
We will use the DATENAME function later so let's have a look at it now.
How many patients were admittted each month?
*/
 
SELECT
	DATENAME(MONTH, ps.AdmittedDate) AS AdmittedMonth
	, COUNT(*) AS [Number Of Patients]
FROM
	dbo.PatientStay ps
GROUP BY
	DATENAME(MONTH, ps.AdmittedDate);
 
/*
The most basic - and useless - example of a Window function
Note that there is an aggregation, COUNT(*), but no GROUP BY
COUNT(*) counts over a window defined by OVER() - the whole of the table since we have not yet partioned it
*/
 
SELECT
	ps.PatientId
	, ps.Hospital
	, ps.Ward
	, ps.AdmittedDate
	, ps.Tariff
	, COUNT(*) OVER () AS TotalCount
    , (select count(sub.tariff) from PatientStay sub where ps.patientid >= sub.PatientId) as CumulativeCount
    ,(COUNT(*) OVER ()/(select count(sub.tariff) from PatientStay sub where ps.patientid >= sub.PatientId))as TranslatedCount
    ,Sum(ps.Tariff) OVER () AS TotalSum
    , (select sum(sub.tariff) from PatientStay sub where ps.patientid >= sub.PatientId) as CumulativeTariff
    ,(Sum(ps.Tariff) OVER ()/(select sum(sub.tariff) from PatientStay sub where ps.patientid >= sub.PatientId)) as TranslatedSum
	-- create a window over the whole table
FROM
	PatientStay ps
ORDER BY
	ps.PatientId;
 
/*
PARTITION divides one large window into several smaller windows
For each row, we create a window based on the rows with the same value of the PARTITION BY column(s) and aggregate over that window
 
We can PARTITION BY more than one column
*/
SELECT
	ps.PatientId
	, ps.Hospital
	, ps.Ward
	, ps.AdmittedDate
	, ps.Tariff
	, COUNT(*) OVER () AS TotalCount
--	, COUNT(*) OVER (PARTITION BY ps.Hospital) AS HospitalCount -- create a window over those rows with the same hospital as the current row
--	, COUNT(*) OVER (PARTITION BY ps.Ward) AS WardCount
--	, COUNT(*) OVER (PARTITION BY ps.Hospital , ps.Ward) AS HospitalWardCount
FROM
	PatientStay ps
ORDER BY
	ps.PatientId;







/*
Use case: percentage of all rows in result set and percentage of a group 
*/
 
SELECT
	ps.PatientId
	, ps.Tariff
	, ps.Ward
	, SUM(ps.Tariff) OVER () AS TotalTariff
	, SUM(ps.Tariff) OVER (PARTITION BY ps.Ward) AS WardTariff
	, 100.0 * ps.Tariff / SUM(ps.Tariff) OVER () AS PctOfAllTariff
	, 100.0 * ps.Tariff / SUM(ps.Tariff) OVER (PARTITION BY ps.Ward) AS PctOfWardTariff
FROM
	PatientStay ps
ORDER BY
	ps.Ward
	, ps.PatientId;