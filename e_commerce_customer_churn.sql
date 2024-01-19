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



