-- Selecting all data from the travel_data table
SELECT *
FROM Tourism.`travel_data`;

-- Renaming columns to remove spaces and standardize names
ALTER TABLE travel_data
RENAME COLUMN `Start date` to `Start_date`;

-- Formatting Start_date to a date format
SELECT `Start_date`,
STR_TO_DATE(`Start_date`, '%m/%d/%Y') AS Formatted_date
FROM travel_data;

-- Updating Start_date column with formatted dates and setting blanks to NULL
UPDATE travel_data
SET `Start_date` = 
    CASE
        WHEN `Start_date` IS NOT NULL AND `Start_date` != 'NULL' AND `Start_date` != '' THEN STR_TO_DATE(`Start_date`, '%m/%d/%Y')
        ELSE NULL
    END;

-- Changing the Start_date column to DATE type
ALTER TABLE travel_data
MODIFY COLUMN `Start_date` DATE;

-- Renaming End date column and formatting it
ALTER TABLE travel_data
RENAME COLUMN `End date` to `End_date`;

-- Formatting End_date to a date format
SELECT `End_date`,
STR_TO_DATE(`End_date`, '%m/%d/%Y') AS Formatted_date
FROM travel_data;

-- Updating End_date column with formatted dates and setting blanks to NULL
UPDATE travel_data
SET `End_date` =
    CASE
        WHEN `End_date` IS NOT NULL AND `End_date` != 'NULL' AND `End_date` != '' THEN STR_TO_DATE(`End_date`, '%m/%d/%Y') ELSE NULL
    END;

-- Changing the End_date column to DATE type
ALTER TABLE travel_data
MODIFY COLUMN `End_date` DATE;

-- Selecting all data to confirm changes
SELECT *
FROM Tourism.`travel_data`;

-- Renaming multiple columns to remove spaces and standardize names
ALTER TABLE travel_data
RENAME COLUMN `Trip ID` TO `Trip_id`,
RENAME COLUMN `Duration (days)` TO `Duration_days`,
RENAME COLUMN `Traveler name` TO `Traveler_name`,
RENAME COLUMN `Traveler age` TO `Traveler_age`,
RENAME COLUMN `Traveler gender` TO `Gender`,
RENAME COLUMN `Traveler nationality` TO `Nationality`,
RENAME COLUMN `Accommodation cost` TO `Accommodation_cost`,
RENAME COLUMN `Transportation type` TO `Transportation_type`,
RENAME COLUMN `Accommodation type` TO `Accommodation_type`,
RENAME COLUMN `Transportation cost` TO `Transportation_cost`;

-- Creating a new table travel_data_1 with the updated structure
CREATE TABLE `travel_data_1` (
  `Trip_id` int DEFAULT NULL,
  `Destination` text,
  `Start_date` date DEFAULT NULL,
  `End_date` date DEFAULT NULL,
  `Duration_days` text,
  `Traveler_name` text,
  `Traveler_age` text,
  `Gender` text,
  `Nationality` text,
  `Accommodation_type` text,
  `Accommodation_cost` text,
  `Transportation_type` text,
  `Transportation_cost` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting data from the original table into the new table
INSERT travel_data_1
SELECT *
FROM travel_data;

-- Deleting rows with null or blank values in any key columns
DELETE
FROM travel_data_1
WHERE `Trip_id` = ''
OR `Destination` = ''
OR `Start_date` IS NULL
OR `End_date` IS NULL
OR `Duration_days` = ''
OR `Traveler_name` = ''
OR `Traveler_age` = ''
OR `Gender` = ''
OR `Nationality` = ''
OR `Accommodation_type` = ''
OR `Accommodation_cost` = ''
OR `Transportation_type` = ''
OR `Transportation_cost` = '';

-- Checking for null or blank values in the Duration_days column
SELECT Duration_days
FROM travel_data_1
WHERE Duration_days IS NULL
OR Duration_days = '';

-- Changing data type of Duration_days to INT
ALTER TABLE travel_data_1
MODIFY COLUMN `Duration_days` INT;

-- Cleaning and updating the Accommodation_cost column to remove currency symbols and convert to INT
UPDATE travel_data_1
SET `Accommodation_cost` = REPLACE(REPLACE(REPLACE(`Accommodation_cost`, '$', ''), 'USD', ''), ',', '');

ALTER TABLE travel_data_1
MODIFY COLUMN `Accommodation_cost` INT;

-- Cleaning and updating the Transportation_cost column to remove currency symbols and convert to INT
UPDATE travel_data_1
SET `Transportation_cost` = REPLACE(REPLACE(REPLACE(`Transportation_cost`, '$', ''), 'USD', ''), ',', '');

ALTER TABLE travel_data_1
MODIFY COLUMN `Transportation_cost` INT;

-- Changing data type of Traveler_age to INT
ALTER TABLE travel_data_1
MODIFY COLUMN `Traveler_age` INT;

-- Identifying duplicate rows based on key columns
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Trip_id`,`Destination`,`Start_date`,`End_date`, `Duration_days`, `Traveler_name`,`Traveler_age`, `Gender`, `Nationality`, `Accommodation_type` , `Accommodation_cost`,`Transportation_type`, `Transportation_cost`) AS Row_num
FROM travel_data_1;

-- Creating a CTE to find duplicate rows
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `Trip_id`,`Destination`,`Start_date`,`End_date`, `Duration_days`, `Traveler_name`,`Traveler_age`, `Gender`, `Nationality`, `Accommodation_type` , `Accommodation_cost`,`Transportation_type`, `Transportation_cost`) AS Row_num
FROM travel_data_1
)
SELECT *
FROM duplicate_cte
WHERE Row_num >1;

-- Selecting distinct destinations to identify and correct inconsistencies
SELECT DISTINCT(Destination)
FROM travel_data_1;

-- Correcting specific destination names for consistency
UPDATE travel_data_1
SET `Destination` = CONCAT(`Destination`, ', Netherland')
WHERE `Destination` = 'Amsterdam';

UPDATE travel_data_1
SET `Destination` = REPLACE(`Destination`, 'AmsterdamNetherland', 'Amsterdam, Netherlands')
WHERE `Destination` LIKE 'AmsterdamNetherland';

-- Updating various destinations with correct country names
UPDATE travel_data_1
SET `Destination` =
    CASE 
        WHEN `Destination` = 'Edinburgh' THEN CONCAT(`Destination`, ', Scotland')
        WHEN `Destination` = 'Paris' THEN CONCAT(`Destination`, ', France')
        WHEN `Destination` = 'Bali' THEN CONCAT(`Destination`, ', Indonesia')
        WHEN `Destination` = 'London' THEN CONCAT(`Destination`, ', England')
        WHEN `Destination` = 'Tokyo' THEN CONCAT(`Destination`, ', Japan')
        WHEN `Destination` = 'New York' THEN CONCAT(`Destination`, ', USA')
        WHEN `Destination` = 'Sydney' THEN CONCAT(`Destination`, ', Australia')
        WHEN `Destination` = 'Rome' THEN CONCAT(`Destination`, ', Italy')
        WHEN `Destination` = 'Bangkok' THEN CONCAT(`Destination`, ', Thailand')
        WHEN `Destination` = 'Hawaii' THEN CONCAT(`Destination`, ', USA')
        WHEN `Destination` = 'Barcelona' THEN CONCAT(`Destination`, ', Spain')
        WHEN `Destination` = 'Cape Town' THEN CONCAT(`Destination`, ', South Africa')
        WHEN `Destination` = 'Cape Town, SA' THEN CONCAT(REPLACE(`Destination`, 'Cape Town, SA', 'Cape Town'), ', South Africa') 
        WHEN `Destination` = 'Bangkok, Thai' THEN CONCAT(REPLACE(`Destination`, 'Bangkok, Thai', 'Bangkok'), ', Thailand')
        WHEN `Destination` = 'Phuket, Thai' THEN CONCAT(REPLACE(`Destination`, 'Phuket, Thai', 'Phuket'), ', Thailand')
        WHEN `Destination` = 'Dubai' THEN CONCAT(`Destination`, ', United Arab Emirates')
        WHEN `Destination` = 'Seoul' THEN CONCAT(`Destination`, ', South Korea')
        WHEN `Destination` = 'Rio de Janeiro' THEN CONCAT(`Destination`, ', Brazil')
        WHEN `Destination` = 'Phuket' THEN CONCAT(`Destination`, ', Thailand')
        WHEN `Destination` = 'Santorini' THEN CONCAT(`Destination`, ', Greece')
        WHEN `Destination` = 'Phnom Penh' THEN CONCAT(`Destination`, ', Cambodia')
        WHEN `Destination` = 'Sydney, Aus' THEN CONCAT(REPLACE(`Destination`, 'Sydney, Aus', 'Sydney'), ', Australia')
        WHEN `Destination` = 'Japan' THEN 'Tokyo, Japan'
        WHEN `Destination` = 'Thailand' THEN 'Bangkok, Thailand'
        WHEN `Destination` = 'Australia' THEN 'Sydney, Australia'
        WHEN `Destination` = 'Brazil' THEN 'Rio de Janeiro, Brazil'
        WHEN `Destination` = 'Greece' THEN 'Athens, Greece'
        WHEN `Destination` = 'Egypt' THEN 'Cairo, Egypt'
        WHEN `Destination` = 'Mexico' THEN 'Mexico City, Mexico'
        WHEN `Destination` = 'Italy' THEN 'Rome, Italy'
        WHEN `Destination` = 'Spain' THEN 'Barcelona, Spain'
        WHEN `Destination` = 'Canada' THEN 'Toronto, Canada'
        ELSE `Destination`
        END;

-- Further refining destination names
UPDATE travel_data_1
SET `Destination` = CASE
        WHEN `Destination` = 'France' THEN 'Paris, France'
        ELSE `Destination`
    END;

UPDATE travel_data_1
SET `Destination` = REPLACE(`Destination`, 'Syndey, Australia', 'Sydney, Australia');

-- Verifying updated destination names
SELECT DISTINCT(Destination)
FROM travel_data_1;

-- Adding new columns to split destination into city and country
ALTER TABLE travel_data_1
ADD COLUMN Destination_city VARCHAR(30),
ADD COLUMN Destination_country VARCHAR(20);

-- Updating new columns with split values
UPDATE travel_data_1
SET Destination_city = TRIM(SUBSTRING_INDEX(Destination, ',', 1)),
    Destination_country = TRIM(SUBSTRING_INDEX(Destination, ',', -1));

-- Standardizing transportation types
SELECT DISTINCT(Transportation_type)
FROM travel_data_1;

UPDATE travel_data_1
SET `Transportation_type` = 'Flight'
WHERE `Transportation_type` IN ('Airplane', 'Plane');

-- Correcting nationalities for consistency
SELECT DISTINCT(Nationality)
FROM travel_data_1;

UPDATE travel_data_1
SET `Nationality` = REPLACE(`Nationality`, 'United Kingdom', 'British');

UPDATE travel_data_1
SET `Nationality` = REPLACE(`Nationality`, 'United Arab Emirates', 'Emirati');

UPDATE travel_data_1
SET `Nationality` = REPLACE(`Nationality`, 'USA', 'American');

UPDATE travel_data_1
SET `Nationality` = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(`Nationality`, 'Canada', 'Canadian'), 'Korean', 'South Korean'), 'Japan', 'Japanese'), 'Brazil', 'Brazilian'), 'China', 'Chinese'), 'Cambodia', 'Cambodian'), 'Italy', 'Italian'), 'Singapore', 'Singaporean'),
'Taiwan', 'Taiwanese');

UPDATE travel_data_1
SET `Nationality` = REPLACE(REPLACE(REPLACE(`Nationality`,'Japaneseese', 'Japanese'), 'Germany', 'German'), 'Morocccan', 'Moroccan');

UPDATE travel_data_1
SET `Nationality` = REPLACE(`Nationality`, 'Taiwaneseese', 'Taiwanese');

UPDATE travel_data_1
SET `Nationality` = REPLACE(`Nationality`, 'Brazilianian', 'Brazilian');

-- Counting occurrences of each nationality
SELECT DISTINCT(`Nationality`), COUNT(*)
FROM travel_data_1
GROUP BY `Nationality`
ORDER BY COUNT(*) DESC;

-- Adding a new column for season based on the start date
ALTER TABLE travel_data_1
ADD COLUMN `Season` VARCHAR(20);

-- Updating the season column based on the start date month
UPDATE travel_data_1
SET `Season` =
    CASE
        WHEN MONTH(`Start_date`) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(`Start_date`) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(`Start_date`) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
        END;

-- Counting trips per season
SELECT DISTINCT(Season), COUNT(*)
FROM travel_data_1
GROUP BY Season
ORDER BY COUNT(*) DESC;

-- Final dataset selection for further analysis
SELECT *
FROM travel_data_1;

-- Counting trips per traveler
SELECT DISTINCT(Traveler_name), COUNT(*)
FROM travel_data_1
GROUP BY Traveler_name
ORDER BY COUNT(*) DESC;

-- Detailed selection for specific traveler
SELECT Trip_id, Traveler_name, Destination, Start_date, End_date, Season, Duration_days, Destination_country, Transportation_type, Transportation_cost, Accommodation_type, Accommodation_cost
FROM travel_data_1
WHERE Traveler_name = 'David Lee'
ORDER BY Traveler_name;

-- Popularity analysis by destination
SELECT Destination, COUNT(*) AS Number_of_visits
FROM travel_data_1
GROUP BY Destination
ORDER BY Number_of_visits DESC;

-- Popular transportation mode and average cost analysis
SELECT Transportation_type, COUNT(*) AS Count_transportation_mode, ROUND(AVG(Transportation_cost)) AS Avg_trans_cost
FROM travel_data_1
GROUP BY Transportation_type
ORDER BY Count_transportation_mode DESC, Avg_trans_cost DESC;

-- Yearly growth rate analysis by destination country
WITH YearlyVisits AS (
    SELECT
        Destination_country,
        SUM(CASE WHEN YEAR(`Start_date`) = 2021 THEN 1 ELSE 0 END) AS Visiting_2021,
        SUM(CASE WHEN YEAR(`Start_date`) = 2022 THEN 1 ELSE 0 END) AS Visiting_2022,
        SUM(CASE WHEN YEAR(`Start_date`) = 2023 THEN 1 ELSE 0 END) AS Visiting_2023,
        SUM(CASE WHEN YEAR(`Start_date`) = 2024 THEN 1 ELSE 0 END) AS Visiting_2024,
        SUM(CASE WHEN YEAR(`Start_date`) = 2025 THEN 1 ELSE 0 END) AS Visiting_2025
    FROM
        travel_data_1
    GROUP BY
        Destination_country
)
SELECT
    Destination_country,
    Visiting_2021,
    Visiting_2022,
    Visiting_2023,
    Visiting_2024,
    Visiting_2025,
    COALESCE(CASE WHEN Visiting_2021 = 0 THEN 'No Data' ELSE ROUND((Visiting_2022 - Visiting_2021) / Visiting_2021 * 100, 2) END, 'No Data') AS Growth_2021_to_2022,
    COALESCE(CASE WHEN Visiting_2022 = 0 THEN 'No Data' ELSE ROUND((Visiting_2023 - Visiting_2022) / Visiting_2022 * 100, 2) END, 'No Data') AS Growth_2022_to_2023,
    COALESCE(CASE WHEN Visiting_2023 = 0 THEN 'No Data' ELSE ROUND((Visiting_2024 - Visiting_2023) / Visiting_2023 * 100, 2) END, 'No Data') AS Growth_2023_to_2024,
    COALESCE(CASE WHEN Visiting_2024 = 0 THEN 'No Data' ELSE ROUND((Visiting_2025 - Visiting_2024) / Visiting_2024 * 100, 2) END, 'No Data') AS Growth_2024_to_2025
FROM
    YearlyVisits
ORDER BY
    Destination_country;

-- Analyzing traveler data by age
SELECT Traveler_age, COUNT(*), AVG(Traveler_age) AS Avg_age
FROM travel_data_1
GROUP BY Traveler_age
ORDER BY COUNT(*) DESC;

-- Transportation preferences by age group
SELECT 
    CASE 
        WHEN Traveler_age <=25 THEN '18-25'
        WHEN Traveler_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Traveler_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Traveler_age > 45 THEN '45+'
    END AS Age_group,
    Accommodation_type,
    Transportation_type,
    COUNT(*) AS Total_trips, ROUND(AVG(Accommodation_cost)) AS Avg_accommodation_cost, ROUND(AVG(Transportation_cost)) AS Avg_transportation_cost
FROM travel_data_1
GROUP BY Age_group, Accommodation_type, Transportation_type
ORDER BY Age_group, Total_trips DESC;

-- Destination popularity by age group
SELECT 
    Destination_country,
    CASE
        WHEN Traveler_age <= 25 THEN '18-25'
        WHEN Traveler_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Traveler_age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Traveler_age >45 THEN '45+'
    END AS Age_group,
    COUNT(*) Total_trips
FROM travel_data_1
GROUP BY Destination_country, Age_group
ORDER BY Destination_country, Age_group DESC;

-- Season analysis by number of trips and average traveler age
SELECT Season, COUNT(*) Total_trips, AVG(Traveler_age) AS Avg_age
FROM travel_data_1
GROUP BY Season
ORDER BY Season;

-- Average cost analysis by destination country
SELECT
    Destination_country,
    ROUND(AVG(Accommodation_cost)) AS Avg_accommodation_cost,
    ROUND(AVG(Transportation_cost)) AS Avg_transportation_cost,
   ROUND(SUM(Accommodation_cost + Transportation_cost)) AS Total_spent
FROM travel_data_1
GROUP BY Destination_country
ORDER BY Total_spent DESC;

-- Accommodation preferences by nationality
SELECT Nationality, Accommodation_type, COUNT(*) AS Trips
FROM travel_data_1
GROUP BY Nationality, Accommodation_type
ORDER BY Nationality, Trips DESC;

-- Average spending by nationality
SELECT Nationality, ROUND(AVG(Accommodation_cost)) AS Avg_accommodation_cost, ROUND(AVG(Transportation_cost)) AS Avg_trans_cost
FROM travel_data_1
GROUP BY Nationality
ORDER BY Avg_accommodation_cost DESC;
