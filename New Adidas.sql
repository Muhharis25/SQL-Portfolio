# Cleaning Data

/* Displaying entire dataset */
SELECT * 
FROM sales_data.data_sales;

/* Retrieving distinct retailers */
SELECT DISTINCT Retailer 
FROM sales_data.data_sales;

/* Creating a duplicate table for data manipulation */
CREATE TABLE data_sales1 
LIKE sales_data.data_sales;

INSERT INTO data_sales1 
SELECT * 
FROM data_sales;

/* Review inserted data */
SELECT * 
FROM data_sales1;

# Standardizing Data

/* Converting string date to date format */
SELECT `Invoice Date`, STR_TO_DATE(`Invoice Date`, '%m/%d/%Y') 
FROM data_sales1;

UPDATE data_sales1 
SET `Invoice Date` = STR_TO_DATE(`Invoice Date`, '%m/%d/%Y');

# Cleaning Column Names

/* Standardizing column names for uniformity */
ALTER TABLE data_sales1 
RENAME COLUMN `Retailer ID` TO Retailer_id;

ALTER TABLE data_sales1 
RENAME COLUMN `Invoice Date` TO Invoice_date;

ALTER TABLE data_sales1 
RENAME COLUMN `Price per Unit` TO Price_per_unit;

ALTER TABLE data_sales1 
RENAME COLUMN `Units Sold` TO Units_sold;

ALTER TABLE data_sales1
RENAME COLUMN `Total Sales` TO Total_sales;
 
ALTER TABLE data_sales1 
RENAME COLUMN `Operating Profit` TO Operating_profit;

ALTER TABLE data_sales1 
RENAME COLUMN `Sales Method` TO Sales_method;

/* Checking data types for key columns */
SELECT column_name, data_type 
FROM information_schema.columns
WHERE table_schema = "sales_data" AND table_name = "data_sales1";

# Data Type Correction

/* Modifying columns to correct data types */
ALTER TABLE data_sales1 
MODIFY COLUMN `Invoice_date` DATE;

UPDATE data_sales1 
SET Operating_profit = REPLACE(REPLACE(Operating_profit, ',', ''), '$', '');

ALTER TABLE data_sales1 
MODIFY COLUMN `Operating_profit` INT;

UPDATE data_sales1 
SET Total_sales = REPLACE(Total_sales, ',', '');

ALTER TABLE data_sales1 
MODIFY COLUMN `Total_sales` INT;

UPDATE data_sales1 
SET Price_per_unit = REPLACE(Price_per_unit, '$', '');

ALTER TABLE data_sales1 
MODIFY COLUMN `Price_per_unit` INT;

# Checking for Nulls and Blanks

/* Identifying rows with missing or null values */
SELECT * 
FROM data_sales1
WHERE Retailer = '' 
OR Retailer_id = '' 
OR Invoice_date IS NULL 
OR Region = ''
OR State = '' 
OR Product = '' 
OR Price_per_unit = '' 
OR Units_sold = ''
OR Total_sales = '' 
OR Operating_profit = '' 
OR Sales_method = '';

/* Deleting rows where units sold are blank */
DELETE 
FROM data_sales1
WHERE Units_sold = '';

# Data Consistency Checks

/* Updating price per unit where previously blank */
UPDATE data_sales1 
SET Price_per_unit = IFNULL(Price_per_unit, Total_sales / Units_sold) 
WHERE Price_per_unit = '';

/* Correcting total sales values because discrepancies were identified between the calculated total sales
   and the previously stored `Total_sales` values, possibly due to earlier data entry errors or updates
   to prices or units that were not reflected in the total. */
UPDATE data_sales1 
SET Total_sales = Price_per_unit * Units_sold;

# Enhancing Data with Additional Columns
# Spelling Corrections and Handling Duplicates

