#  Data from human_resources was structured into human_resources_1. 
-- and adding employee_age. Invalid dates were flagged and removed. hire_date and 
-- termination_date were standardized.
-- A final table, h_r, was created, cleaned, and deduplicated. Analyses covered gender,
-- race, age groups, locations, employment length, departments, job titles, and 
-- termination rates.
-- The result is a cleaned, structured dataset ready for business insights.

-- 1. Select all records from human_resources
SELECT * FROM human_resources;

-- 2. Create a new table human_resources_1 and insert data
CREATE TABLE `human_resources_1` (
  `id` text,
  `first_name` text,
  `last_name` text,
  `birthdate` text,
  `gender` text,
  `race` text,
  `department` text,
  `jobtitle` text,
  `location` text,
  `hire_date` text,
  `termdate` text,
  `location_city` text,
  `location_state` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO human_resources_1
SELECT *
FROM human_resources;

-- 3. Data Cleaning and Standardization
-- Standardize birthdate to DATE format and update it
SELECT `birthdate`,
CASE 
  WHEN `birthdate` LIKE '%-%-%' THEN STR_TO_DATE(`birthdate`, '%m-%d-%Y')
  WHEN `birthdate` LIKE '%/%/%' THEN STR_TO_DATE(`birthdate`, '%m/%d/%Y')
  ELSE NULL
END AS Formatted_date
FROM human_resources_1;

UPDATE human_resources_1
SET `birthdate` = 
  CASE
    WHEN `birthdate` LIKE '%-%-%' THEN STR_TO_DATE(`birthdate`, '%m-%d-%Y')
    WHEN `birthdate` LIKE '%/%/%' THEN STR_TO_DATE(`birthdate`, '%m/%d/%Y')
    ELSE NULL
  END;

ALTER TABLE human_resources_1
MODIFY COLUMN `birthdate` DATE;
ALTER TABLE human_resources_1
RENAME COLUMN `birthdate` TO `date_of_birth`;
ALTER TABLE human_resources_1
RENAME COLUMN `jobtitle` TO `job_title`;
ALTER TABLE human_resources_1
RENAME COLUMN `id` TO `employer_id`;

-- Validate and standardize employer_id
SELECT employer_id
FROM human_resources_1
WHERE employer_id REGEXP '[^0-9-]';

ALTER TABLE human_resources_1
MODIFY COLUMN `employer_id` VARCHAR(20);

-- Add employee_age column and calculate ages
ALTER TABLE human_resources_1
ADD COLUMN `employee_age` INT;

UPDATE human_resources_1
SET `employee_age` = TIMESTAMPDIFF(YEAR, `date_of_birth`, CURDATE());

-- Create temporary table for further data cleaning
CREATE TEMPORARY TABLE human_resources_temp
SELECT * 
FROM human_resources_1;

-- Check and remove invalid date_of_birth records
SELECT MIN(employee_age) AS young, MAX(employee_age) AS old
FROM human_resources_temp;

SELECT COUNT(*) AS count_age
FROM human_resources_temp
WHERE employee_age < '18';

DELETE FROM human_resources_temp
WHERE employee_age < '18';

-- Check for NULL or invalid date_of_birth records
SET sql_mode = '';
SELECT * FROM human_resources_temp
WHERE date_of_birth IS NULL
OR date_of_birth = '0000-00-00';

-- Restore strict mode
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- Additional cleaning: creating a temporary table for invalid_dob flag
CREATE TEMPORARY TABLE temp_table
SELECT * 
FROM human_resources_1;

ALTER TABLE temp_table
ADD COLUMN `invalid_dob` TINYINT DEFAULT 0;

UPDATE temp_table
SET `invalid_dob` = 1
WHERE employee_age < '18';

UPDATE temp_table
SET date_of_birth = NULL,
employee_age = NULL,
invalid_dob = 1
WHERE employee_age < '18';

-- Standardize and rename hire_date and termination_date columns
UPDATE human_resources_1
SET `hire_date` = 
  CASE
    WHEN `hire_date` LIKE '%-%-%' THEN STR_TO_DATE(`hire_date`, '%m-%d-%Y')
    WHEN `hire_date` LIKE '%/%/%' THEN STR_TO_DATE(`hire_date`, '%m/%d/%Y')
    ELSE NULL
  END;

ALTER TABLE human_resources_1
MODIFY COLUMN `hire_date` DATE;
ALTER TABLE human_resources_1
RENAME COLUMN `hire_date` TO `date_of_hire`;
ALTER TABLE human_resources_1
RENAME COLUMN `termdate` TO `termination_date`;

UPDATE human_resources_1
SET `termination_date` = 
  CASE
    WHEN `termination_date` LIKE '%-%-% %:%:% UTC' THEN DATE_FORMAT(STR_TO_DATE(`termination_date`, '%Y-%m-%d %H:%i:%s UTC'), '%Y-%m-%d')
    WHEN `termination_date` = '' THEN 'No Data'
    ELSE NULL
  END;

-- Create a new table h_r for further analysis
CREATE TABLE `h_r` (
  `employer_id` varchar(20) DEFAULT NULL,
  `first_name` text,
  `last_name` text,
  `date_of_birth` date DEFAULT NULL,
  `gender` text,
  `race` text,
  `department` text,
  `job_title` text,
  `location` text,
  `date_of_hire` date DEFAULT NULL,
  `termination_date` text,
  `location_city` text,
  `location_state` text,
  `employee_age` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO h_r
SELECT * 
FROM human_resources_1; 

ALTER TABLE h_r
ADD COLUMN `dob_flag` TINYINT DEFAULT 0;

UPDATE h_r
SET date_of_birth = NULL,
employee_age = NULL,
dob_flag = 1
WHERE employee_age < '18';

-- Remove duplicates
WITH dup_CTE AS
(SELECT *,
ROW_NUMBER() OVER(PARTITION BY employer_id, first_name, last_name, `date_of_birth`, gender, race, department, job_title, location, `date_of_hire`, termination_date, location_city, location_state, employee_age) as row_num
FROM h_r)
SELECT *
FROM dup_CTE
WHERE row_num > 1;

-- Analysis
-- Breakdown of employee gender in companies
SELECT gender, COUNT(*) AS gender_count
FROM h_r
WHERE employee_age >= 18
AND termination_date = 'No Data'
GROUP BY gender;

-- Race Breakdown in companies
SELECT race, department, job_title, COUNT(*) race_count
FROM h_r
WHERE employee_age >= 18
AND termination_date = 'No Data'
GROUP BY race
ORDER BY COUNT(*) DESC;

-- Breakdown by age, gender, employee count
SELECT 
  CASE 
    WHEN `employee_age` <= 25 THEN '18-25'
    WHEN `employee_age` BETWEEN 26 AND 35 THEN '26-35'
    WHEN `employee_age` BETWEEN 36 AND 45 THEN '36-45'
    WHEN `employee_age` BETWEEN 46 AND 55 THEN '46-55'
    WHEN `employee_age` >= 56 THEN '56+'
    ELSE 'Unknown'
  END AS age_group,
  gender,
  COUNT(*) AS employee_count
FROM h_r
WHERE `employee_age` IS NOT NULL
AND termination_date = 'No Data'
GROUP BY age_group, gender
ORDER BY age_group;

-- Breakdown of employees by location (Remote vs Headquarters)
SELECT location, COUNT(*) AS location_count
FROM h_r
WHERE employee_age >= 18
AND termination_date = 'No Data'
GROUP BY location;

-- Average length of employment
SELECT ROUND(AVG(DATEDIFF(termination_date, date_of_hire))/ 365, 0) AS avg_length_of_employment
FROM h_r
WHERE termination_date <= CURDATE() 
AND termination_date <> 'No Data'
AND employee_age >= 18;

-- Department and gender breakdown
SELECT department, gender, COUNT(*)
FROM h_r
WHERE termination_date = 'No data'
AND employee_age >= 18
GROUP BY department, gender
ORDER BY department;

-- Job title count
SELECT job_title, COUNT(*)
FROM h_r
WHERE employee_age > 18
AND termination_date = 'No Data'
GROUP BY job_title
ORDER BY job_title DESC;

-- Department termination rate
SELECT department, total_count, terminated_count,
terminated_count/total_count AS termination_rate
FROM(
	SELECT department, COUNT(*) AS total_count,
    SUM(CASE
			WHEN termination_date <> 'No Data' 
            AND termination_date <= CURDATE() THEN 1 ELSE 0 END) AS terminated_count
	FROM h_r
    WHERE employee_age > 18 
    GROUP BY department) AS sub_query
ORDER BY termination_rate DESC;

-- Location state count
SELECT location_state, COUNT(*) 
FROM h_r
WHERE employee_age > 18
AND termination_date = 'No Data'
GROUP BY location_state
ORDER BY COUNT(*) DESC;

-- Location city count
SELECT location_city, COUNT(*) 
FROM h_r
WHERE employee_age > 18
AND termination_date = 'No Data'
GROUP BY location_city
ORDER BY COUNT(*) DESC;

-- Yearly net change in employee count
SELECT year, hired, `terminated`,
hired - `terminated` AS net_change, 
ROUND((hired - `terminated`)/ hired * 100, 2) AS net_change_percent
FROM 
	(
	SELECT
		YEAR(date_of_hire) AS year,
        COUNT(*) hired,
        SUM(CASE WHEN termination_date <> 'No Data'
                AND termination_date <= CURDATE() THEN 1 ELSE 0
			END) AS `terminated`
		FROM h_r
        WHERE employee_age > 18
        GROUP BY YEAR(date_of_hire)
        ) AS subq
ORDER BY year ASC;

-- Department tenure
SELECT department,
       YEAR(CURDATE()) - YEAR(date_of_hire) AS tenure_years,
       COUNT(*) AS num_employees
FROM h_r
WHERE employee_age > 18
GROUP BY department, tenure_years
ORDER BY department, tenure_years ASC;

-- Average tenure by department
SELECT department, ROUND(AVG(DATEDIFF(termination_date, date_of_hire)/ 365), 0) AS avg_tenure
FROM h_r
WHERE termination_date <= CURDATE()
AND termination_date <> 'No Data' 
AND employee_age > 18
GROUP BY department;

-- Department and race count
SELECT department, race, COUNT(*)
FROM h_r
WHERE employee_age > 18 
AND termination_date <> 'No data'
GROUP BY department;
