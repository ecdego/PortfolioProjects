/*

Queries for 'COVID Data Exploration Tableau Visualization'


Queries from 'SQL Data Exploration' Project by AlexTheAnalyst(https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Tableau%20Portfolio%20Project%20SQL%20Queries.sql)

*changed changed query for # 2, added more comments

*/

-- 1. GLOBAL NUMBERS: total cases, total deaths and death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
From covidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as float))/SUM(New_Cases)*100 as DeathPercentage
-- From covidDeaths
-- --Where location like '%states%'
-- where location = 'World'
-- order by 1,2



-- 2. Total Death Count Per Continent
/* The new data has the following added to locations: 
('High income', 'Low income', 'Lower middle income', 'Upper middle income')

When comparing population of world, population sum of continents, and population sum of the income categories,
the numbers were close. 

Hence, I modified query #2 to be consistent with data used in query #1.


original query:

We take these out as they are not inluded in the above queries and want to stay consistent
European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
*/


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covidDeaths
--Where location like '%states%'
where continent is null
and location in ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')
group by location
order by TotalDeathCount desc


-- shows all locations if continent is null
-- SELECT location
-- FROM covidDeaths
-- WHERE continent is NULL
-- GROUP by location
-- results: Africa, Asia, Europe, European Union, High income, Low income, Lower middle income, North America, Oceania, South America, Upper middle income, World


-- comparing population among groups of location
-- SELECT SUM(population) AS total_population
-- FROM covidDeaths
-- WHERE continent is null AND
-- location IN ('Africa', 'Asia', 'Europe', 'North America', 'Oceania', 'South America')
-- 
-- UNION ALL
-- 
-- SELECT SUM(population) AS total_population
-- FROM covidDeaths
-- WHERE continent is null AND
-- location in  ('World')
-- 
-- UNION ALL
-- 
-- SELECT SUM(population) AS total_population
-- FROM covidDeaths
-- WHERE continent is null AND
-- location IN ('High income', 'Low income', 'Lower middle income', 'Upper middle income')




-- 3. Countries With Highest Infection Rate VS Population

Select Location, Population, MAX(CAST(total_cases AS INT)) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covidDeaths
Group by Location, Population
order by PercentPopulationInfected desc



-- 4. Countries With Highest Infection Rate VS Population OVER TIME

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc