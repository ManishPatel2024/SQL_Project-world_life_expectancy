# World Life Expectancy: Data Cleaning & EDA
This project involves a comprehensive deep dive into global life expectancy trends using MySQL. I focused on two distinct phases: Data Cleaning (to ensure accuracy and consistency) and Exploratory Data Analysis (EDA) (to uncover correlations between socio-economic factors and longevity).

###💡 Key Insights & Findings
* **Top 5** Countries with the highest increase of life expectancy over 15 years. (Number 1 is Haiti with 28.7 years)
* Analysis showed that countries in the 'High' GDP bracket lived an average of **20 years longer** than those in the 'Low' GDP bracket.
* **17%** of Countries are classed as developed and **83%** of Countries are classed as developing.
* Developed Countries have an average life expectancy of **79 years** and Developing countries have an average life expectancy of **67 years**.

### 📁 Dataset Overview
The dataset contains life expectancy data for various countries over a 15-year period, including variables like GDP, Adult Mortality, and status (Developed vs. Developing).

🛠️ Key Technical Skills includes:  
<ins>Data Cleaning:</ins> Removing duplicates using **ROW_NUMBER()**, standardizing text data, and handling missing values using **JOIN** logic.

<ins>EDA:</ins> Aggregating data with **GROUP BY**, calculating year-over-year growth, and analyzing correlations between GDP and Life Expectancy.

<ins>Advanced SQL:</ins> Window Functions and complex Subqueries.



### 🧹 Phase 1: Data Cleaning Highlights
In this phase, I transformed a raw, "dirty" dataset into a reliable source of truth. Key steps included:

Duplicate Removal: Identified and deleted duplicate records by partitioning over Country and Year.

Standardization: Fixed inconsistencies in the 'Status' column (e.g., filling in "Developing" where it was blank based on previous entries).

Null Value Imputation: Populated missing Life Expectancy values by calculating the average of the preceding and succeeding years for that specific country.



### 📊 Phase 2: Exploratory Data Analysis
Once the data was clean, I queried the database to answer critical questions:

Life Expectancy Growth: Which countries saw the most significant improvement over the 15-year period?

GDP Correlation: Is there a strict linear relationship between a nation's wealth and its citizens' lifespan? (Spoiler: Usually, but there are outliers!)

Regional Trends: How do average lifespans compare across different geographic regions?
