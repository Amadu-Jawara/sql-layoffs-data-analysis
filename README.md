# SQL Layoffs Data Cleaning and Analysis Project

## Project Overview

This project analyzes global layoffs data using SQL and Excel. The main objective is to clean a raw layoffs dataset, fix data quality issues, prepare analysis-ready tables, and generate insights on layoffs by company, industry, country, year, month, funding stage, and company funding level.

## Dashboard
<img width="1081" height="546" alt="image" src="https://github.com/user-attachments/assets/55eb5910-79c6-4d4d-9d18-734dadc49af0" />


The project follows a professional data analysis workflow:

1. Data import
2. Data inspection
3. Data cleaning
4. Duplicate removal
5. Data standardization
6. Date correction
7. Exploratory data analysis
8. Dashboard preparation in Excel

## Tools Used

- MySQL Workbench
- SQL
- Microsoft Excel
- GitHub

## Dataset

The dataset contains information on layoffs across different companies, industries, countries, funding stages, dates, and funding amounts.

Main columns include:

- company
- location
- industry
- total_laid_off
- percentage_laid_off
- date
- stage
- country
- funds_raised_millions

## Key Cleaning Steps

The SQL cleaning process included:

- Created a raw table for the original dataset
- Created staging tables to protect the original data
- Removed duplicate records using `ROW_NUMBER()`
- Standardized industry names, especially Crypto-related values
- Fixed country names such as `United States.`
- Converted blank values into proper SQL `NULL` values
- Corrected the date column to prevent year and month values from showing as `NULL`
- Removed rows where both total layoffs and percentage layoffs were missing
- Created a final cleaned table for analysis

## Important Date Fix

A major issue in the project was that the year and month values initially showed as `NULL`.

This was fixed by creating a proper date column and converting the raw text date using the correct MySQL date format.

```sql
STR_TO_DATE(TRIM(`date`), '%c/%e/%Y')
