**Cleaning Data**

  **1. Initial Queries:**
  Display the entire dataset and unique retailer names to understand data composition.

  **2. Table Duplication:**
  Create a new table data_sales1 to preserve the original data during manipulation.

  **3. Date Conversion:**
  Convert invoice dates from string format to a date format for better manipulation and analysis.

**Standardizing**

  **1. Column Name Standardization:**
  Renames columns to remove spaces and standardize naming conventions for easier SQL handling.

**Data Type Correction**

  **1. Data Type Conversion:**
  Corrects the data types of several columns, such as converting invoice dates to the DATE type and financial figures from strings to integers after cleaning 
  out unwanted characters like commas and dollar signs.
  Handling Missing Values

  **2. Identify Nulls and Blanks:**
  Identify and remove rows with critical missing data to ensure data integrity.

  **3. Derived Calculations:**
  Updates incorrect or missing price per unit values using the total sales and units sold data.

**Deduplication**

  **1. Duplicate Detection and Removal:**
  Checks for and removes duplicate records to ensure each entry is unique.
  Enhancements

  **2. Adding Time Dimensions:**
  Enhances the dataset by calculating and adding columns for the year, month, and season based on invoice dates. This categorization aids in time-based 
  analysis.

**Growth Analysis**

  **1. Seasonal and Yearly Growth**
  Calculates total sales and growth metrics by seasons and years to identify trends and performance over time.

  **2. Detailed Monthly Analysis:**
  Provides a detailed breakdown of sales by month across two years to compare performance and seasonal impacts.

**Geospatial Analysis**

  **1. Regional Sales Analysis:**
  Aggregates sales by region and state to pinpoint higher and lower performing areas. Includes top and bottom performers which could influence regional 
  business strategies.

**Product Analysis**

  **1. Product Performance:**
  Identifies top-selling and highest growth rate products, informing stock and marketing decisions.

  **2. Sales Method Efficiency:**
  Analyzes sales effectiveness by method (online, in-store, etc.), guiding strategic adjustments in sales approaches.

**Customer Insights**

  **1. Retailer Analysis:**
  Focuses on retailer performance by counting transactions, helping understand retailer influence on sales.
