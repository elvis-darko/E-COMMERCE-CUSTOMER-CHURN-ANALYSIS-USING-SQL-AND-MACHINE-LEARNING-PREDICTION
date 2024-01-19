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

-- 2. WHAT PERCENTAGE OF CUSTOMERS CHURNED?
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

-- 3. WHAT IS THE DISTRIBUTION OF CUSTOMERS ACCORDING TO THE CITY TIERS COLUMN?
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY citytier
ORDER BY churnrate DESC;
-- Answer = citytier3 has the highest churn rate, followed by citytier2 and then citytier1 has the least churn rate.

-- 3. WHAT IS THE DISTRIBUTION OF PREFERRED LOGIN WITH REGARDS TO CHURNING?
SELECT preferredlogindevice, 
        COUNT(*) AS TotalCustomers,
        SUM(churn) AS ChurnedCustomers,
        CAST(SUM(churn) * 1.0 / COUNT(*) * 100 AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY preferredlogindevice ;
-- Answer = The prefered login devices are computer and phone. Computer accounts for the highest churnrate with 20.66% and 
-- phone with 16.79%. 

-- 5. ASCERTAIN CORRELATION BETWEEN WAREHOUSE-TO-HOME AND CUSTOMER ATTRITION?
-- Firstly, we will create a new column that provides a distance range based on the values in warehousetohome column
ALTER TABLE ecommercechurn
ADD warehousetohomerange NVARCHAR(50) ;

UPDATE ecommercechurn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END ;

-- Finding correlation between warehousetohome and churnrate
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC ;
-- Answer = The farther a customer's distance to the warehouse, the higher the likelihood of the customer churning.

-- 6. WHAT IS THE TENURE OF CUSTOMERS WHO CHURNED?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE ecommercechurn
ADD TenureRange NVARCHAR(50) ;

UPDATE ecommercechurn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END ;

-- Finding typical tenure for churned customers
SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY Churnrate DESC;
-- Answer = Most customers churned within a 6 months tenure period

-- 6. WHAT PAYMENNT MODE IS MOST FAVORED BY CUSTOMERS?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC ;
-- Answer = The most prefered payment mode among churned customers is Cash on Delivery.

-- 7. WHAT IS THE CHURN RATE OF MEN AND WOMEN?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY gender
ORDER BY Churnrate DESC ;
-- Answer = 18.51% men churned and 17.05% women churned. It can be concluded that men churned more than women.alter

-- 8. DOES CUSTOMERS' NUMBER OF REGISTERED DEVICES AFFECT CHURN?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC ;
-- Answer = As the number of registered devices increseas the churn rate also increases.  

-- 9. DOES TIME SPENT ON DEVICES AFFECT CHURN?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM ecommercechurn
GROUP BY customerstatus ;
-- Answer = There is no significant difference between the average time spent on the app for churned and non-churned customers

-- 10. WHICH ORDER CATEGORY CHURNED THE MOST?
SELECT preferedordercat,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY preferedordercat
ORDER BY Churnrate DESC ;
-- Answer = Mobile phone category has the highest churn rate and grocery has the least churn rate

-- 11. Does the marital status of customers influence churn behavior?
SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM ecommercechurn
GROUP BY maritalstatus
ORDER BY Churnrate DESC ;
-- Answer = Single customers have the highest churn rate while married customers have the least churn rate