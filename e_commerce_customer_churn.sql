/*******************************
PROJECT INTRODUCTION
This is a project that contains data of transactions at an e-commerce business. The dataset contains details of customer 
transactional behaviour.
This project aims to analyze customer transactions as well as determine customers who are continually patronizing the company's
products and customers who have stopped using the company's products.
***************************/

/**********************
DATA CLEANING
**********************/

-- CORRECT THE NAME OF THE TABLE
RENAME table ecommerce_churn to ecommercechurn;

-- CORRECT THE NAME OF INCONSISTENT COLUMNS
ALTER table ecommercechurn
RENAME COLUMN ï»¿CustomerID TO CustomerID;

--  CHECK FOR DUPLICATE ROWS
SELECT CustomerID, COUNT(CustomerID) as Count
FROM ecommercechurn
GROUP BY CustomerID
Having COUNT(CustomerID) > 1;
-- Answer = There are no duplicate rows

--  CHECK FOR AND COUNT NULL VALUES IN COLUMNS
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE Tenure IS NULL 
UNION
SELECT 'WarehouseToHome' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE warehousetohome IS NULL 
UNION
SELECT 'HourSpendonApp' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE hourspendonapp IS NULL
UNION
SELECT 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE orderamounthikefromlastyear IS NULL 
UNION
SELECT 'CouponUsed' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE couponused IS NULL 
UNION
SELECT 'OrderCount' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE ordercount IS NULL 
UNION
SELECT 'DaySinceLastOrder' as ColumnName, COUNT(*) AS NullCount 
FROM ecommercechurn
WHERE daysincelastorder IS NULL;


-- HANDLE NULL VALUES
-- We will fill null values with their mean. 

UPDATE ecommercechurn
SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM ecommercechurn)
WHERE orderamounthikefromlastyear IS NULL ;

UPDATE ecommercechurn
SET Hourspendonapp = (SELECT AVG(Hourspendonapp) FROM ecommercechurn)
WHERE Hourspendonapp IS NULL;

UPDATE ecommercechurn
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM ecommercechurn)
WHERE WarehouseToHome IS NULL ;

UPDATE ecommercechurn
SET tenure = (SELECT AVG(tenure) FROM ecommercechurn)
WHERE tenure IS NULL;

UPDATE ecommercechurn
SET daysincelastorder = (SELECT AVG(daysincelastorder) FROM ecommercechurn)
WHERE daysincelastorder IS NULL ;

UPDATE ecommercechurn
SET couponused = (SELECT AVG(couponused) FROM ecommercechurn)
WHERE couponused IS NULL ;

UPDATE ecommercechurn
SET ordercount = (SELECT AVG(ordercount) FROM ecommercechurn)
WHERE ordercount IS NULL ;


 -- CREATE NEW COLUMN FROM THE COMPLAIN COLUMN
-- The values in complain column are 0 and 1 values where O means No and 1 means Yes. I will create a new column 
-- called complainrecieved that shows 'Yes' and 'No' instead of 0 and 1  
ALTER TABLE ecommercechurn
ADD ComplainRecieved NVARCHAR(10);

UPDATE ecommercechurn
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END;


-- CREATE NEW COLUMN WITH THE VALUES IN THE CHURN COLUMN
-- The values in churn column are 0 and 1 values were O means stayed and 1 means churned. I will create a new column 
-- called customerstatus that shows 'Stayed' and 'Churned' instead of 0 and 1

ALTER TABLE ecommercechurn
ADD CustomerStatus NVARCHAR(50);

UPDATE ecommercechurn
SET CustomerStatus = 
CASE 
    WHEN Churn = 1 THEN 'Churned' 
    WHEN Churn = 0 THEN 'Stayed'
END ;


-- CHECK COLUMN VALUES FOR ACCURACY AND CONSISTENCY

-- a) check distinct value in warehousetohome column
SELECT DISTINCT warehousetohome
FROM ecommercechurn;
-- I can see two values 126 and 127 that are outliers, it could be a data entry error, so I will correct it to 26 & 27 respectively
-- Replace value 127 with 27

-- ) Replace value 126 with 26
UPDATE ecommercechurn
SET warehousetohome = '26'
WHERE warehousetohome = '126';

UPDATE ecommercechurn
SET warehousetohome = '27'
WHERE warehousetohome = '127' ;


-- b) Check distinct values for preferedordercat column
select distinct preferedordercat 
from ecommercechurn ;

-- The result shows mobile phone and mobile, so I replace mobile with mobile phone
-- Replace mobile with mobile phone

UPDATE ecommercechurn
SET preferedordercat = 'Mobile Phone'
WHERE Preferedordercat = 'Mobile' ;

-- c) Check distinct values for preferredlogindevice column
select distinct preferredlogindevice 
from ecommercechurn ;

-- The result shows phone and mobile phone which indicates the same thing, so I will replace mobile phone with phone
--  Replace mobile phone with phone

UPDATE ecommercechurn
SET preferredlogindevice = 'phone'
WHERE preferredlogindevice = 'mobile phone';

-- d) Check distinct values for preferredpaymentmode column
select distinct PreferredPaymentMode 
from ecommercechurn ;

-- The result shows Cash on Delivery and COD which mean the same thing, so I replace COD with Cash on Delivery
-- Replace mobile with mobile phone

UPDATE ecommercechurn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD';


/*************************************
DATA EXPLORATION
*************************************/

-- 1. WHAT IS THE TOTAL NUMBER OF CUSTOMERS
SELECT DISTINCT COUNT(CustomerID) as TotalNumberOfCustomers
FROM ecommercechurn ;
-- Answer = There are 4,293 customers 

-- 1. What is the overall customer churn rate?
SELECT TotalNumberofCustomers, 
       TotalNumberofChurnedCustomers,
       CAST((TotalNumberofChurnedCustomers * 1.0 / TotalNumberofCustomers * 1.0)*100 AS DECIMAL(10,2)) AS ChurnRate
FROM
(SELECT COUNT(*) AS TotalNumberofCustomers
FROM ecommercechurn) AS Total,
(SELECT COUNT(*) AS TotalNumberofChurnedCustomers
FROM ecommercechurn
WHERE CustomerStatus = 'churned') AS Churned ;
-- Answer = The Churn rate is 17.94%






