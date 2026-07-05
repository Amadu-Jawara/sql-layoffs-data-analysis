
-- PROJECT: Layoffs Data Cleaning and Analysis in MySQL
-- AUTHOR: Amadu Jawara
-- TOOL: MySQL Workbench
-- DATASET: layoffs.csv
-- PURPOSE: Clean the dataset and analyze global layoffs


USE layoffs_project;

SELECT *
FROM layoffs;

SELECT *
FROM layoffs
LIMIT 10;

DESCRIBE layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT COUNT(*) AS staging_rows
FROM layoffs_staging;

SELECT 
    (SELECT COUNT(*) FROM layoffs) AS raw_table_rows,
    (SELECT COUNT(*) FROM layoffs_staging) AS staging_table_rows;
    
    SELECT 
    company,
    industry,
    total_laid_off,
    `date`,
    ROW_NUMBER() OVER (
        PARTITION BY company, industry, total_laid_off, `date`
    ) AS row_num
FROM layoffs_staging;

SELECT *
FROM (
    SELECT 
        company,
        industry,
        total_laid_off,
        `date`,
        ROW_NUMBER() OVER (
            PARTITION BY company, industry, total_laid_off, `date`
        ) AS row_num
    FROM layoffs_staging
) AS duplicate_check
WHERE row_num > 1;

SELECT *
FROM (
    SELECT 
        company,
        location,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions,
        ROW_NUMBER() OVER (
            PARTITION BY 
                company,
                location,
                industry,
                total_laid_off,
                percentage_laid_off,
                `date`,
                stage,
                country,
                funds_raised_millions
        ) AS row_num
    FROM layoffs_staging
) AS duplicate_check
WHERE row_num > 1;

CREATE TABLE layoffs_staging2 (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT NULL,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT NULL,
    row_num INT
);

INSERT INTO layoffs_staging2
SELECT 
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY 
            company,
            location,
            industry,
            total_laid_off,
            percentage_laid_off,
            `date`,
            stage,
            country,
            funds_raised_millions
    ) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


SET SQL_SAFE_UPDATES = 0;

DELETE FROM layoffs_staging2 WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;


SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = ''
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
ORDER BY company;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;
SET SQL_SAFE_UPDATES = 1;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
ORDER BY company;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');
SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);
SET SQL_SAFE_UPDATES = 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

SELECT `date`
FROM layoffs_staging2
LIMIT 20;

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SET SQL_SAFE_UPDATES = 0;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE funds_raised_millions IS NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  
  DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  
  ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2
LIMIT 20;

CREATE TABLE layoffs_clean AS
SELECT *
FROM layoffs_staging2;

SELECT COUNT(*) AS final_clean_rows
FROM layoffs_clean;

DESCRIBE layoffs_clean;

SELECT 
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean;

SELECT 
    company,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

SELECT 
    industry,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY total_layoffs DESC;

SELECT 
    country,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY country
ORDER BY total_layoffs DESC;

SELECT 
    YEAR(`date`) AS layoff_year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
WHERE `date` IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY layoff_year;

SELECT 
    DATE_FORMAT(`date`, '%Y-%m') AS layoff_month,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_clean
WHERE `date` IS NOT NULL
  AND total_laid_off IS NOT NULL
GROUP BY DATE_FORMAT(`date`, '%Y-%m')
ORDER BY layoff_month;

SELECT 
    company,
    location,
    industry,
    country,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage
FROM layoffs_clean
WHERE percentage_laid_off = '1'
ORDER BY total_laid_off DESC;

SELECT 
    company,
    COUNT(*) AS number_of_layoff_events,
    SUM(total_laid_off) AS total_layoffs,
    MIN(`date`) AS first_layoff_date,
    MAX(`date`) AS latest_layoff_date
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY total_layoffs DESC;

WITH monthly_layoffs AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS layoff_month,
        SUM(total_laid_off) AS monthly_layoffs
    FROM layoffs_clean
    WHERE `date` IS NOT NULL
      AND total_laid_off IS NOT NULL
    GROUP BY DATE_FORMAT(`date`, '%Y-%m')
)
SELECT 
    layoff_month,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER (
        ORDER BY layoff_month
    ) AS rolling_total_layoffs
FROM monthly_layoffs
ORDER BY layoff_month;

WITH company_year AS (
    SELECT 
        YEAR(`date`) AS layoff_year,
        company,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_clean
    WHERE `date` IS NOT NULL
      AND total_laid_off IS NOT NULL
    GROUP BY YEAR(`date`), company
),
ranked_companies AS (
    SELECT 
        layoff_year,
        company,
        total_layoffs,
        DENSE_RANK() OVER (
            PARTITION BY layoff_year
            ORDER BY total_layoffs DESC
        ) AS company_rank
    FROM company_year
)
SELECT 
    layoff_year,
    company,
    total_layoffs,
    company_rank
FROM ranked_companies
WHERE company_rank <= 5
ORDER BY layoff_year, company_rank;

WITH industry_totals AS (
    SELECT 
        industry,
        SUM(total_laid_off) AS industry_layoffs
    FROM layoffs_clean
    WHERE total_laid_off IS NOT NULL
    GROUP BY industry
)
SELECT 
    industry,
    industry_layoffs,
    ROUND(
        100 * industry_layoffs / SUM(industry_layoffs) OVER (), 
        2
    ) AS percentage_share
FROM industry_totals
ORDER BY industry_layoffs DESC;

SELECT 
    stage,
    COUNT(*) AS number_of_events,
    SUM(total_laid_off) AS total_layoffs,
    ROUND(AVG(total_laid_off), 2) AS average_layoffs_per_event
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY stage
ORDER BY total_layoffs DESC;

SELECT 
    CASE 
        WHEN funds_raised_millions IS NULL THEN 'Unknown funding'
        WHEN funds_raised_millions < 50 THEN 'Less than $50m'
        WHEN funds_raised_millions BETWEEN 50 AND 199 THEN '$50m - $199m'
        WHEN funds_raised_millions BETWEEN 200 AND 999 THEN '$200m - $999m'
        ELSE '$1bn or more'
    END AS funding_group,
    COUNT(*) AS number_of_events,
    SUM(total_laid_off) AS total_layoffs,
    ROUND(AVG(total_laid_off), 2) AS average_layoffs_per_event
FROM layoffs_clean
WHERE total_laid_off IS NOT NULL
GROUP BY funding_group
ORDER BY total_layoffs DESC;



