/* 1.Total Credit Amount*/
USE bankmodels;
    select round(sum(Amount),2) AS Total_Credit
    from debitcredit
    where `Transaction Type` = 'credit';
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 2.Total debit amount*/
    select round(sum(Amount),2) AS Total_Debit
    from debitcredit
    where `Transaction Type` = 'debit';
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 3.Credit to debit ratio*/
 
select concat(round(CreditTotal / DebitTotal,4), ':1') AS `credit to debit ratio`
from(
SELECT
sum(CASE WHEN `Transaction Type` = 'Credit' THEN Amount else 0 end) AS CreditTotal,
sum(CASE WHEN `Transaction Type` = 'Debit' THEN Amount else 0 end) AS DebitTotal
from debitcredit
)
AS Sub;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 4.Net transaction amount */
SELECT 
    SUM(CASE WHEN `Transaction Type` = 'credit' 
             THEN Amount  
             ELSE 0 END) 
  - SUM(CASE WHEN `Transaction Type` = 'debit' 
             THEN Amount  
             ELSE 0 END) 
    AS Net_Transaction_Amount
FROM debitcredit;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 5.Account activity ratio */
SELECT 
  CONCAT(ROUND(COUNT(`Transaction Type`) / SUM(`Balance`), 5), ':1') AS `Account_Activity_Ratio`
FROM debitcredit;

-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 6.Transaction per month */

SELECT 
    DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Month,
    COUNT(*) AS Number_of_Transactions
FROM debitcredit
GROUP BY DATE_FORMAT(`Transaction Date`, '%Y-%m')
ORDER BY Month;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 7.Total transaction amount by branch */

SELECT 
    Branch,
    ROUND(SUM(Amount), 2) AS Total_Transaction_Amount
FROM debitcredit
GROUP BY Branch
ORDER BY Total_Transaction_Amount DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 8.Transaction Volume by Bank */

SELECT 
    `Bank Name`,
    SUM(Amount) AS Total_Amount
FROM debitcredit
GROUP BY `Bank Name`
ORDER BY Total_Amount DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 9.Transaction Method Distributation */
USE bankmodels;

SELECT 
    `Transaction Method`,
    COUNT(*) AS Transaction_Count
FROM debitcredit
GROUP BY `Transaction Method`
ORDER BY Transaction_Count DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 12.Suspicious Transactions */

USE bankmodels;

SELECT 
    DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Month,   -- groups by month
    COUNT(*) AS Suspicious_Transactions
    FROM debitcredit
WHERE 
    
    (LOWER(Description) LIKE '%refund%'
     OR LOWER(Description) LIKE '%chargeback%'
     OR LOWER(Description) LIKE '%lottery%'
     OR LOWER(Description) LIKE '%bet%'
     OR LOWER(Description) LIKE '%gamble%')
    

    AND `Transaction Date` BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY DATE_FORMAT(`Transaction Date`, '%Y-%m')
ORDER BY Month;
-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 11.High Risk Flag */

USE bankmodels;

SELECT 
    `Transaction Date`,
    `Description`,
    `Amount`,
    CASE 
        WHEN LOWER(Description) LIKE '%refund%'
          OR LOWER(Description) LIKE '%chargeback%'
          OR LOWER(Description) LIKE '%lottery%'
          OR LOWER(Description) LIKE '%bet%'
          OR LOWER(Description) LIKE '%gamble%' 
        THEN 'High-Risk'
        ELSE 'Normal'
    END AS Risk_Flag
FROM debitcredit;

-------------------------------------------------------------------------------------------------------------------------------------------------------
/* 10.Branch Transactions growth */
USE bankmodels;
WITH branch_totals AS (
    SELECT 
        `Branch`,
        DATE_FORMAT(`Transaction Date`, '%Y-%m') AS Period,  
        SUM(Amount) AS Total_Amount
    FROM debitcredit
    GROUP BY `Branch`, DATE_FORMAT(`Transaction Date`, '%Y-%m')
)
SELECT 
    `Branch`,
    Period,
    Total_Amount,
    LAG(Total_Amount) OVER (PARTITION BY `Branch` ORDER BY Period) AS Prev_Total,
    ROUND(
        ((Total_Amount - LAG(Total_Amount) OVER (PARTITION BY `Branch` ORDER BY Period)) 
         / LAG(Total_Amount) OVER (PARTITION BY `Branch` ORDER BY Period)) * 100, 2
    ) AS Percentage_Change
FROM branch_totals
ORDER BY `Branch`, Period;
=======================================================================================================================================================

