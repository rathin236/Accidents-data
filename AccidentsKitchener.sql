USE CollisionPortfolio;
--Showing the most dangerous intersaction to drive. It shows that there are 0.98% chances that you will be involved in a collision if you pass through BLOCK LINE RD @ STRASBURG RD

Declare @TotalAcc as float;
SET @TotalAcc=(SELECT COUNT(*) FROM Traffic_Collisions$);
SELECT LOCATION,COUNT(*) AS AccidentCount, Round(((Cast(count(*) as float)/@TotalAcc)*100),2) as AccidentPercent FROM Traffic_Collisions$
GROUP BY LOCATION
ORDER BY AccidentCount DESC;

--Locations where collisions occured in daylight and clear weather

Select LOCATION, COUNT(*) as Count from Traffic_Collisions$
where LIGHT like '%daylight' and ENVIRONMENT_CONDITION like '%clear'
group by LOCATION
order by Count desc;

--The darkest date when most of the accidents happened, but the datatype of date was float so i had to convert it to a string 
--and created a temporary table with this dates

SELECT TOP 3 
SUBSTRING(Cast(cast(ACCIDENTDATE as bigint) as varchar),7,2) AS Day, SUBSTRING(Cast(cast(ACCIDENTDATE as bigint) as varchar),6,2) AS Month,SUBSTRING(Cast(cast(ACCIDENTDATE as bigint) as varchar),1,4) AS Year,COUNT(*) as Count into DarkDate from Traffic_Collisions$
Group by ACCIDENTDATE
order by count desc;
SELECT * FROM DarkDate;
DROP TABLE DarkDate;

--I wanted to see where there is need of changes (like signs or speedbrakers) at intersaction, but someone told me to do it without using the word 'intersaction'

DROP TABLE IF EXISTS NeedofChange;
SELECT * INTO NeedofChange FROM 
(SELECT LOCATION,PARSENAME(REPLACE(accident_location,'-','.'),2) as AccLocCode,PARSENAME(REPLACE(accident_location,'-','.'),1) as AccDesc, COUNT(*) as AccCount FROM Traffic_Collisions$
GROUP BY ACCIDENT_LOCATION,LOCATION) AS New
WHERE AccCount>=20
ORDER BY LOCATION,AccLocCode ASC;

SELECT * FROM NeedofChange WHERE AccLocCode=3
ORDER BY AccCount DESC;

--Since its rainy season and winter is about to come, showing where do we need to be more cautious during snowfall and rainfall using union for two tables

SELECT LOCATION,CONCAT('Place to be cautious during ',SUBSTRING(ENVIRONMENT_CONDITION,4,LEN(ENVIRONMENT_CONDITION)-3)) AS Description  FROM 
(Select TOP 1 LOCATION,ENVIRONMENT_CONDITION,COUNT(*) as Count from Traffic_Collisions$ 
where ENVIRONMENT_CONDITION like '%snow%'
group by LOCATION,ENVIRONMENT_CONDITION
order by Count DESC) AS A

Union (

SELECT LOCATION,CONCAT('Place to be cautious during ',SUBSTRING(ENVIRONMENT_CONDITION,4,LEN(ENVIRONMENT_CONDITION)-3)) AS Description FROM 
(Select TOP 1 LOCATION,ENVIRONMENT_CONDITION,COUNT(*) as Count from Traffic_Collisions$
where ENVIRONMENT_CONDITION like '%rain%'
group by LOCATION,ENVIRONMENT_CONDITION
order by Count DESC) AS B);





