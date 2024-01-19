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
-- Correct the name of inconsistent column
ALTER table ecommerce_churn
RENAME COLUMN ï»¿CustomerID TO CustomerID;

--  Check for duplicate rows
SELECT CustomerID, COUNT(CustomerID) as Count
FROM ecommerce_churn
GROUP BY CustomerID
Having COUNT(CustomerID) > 1
-- Answer = There are no duplicate rows