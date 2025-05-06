SELECT
    ps.PatientId
    ,ps.AdmittedDate
    ,ps.Hospital
    , ps.Tariff
    , (SELECT sum(Tariff) FROM PatientStay) as CumulativeTariff    
FROM
    PatientStay ps
ORDER BY ps.PatientId



(SELECT sum(ps.Tariff) FROM PatientStay)




SELECT 
    ps.PatientId
    ,ps.AdmittedDate
    ,ps.Hospital
    , ps.Tariff
    ,sum(ps.Tariff)  OVER (ORDER BY ps.PatientId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS CumulativeTotal
FROM 
    PatientStay ps
--having sum(ps.Tariff) >= 100
ORDER BY 
    ps.PatientId;


SELECT 
    ps.patientId
    ,ps.Tariff
    ,(SELECT SUM(Tariff) 
     FROM PatientStay AS ps2
     WHERE ps2.patientID <= ps.patientId) AS CumulativeTotal
FROM 
    PatientStay AS ps
ORDER BY 
    ps.patientId;




    SELECT
    ps.PatientId
    ,ps.AdmittedDate
    ,ps.Hospital
    , ps.Tariff
    , (SELECT sum(sub.Tariff) FROM PatientStay sub where ps.patientID >= sub.PatientId ) as CumulativeTariff
    ,(SELECT count(sub2.Tariff) FROM PatientStay sub2 where ps.patientID >= sub2.PatientId ) as PatientIndex     
FROM
    PatientStay ps
ORDER BY ps.PatientId


    SELECT
    ps.PatientId
    ,ps.AdmittedDate
    ,ps.Hospital
    , ps.Tariff
    , (SELECT sum(sub.Tariff) FROM PatientStay sub where ps.patientID >= sub.PatientId and ps.Hospital = sub.Hospital) as CumulativeTariff
    ,(SELECT count(*) FROM PatientStay sub2 where ps.patientID >= sub2.PatientId and ps.Hospital = sub2.Hospital) as PatientIndex     
FROM
    PatientStay ps
ORDER BY ps.hospital,ps.PatientId