/* Creating a new table to fix and standardize data without altering the original data */
CREATE TABLE `data_sales2` (
  `Retailer` TEXT,
  `Retailer_id` INT DEFAULT NULL,
  `Invoice_date` DATE DEFAULT NULL,
  `Region` TEXT,
  `State` TEXT,
  `City` TEXT,
  `Product` TEXT,
  `Price_per_unit` INT DEFAULT NULL,
  `Units_sold` INT DEFAULT NULL,
  `Total_sales` INT DEFAULT NULL,
  `Operating_profit` INT DEFAULT NULL,
  `Sales_method` TEXT,
  `Row_Num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* Inserting data into the new table while assigning a row number to detect duplicates */
INSERT INTO data_sales2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Retailer, Retailer_id, `Invoice_date`, Region, State, City, Product,
Price_per_unit, Units_sold, Total_sales, Operating_profit, Sales_method) AS Row_Num
FROM data_sales1;

/* Querying to check occurrences of a specific row number, typically to detect duplicates */
SELECT Retailer, Row_Num, COUNT(*)
FROM data_sales2
WHERE Row_Num = 4
GROUP BY Retailer;

/* Identifying and correcting misspellings in product names */
SELECT *
FROM data_sales1
WHERE Product = "Men's aparel";  -- Incorrect spelling identified

/* 1. First, it corrects "Men's aparel" to "Men's Apparel", addressing a typo.
   2. Second, it ensures any incorrectly escaped apostrophes from previous data handling
      ("Men''s Apparel") are standardized to "Men's Apparel".
   This ensures data consistency and accuracy in product names across the dataset. */
UPDATE data_sales1
SET Product = REPLACE(REPLACE(Product, "Men's aparel", "Men's Apparel"), "Men''s Apparel", "Men's Apparel");

/* Checking for duplicates by evaluating the assigned row numbers */
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Retailer, Retailer_id, `Invoice_date`, Region, State, City, Product,
Price_per_unit, Units_sold, Total_sales, Operating_profit, Sales_method) AS Row_Num
FROM data_sales1;

/* Using a Common Table Expression (CTE) to simplify the handling of duplicates */
WITH duplicates_cte AS (
  SELECT *,
  ROW_NUMBER() OVER(PARTITION BY Retailer, Retailer_id, `Invoice_date`, Region, State, City, Product,
  Price_per_unit, Units_sold, Total_sales, Operating_profit, Sales_method) AS Row_Num
  FROM data_sales1
)
SELECT *
FROM duplicates_cte
WHERE Row_Num = 4;  -- Example to show how to filter duplicates if Row_Num > 1 would indicate duplicates

/* No duplicates found, confirming data integrity */


# Creating and Manipulating a Temporary Table

/* Temporary table creation to handle intermediate data manipulations */
CREATE TEMPORARY TABLE temp_data_sales4 AS 
SELECT *
FROM data_sales1;

/* Adding new columns for temporal data analysis */
ALTER TABLE temp_data_sales4 
ADD COLUMN Year INT,
ADD COLUMN Month INT,
ADD COLUMN Season VARCHAR(10);

/* Updating the temporary table with year, month, and season data */
UPDATE temp_data_sales4
SET 
	Year = YEAR(`Invoice_date`),
    Month = MONTH(`Invoice_date`),
    Season = CASE
				WHEN MONTH(`Invoice_date`) IN (12, 1, 2) THEN 'Winter'
                WHEN MONTH(`Invoice_date`) IN (3, 4, 5) THEN 'Spring'
                WHEN MONTH(`Invoice_date`) IN (6, 7, 8) THEN 'Summer'
                ELSE 'Autumn'
			END;

/* Querying updated data to verify the changes and understand data distribution */
SELECT Retailer, Retailer_id, `Invoice_date`, `Year`, `Month`, Season, State, Product, Sales_method
FROM temp_data_sales4;

/* Dropping the temporary table after use */
DROP TEMPORARY TABLE IF EXISTS temp_data_sales4;

/* Adding columns for year, month, and season */
ALTER TABLE data_sales1
ADD COLUMN Year INT, 
ADD COLUMN Month INT, 
ADD COLUMN Season VARCHAR(10);

UPDATE data_sales1
SET Year = YEAR(`Invoice_date`),
    Month = MONTH(`Invoice_date`),
    Season = CASE
                WHEN MONTH(`Invoice_date`) IN (12, 1, 2) THEN 'Winter'
                WHEN MONTH(`Invoice_date`) IN (3, 4, 5) THEN 'Spring'
                WHEN MONTH(`Invoice_date`) IN (6, 7, 8) THEN 'Summer'
                ELSE 'Autumn'
             END;

# Reorganizing Data for Analysis and making it presenatable

/* Creating a structured table with added temporal and seasonal columns */
CREATE TABLE `data_sales3` (
  `Retailer` TEXT,
  `Retailer_id` INT,
  `Invoice_date` DATE,
  `Year` INT,
  `Month` INT,
  `Season` VARCHAR(10),
  `Region` TEXT,
  `State` TEXT,
  `City` TEXT,
  `Product` TEXT,
  `Price_per_unit` INT,
  `Units_sold` INT,
  `Total_sales` INT,
  `Operating_profit` INT,
  `Sales_method` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/* Populating new table with clean data */
INSERT INTO data_sales3
SELECT
    Retailer,
    Retailer_id,
    Invoice_date,
    YEAR(Invoice_date) AS Year,       
    MONTH(Invoice_date) AS Month,
    CASE                              
        WHEN MONTH(Invoice_date) BETWEEN 3 AND 5 THEN 'Spring'
        WHEN MONTH(Invoice_date) BETWEEN 6 AND 8 THEN 'Summer'
        WHEN MONTH(Invoice_date) BETWEEN 9 AND 11 THEN 'Autumn'
        ELSE 'Winter'
    END AS Season,
    Region,
    State,
    City,
    Product,
    Price_per_unit,
    Units_sold,
    Total_sales,
    Operating_profit,
    Sales_method
FROM data_sales2;

# Data Analysis

/* Growth analysis by seasons */
SELECT Season, SUM(ROUND(Total_sales/1000000,2)) AS Total_sales,
SUM(Units_sold) AS Total_Units_sold
FROM data_sales3
GROUP BY Season
ORDER BY Total_sales DESC;

/* Monthly sales comparison for two consecutive years */
SELECT DATE_FORMAT(Invoice_date, '%M') AS Months,
ROUND(SUM(CASE WHEN YEAR(Invoice_date) = 2020 THEN Total_sales ELSE 0 END) / 1000000, 2) AS Total_sales_2020,
ROUND(SUM(CASE WHEN YEAR(Invoice_date) = 2021 THEN Total_sales ELSE 0 END) /1000000, 2) AS Total_sales_2021
FROM data_sales3
GROUP BY MONTH(Invoice_date), Months
ORDER BY MONTH(Invoice_date);

/* Calculating growth rate by year using a common table expression (CTE) */
WITH CTE AS
(SELECT
    SUM(CASE WHEN Year = 2020 THEN Total_sales ELSE 0 END) AS T_sales_2020,
    SUM(CASE WHEN Year = 2021 THEN Total_sales ELSE 0 END) AS T_sales_2021
 FROM data_sales3)
SELECT
    ROUND(T_sales_2020 / 1000000, 2) AS Total_sales_2020,
    ROUND(T_sales_2021 / 1000000, 2) AS Total_sales_2021,
    CASE
        WHEN T_sales_2020 = 0 THEN NULL
        ELSE ROUND(((T_sales_2021 - T_sales_2020) / T_sales_2020) * 100, 2)
    END AS Growth_rate
FROM CTE;

/* Geospatial analysis by region */
SELECT Region, ROUND(SUM(Total_sales)/1000000, 2) AS Total_sales
FROM data_sales3
GROUP BY Region
ORDER BY Total_sales DESC;

/* Identifying top and bottom states in terms of total sales */
SELECT State, ROUND(SUM(Total_sales) / 1000000, 2) AS Total_sales
FROM data_sales3
GROUP BY State
ORDER BY Total_sales DESC
LIMIT 10;  -- Top 10 states

SELECT State, ROUND(SUM(Total_sales) / 1000000, 2) AS Total_sales
FROM data_sales3
GROUP BY State
ORDER BY Total_sales ASC
LIMIT 10;  -- Bottom 10 states

/* Analysis of product sales and growth */
SELECT Product, ROUND(SUM(Total_sales) / 1000000, 2) AS Total_sales,
ROUND(SUM(Units_sold)/1000, 2) AS Total_units_sold
FROM data_sales3
GROUP BY Product
ORDER BY Total_sales DESC;

/* Analyzing customer data and sales methods */
SELECT Sales_method, ROUND(SUM(Total_sales) / 1000000, 2) AS Total_sales,
ROUND(SUM(Units_sold)/1000,2) AS Total_units_sold
FROM data_sales3
GROUP BY Sales_method
ORDER BY Total_sales DESC, Total_units_sold DESC;


