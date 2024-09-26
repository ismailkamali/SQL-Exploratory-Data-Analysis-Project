-- EXPLOARATORY DATA ANALYSIS PROJECT by Ismail Kamali
-- I will be using my cleaned data from my previous project to perfom exploratory data analysis

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; #Here we are just investigating the layoff metrics

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER by total_laid_off DESC; #Now we are investigating companies that went completely under and laid off all of their staff

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 desc; #Since there are multiple different branches of a company, we investigate the sum of the total laid off column

SELECT *
FROM layoffs_staging2
WHERE company = 'Amazon'; #An example to illustrate why we done the previous block of code

SELECT MIN(`date`),MAX(`date`)
FROM layoffs_staging2; #Investigating the date ranges

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by industry
ORDER BY 2 desc; #Investigating the total laid off for each industry

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP by country
ORDER BY 2 desc; #Investigating the total laid off for each country

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP by YEAR(`date`)
ORDER BY 2 desc; #Investigating the total laid off for each year, sort of like a time series

SELECT industry, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP by industry
ORDER BY 2 desc; #Investigating the average % laid off for each industry

SELECT substring(`date`,1,7) as `YYYY-MM`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT null
GROUP BY `YYYY-MM`
ORDER BY 1; #Here we manipulate the date column to extract the year and month only and group by this

SELECT *
FROM layoffs_staging2
WHERE `date` is NULL; #THIS IS WHY THERE'S A NULL VALUE

#Lets create a rolling total
WITH Rolling_Total AS
(
SELECT substring(`date`,1,7) as `YYYY-MM`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT null
GROUP BY `YYYY-MM`
ORDER BY 1
)
SELECT `YYYY-MM`, total_off, SUM(total_off) OVER(ORDER BY `YYYY-MM`) rolling_total
FROM Rolling_Total; #We use a CTE for this where the sum of 'total_off' is added on in order of date
#We can see the progression of people laid off to give more context to our people laid off per year

#Now lets see how many people were laid off for each company per year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company;

#Now lets rank each year for each company
WITH company_year_off as
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS sum_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY sum_laid_off desc) AS yearly_ranking
FROM company_year_off
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE yearly_ranking <=5;
#We have used a double CTE, the first to dense_rank every companys lay offs per year and the second so I can see the top 5 companies for each year
#So we used the first CTE in the second CTE