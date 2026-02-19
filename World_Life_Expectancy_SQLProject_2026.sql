#SQL Project for using the World_Life_Expectancy dataset

#Objective 1: Standardise and validate data integrity
#Objective 2: EDA of health trends
#Objective 3: Correlation and insights


#The following queries are to meet Objective 1
#Review dataset as a whole. Scroll through some of the records to review anything that may be erroroneous. 
SELECT * 
FROM world_life_expectancy_2
;

#Find duplicates by concatenating the Country column with the year column. There should be only a single instance of a country and a year.
SELECT * 
FROM (
	SELECT Row_ID, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year) ) AS row_num
	FROM world_life_expectancy_2
    ) AS row_table
WHERE row_num > 1
	;

#The above query has found 3 x duplicates (Ireland2022, Senegal2009 and Zimbabwe2019)

#Deleting the duplicates
DELETE FROM world_life_expectancy_2
WHERE Row_ID IN (
	SELECT Row_ID
		FROM (
			SELECT Row_ID, 
			CONCAT(Country, Year),
			ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year) ) AS Row_Num
			FROM world_life_expectancy_2
			) AS Row_Table
WHERE Row_Num > 1
)
;

#Double checking that duplicates have been removed by running this query again
SELECT * 
FROM (
	SELECT Row_ID, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year) ) AS row_num
	FROM world_life_expectancy_2
    ) AS row_table
WHERE row_num > 1
	;

#Returning to overview of data. I can see there are blank values in the Status column
SELECT * 
FROM world_life_expectancy_2
;

#Seeing how many blank cells are in the Status column
SELECT *
FROM world_life_expectancy_2
WHERE Status = ''
;

#If there are blank values, I am checking if there are an NULL values. 
SELECT COUNT(Status)
FROM world_life_expectancy_2
WHERE Status IS NULL
;

#Joining the table to itself. Find the missing information by looking at what we already know about that country. We're telling MySQL to look at the table twice at the same time. t1 is the working table and t2 is the reference table.
UPDATE world_life_expectancy_2 t1
JOIN world_life_expectancy_2 t2
	ON t1.Country = t2.Country
#Set the status of the column to Developing
SET t1.Status = 'Developing'
#Identifying which ones are blank in t1
WHERE t1.Status = ''
#AND the T2.STATUS that are not blank
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

#Using the same query as above but changing 'Developing' to 'Developed
UPDATE world_life_expectancy_2 t1
JOIN world_life_expectancy_2 t2
	ON t1.Country = t2.Country
#Set the status of the column to Developing
SET t1.Status = 'Developed'
#Identifying which ones are blank in t1
WHERE t1.Status = ''
#AND the T2.STATUS that are not blank
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

SELECT * 
FROM world_life_expectancy_2
;


#I've seen a couple of blanks in the life expectancy column. Seems to be only 2; 'Afghanistan' and 'Albania'
SELECT *
FROM world_life_expectancy_2
WHERE `Life expectancy` = ''
;

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy_2
WHERE `Life expectancy` = ''
;

#I'm choosing to fill those blanks with an average of the previous and the following year. 

#Below code to create two other tables that have Year+1 and Year-1 so that we can have Life Expectancy numbers that we can use to calculate the average.
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) AS Mean
FROM world_life_expectancy_2 t1
JOIN world_life_expectancy_2 t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy_2 t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

#Update column so there's no blanks.
UPDATE world_life_expectancy_2 t1
JOIN world_life_expectancy_2 t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy_2 t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;


SELECT * 
FROM world_life_expectancy_2
;


#The following queries are to meet Objective 2: EDA of health trends
#Calculate the total increase in life expectancy per country over the 15 year period

SELECT Country, 
MIN(`Life expectancy`) AS Min_Life_Exp, 
MAX(`Life expectancy`) AS Max_Life_Exp,
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_increase_over_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) != 0
AND MAX(`Life expectancy`) != 0
ORDER BY Life_increase_over_15_years ASC
;

#Identifying top 5 Countries with highest increase of life expectancy using a CTE. 

WITH Life_Increase_Table AS (
	SELECT Country, 
	MIN(`Life expectancy`) AS Min_Life_Exp, 
	MAX(`Life expectancy`) AS Max_Life_Exp,
	ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_increase_over_15_years
	FROM world_life_expectancy
	GROUP BY Country
	HAVING MIN(`Life expectancy`) != 0
	AND MAX(`Life expectancy`) != 0
)
SELECT *,
RANK() OVER(ORDER BY Life_increase_over_15_years DESC) AS Increase_Rank
FROM Life_Increase_Table
LIMIT 5;


SELECT Country, 
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy_2
#WHERE Country LIKE '%United%'
;

#Creating a rolling average of life expectancy to smooth out the anomalies, removing any jagged peaks or troughs.
SELECT Country, 
Year,
`Life expectancy`,
ROUND(AVG(`Life expectancy`) OVER(PARTITION BY Country ORDER BY Year),1) AS Rolling_Average
FROM world_life_expectancy_2
#WHERE Country LIKE '%Britain%'
;



#Objective 3: Correlation and insights
#Create conditional buckets to categorise countries into Low, Medium and High GDPS. Compare the average life expectancy and compare to these buckets. 

SELECT 
    Country,
    Status,
    AVG(GDP) AS Avg_GDP,
    CASE 
        WHEN AVG(GDP) > 12000 THEN 'High'
        WHEN AVG(GDP) BETWEEN 1500 AND 12000 THEN 'Medium'
        ELSE 'Low'
    END AS GDP_Bucket,
    ROUND(AVG(`Life expectancy`), 2) AS Avg_Life_Exp
FROM world_life_expectancy_2
WHERE GDP > 0 
  AND `Life expectancy` > 0
GROUP BY Country, Status
ORDER BY Avg_Life_Exp DESC;


#I wanted to find out how many years longer, on average, does someone live up to in a Low GDP Country vs a High GDP Country.
WITH Country_Averages AS (
    SELECT 
        Country,
        AVG(GDP) AS Avg_GDP,
        AVG(`Life expectancy`) AS Avg_Life_Exp
    FROM world_life_expectancy_2
    WHERE GDP > 0 AND `Life expectancy` > 0
    GROUP BY Country
)
SELECT 
    CASE 
        WHEN Avg_GDP > 12000 THEN 'High'
        WHEN Avg_GDP BETWEEN 1500 AND 12000 THEN 'Medium'
        ELSE 'Low'
    END AS GDP_Bucket,
    ROUND(AVG(Avg_Life_Exp), 2) AS Final_Avg_Life_Exp,
    COUNT(Country) AS Country_Count
FROM Country_Averages
GROUP BY GDP_Bucket
ORDER BY Final_Avg_Life_Exp DESC;

SELECT * 
FROM world_life_expectancy_2
;

#Life expectancy based on status
SELECT status, ROUND(AVG(`Life expectancy`), 1)
FROM world_life_expectancy_2
GROUP BY Status
;

#I wanted to find out the percentage of countries that are classed as 'Developed' vs countries that are classed as 'Developing and find out the average lif expectancy of those countries.
SELECT status, COUNT(DISTINCT Country), COUNT(DISTINCT Country)/ 193 AS Perc, ROUND(AVG(`Life expectancy`), 1) 
FROM world_life_expectancy
GROUP BY Status
;

