/*
ROW_NUMBER() is a special function used with Window functions to index rows in a window
It must have a ORDER BY since SQL must know  how to sort rows in each window
*/
SELECT
    ps.PatientId
    , ps.Hospital
    , ps.Ward
    , ps.AdmittedDate
    , ps.Tariff
    , ROW_NUMBER() OVER (ORDER BY ps.PatientId desc) AS PatientIndex
    , ROW_NUMBER() OVER (PARTITION BY ps.Hospital ORDER BY ps.PatientId) AS PatientByHospitalIndex
    ,COUNT(*) OVER (PARTITION BY ps.Hospital order by ps.PatientId)  as PatientByHospitalIndexAlt -- An alternative way of indexing
FROM
    PatientStay ps
having (ROW_NUMBER() OVER (PARTITION BY ps.Hospital ORDER BY ps.PatientId) in ('1','2','3'))
ORDER BY
    ps.Hospital
    ,ps.PatientId;
 
/*
Compare ROW_NUMBER(), RANK() and DENSE_RANK() where there are ties
ROW_NUMBER() will always create a monotonically  increasing sequence 1,2,3,... and arbitrarily choose one tie row over another
RANK() will give all tie rows the same value and the rank of the next row will n higher if there are n tie rows e.g. 1,1,3,...
DENSE_RANK() will give all tie rows the same value and the rank of the next row will one higher e.g. 1,1,2,...
NTILE(10) splits into deciles
*/
 
SELECT
    ps.PatientId
    , ps.Tariff
    , ROW_NUMBER() OVER (ORDER BY ps.Tariff DESC) AS PatientRowIndex
    , RANK() OVER ( ORDER BY ps.Tariff DESC) AS PatientRank
    , DENSE_RANK() OVER (ORDER BY ps.Tariff DESC) AS PatientDenseRank
    , NTILE(10) OVER (ORDER BY ps.Tariff DESC) AS PatientIdDecile
FROM
    PatientStay ps
ORDER BY
    ps.Tariff DESC;


    SELECT
    ps.PatientId
    , ps.Hospital
    , DENSE_RANK() OVER ( ORDER BY ps.Hospital) AS PatientRank
    ,(cast(DENSE_RANK() OVER ( ORDER BY ps.Hospital) as varchar)+'.'+cast(DENSE_RANK() OVER ( ORDER BY ps.patientid) as varchar)) AS PatientRank2
FROM
    PatientStay ps
ORDER BY
    4;
 
-- Use Window functions to calculate a cumulative value , or running total
SELECT
    ps.AdmittedDate
    , ps.Tariff
     , ROW_NUMBER() OVER (ORDER BY ps.AdmittedDate) AS RowIndex
     , SUM(ps.Tariff) OVER (ORDER BY ps.AdmittedDate) AS RunningTariff
     , ROW_NUMBER() OVER (PARTITION BY DATENAME(MONTH, ps.AdmittedDate) ORDER BY ps.AdmittedDate) AS MonthIndex
     , (select datename(year,sub.AdmittedDate) + left(datename(month,sub.AdmittedDate),3) from PatientStay Sub where sub.PatientId = ps.PatientId)
     ,(select datename(year,sub.AdmittedDate) from PatientStay Sub where sub.PatientId = ps.PatientId)
     --, SUM(ps.Tariff) OVER (PARTITION BY DATENAME(MONTH, ps.AdmittedDate) ORDER BY ps.AdmittedDate) AS MonthToDateTariff
FROM
    PatientStay ps
WHERE
    ps.Hospital = 'Oxleas'
    AND ps.Ward = 'Dermatology'
ORDER BY
    ps.AdmittedDate;