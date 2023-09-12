/*
COVID 19 DATA EXPLORATION

Skills used: Updating and Altering Table, Joins, CTE's, Window Functions, Aggregate Functions, Creating Views, Converting Data Types

Data from https://ourworldindata.org/covid-deaths (Retrieved in Aug. 2023)

Project adopted from Alex The Analyst (https://youtu.be/qfyynHBFOsM?si=j75PGsA4jQtw3yxp)

*/


-- preview tables
SELECT *
FROM covidDeaths
ORDER BY 3, 4
LIMIT 5

SELECT *
FROM covidVaccinations
--ORDER BY 3, 4
LIMIT 5




-- CHANGE DATE FORMAT FOR BOTH TABLES
-- creating new date_cleaned column
ALTER TABLE covidDeaths
ADD date_cleaned INTEGER

-- modifying date column to take proper format of date
UPDATE covidDeaths
SET date_cleaned = SUBSTR(date, 7, 4) || '-' || SUBSTR(date, 4, 2) || '-' || SUBSTR(date, 1, 2)

-- dropping original date column
ALTER TABLE covidDeaths
DROP COLUMN date

-- making new date_cleaned into 'date' column
ALTER TABLE covidDeaths
RENAME COLUMN date_cleaned TO date

-- same process for the covidVaccinations table
ALTER TABLE covidVaccinations
ADD date_cleaned INTEGER

UPDATE covidVaccinations
SET date_cleaned = SUBSTR(date, 7, 4) || '-' || SUBSTR(date, 4, 2) || '-' || SUBSTR(date, 1, 2)

ALTER TABLE covidVaccinations
DROP COLUMN date

ALTER TABLE covidVaccinations
RENAME COLUMN date_cleaned TO date



-- change data type of total_cases and total_deaths columns from TEXT to INTEGER
UPDATE covidDeaths
SET total_cases = CAST(total_cases AS FLOAT)
	
	

	
-- Select data to be use
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidDeaths
order by 1, 2



-- total cases vs total deaths
-- likelihood of dying when infected by COVID in the PH
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS deathPercentage
FROM covidDeaths
WHERE location = 'Philippines'
ORDER BY 2 DESC

-- total cases vs population
-- percentage of population affected by COVID in PH
SELECT location, date, total_cases, population, (total_cases/population) * 100 AS percentPopulationInfected
FROM covidDeaths
WHERE location = 'Philippines'
ORDER BY 1, 2 DESC

-- countries with highest infection rate vs population
SELECT location, population, MAX(CAST(total_cases AS FLOAT)) as HighestInfectionCount,
MAX((total_cases/population) * 100) AS percentPopulationInfected
FROM covidDeaths
GROUP BY 1, 2
ORDER BY 4 DESC

-- countries with highest death count
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC




-- GLOBAL NUMBERS

-- highest death count per continent

-- changed query because inaccurate
-- original query:
-- SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
-- FROM covidDeaths
-- WHERE continent IS NOT NULL
-- GROUP BY 1
-- ORDER BY 2 DESC

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From covidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- total cases, total deaths & deaths percentage PER DAY
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100
AS deathPercentage
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 1 DESC

-- total cases, total deaths & deaths percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100
AS deathPercentage
FROM covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1




-- USING covidVaccinations table
-- preview of joined tables
SELECT *
FROM covidDeaths dea
JOIN covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
LIMIT 5


-- total population vs vaccinations
-- shows the rolling sum of vaccinations each day
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- GLOBAL NUMBERS: total population, covid vaccines administered
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.location = 'World'
ORDER BY 2 DESC

-- using CTE to calculate ROLLING percentage of population that received vaccination
With popVsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3
)
SELECT *, (rollingPeopleVaccinated/CAST(Population AS FLOAT))*100 AS rollingPercentageVaccinated
FROM popVsVac


-- using Temp Table to perform calculation on Partition By in previous QUERY
DROP Table if exists PercentPopulationVaccinated

Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From covidDeaths dea
Join covidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- creating view to store data for later visualizations
CREATE VIEW rollingPercentageVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as INT)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVaccinated
FROM covidDeaths dea
JOIN covidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


--end--