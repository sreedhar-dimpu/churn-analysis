/* telecom churn analysis */

----checking for duplicates-----
select [customer id],count(*) as occurrences
from [dbo].[telecom_customer_churn]
group by [customer id]
having count(*)>1;

select count(distinct([customer id]))
from [dbo].[telecom_customer_churn]




/* how many customers joined the company during the last quater?*/
WITH LastQuater AS (
    SELECT DATEADD(MONTH, -3, GETDATE()) AS STARTOFLASTQUARTER
)
SELECT COUNT(*) AS CUSTOMER_JOINED_LAST_QUATER
--JOINED DATE--
FROM [dbo].[telecom_customer_churn]
WHERE DATEADD(MONTH, -[Tenure in Months], GETDATE()) >= 
    (SELECT STARTOFLASTQUARTER FROM LastQuater);








----WHAT ARE THE KEY DRIVERS FOR CHURN----
SELECT [Churn Category],[Churn Reason], COUNT(*) AS CUSTOMERS
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'CHURNED'
GROUP BY [Churn Category],[Churn Reason]
ORDER BY COUNT(*) DESC;



-----WHAT CONTRACT ARE CHURNERS ON ----

SELECT [CONTRACT],COUNT(*) AS CUSTOMERS,(COUNT(*)*100/(SUM(COUNT(*)) OVER())) AS PER
FROM[dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'CHURNED'
GROUP BY [CONTRACT]
ORDER BY COUNT(*) DESC

/*(COUNT() * 100 / (SUM(COUNT()) OVER())): This formula calculates the percentage of customers in a specific
contract type compared to the total number of churned customers. 
Multiplying by 100 converts the ratio to a percentage.*/
       
---DO CHURNERS HAVE ACCESS TO PREMIUM TECH SUPPORT---
SELECT	[Premium Tech Support],COUNT(*) AS CUSTOMERS
,ROUND((COUNT(*)*100.0/SUM(COUNT(*)) OVER ()),1) AS PER
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] ='CHURNED'
GROUP BY [Premium Tech Support]
ORDER BY COUNT(*) DESC
 

 SELECT [Internet Type]	,COUNT(*) AS CUSTOMERS
,ROUND((COUNT(*)*100.0/SUM(COUNT(*)) OVER ()),1) AS PER
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] ='CHURNED'
GROUP BY [Internet Type]
ORDER BY COUNT(*) DESC



SELECT [Offer]	,COUNT(*) AS CUSTOMERS
,ROUND((COUNT(*)*100.0/SUM(COUNT(*)) OVER ()),1) AS PER
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] ='CHURNED'
GROUP BY [Offer]
ORDER BY COUNT(*) DESC





----HIGH VALUE CUSTOMERS AT RISK OF CHURNING?----
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Monthly Charge]) 
       OVER () AS MedianMonthlyCharge
FROM [dbo].[telecom_customer_churn];



---OFFER 1
---PREMIUM TECH SUPPORT 1
----CONTRACT 1
----INTERNET TYPE 1


SELECT [Customer ID],
[Offer],
[Premium Tech Support],
[Contract],
[Internet Type],

CASE
WHEN (
CASE WHEN [Offer]='NONE' THEN 1 ELSE 0 END +
CASE WHEN [Premium Tech Support] ='NO' THEN 1 ELSE 0 END +
CASE WHEN [Contract] ='MONTH-TO-MONTH' THEN 1 ELSE 0 END +
CASE WHEN [Internet Type]='FIBER OPTIC' THEN 1 ELSE 0 END)
>=3 THEN 'HIGH RISK'

WHEN (
CASE WHEN [Offer]='NONE' THEN 1 ELSE 0 END +
CASE WHEN [Premium Tech Support] ='NO' THEN 1 ELSE 0 END +
CASE WHEN [Contract] ='MONTH-TO-MONTH' THEN 1 ELSE 0 END +
CASE WHEN [Internet Type]='FIBER OPTIC' THEN 1 ELSE 0 END)
=2 THEN 'HIGH RISK'
ELSE 'LOW RISK'
END AS "RISK LEVEL"
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] !='CHURNED'


----REFERALS >0--
---MONTHLY CHARGES >MEADIAN---
----TENTURE IN MONTHS > 9 MONTHS---
----HIGH VALUE CUSTOMERS AT RISK OF CHURNING?---

WITH MEDIANMONTHLY AS
(
    SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY [Monthly Charge]) 
    OVER () AS MedianMonthlyCharge
    FROM [dbo].[telecom_customer_churn]
)
SELECT [CUSTOMER ID],
       CASE 
            WHEN [Number of Referrals] > 0
            AND [Monthly Charge] >= (SELECT MAX(MedianMonthlyCharge) FROM MEDIANMONTHLY)
            AND [Tenure in Months] > 9
            THEN 'HIGH VALUE'
            WHEN [Tenure in Months] > 9
            THEN 'MEDIUM VALUE'
            ELSE 'LOW VALUE'
       END AS "CUSTOMER VALUE"
FROM [dbo].[telecom_customer_churn];


