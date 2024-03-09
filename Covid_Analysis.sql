-- Viewing the databases
SELECT * FROM covid.coviddeaths;
SELECT * FROM covid.covidvaccinations;

SELECT location, total_cases, new_cases, total_deaths, population
FROM covid.coviddeaths
ORDER BY 1 AND 2;

-- Looking at total cases VS total deaths
SELECT location, total_cases, date, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM covid.coviddeaths
ORDER BY 1 AND 2;

-- Likelihood you die from covid in India
SELECT location, total_cases, date, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM covid.coviddeaths
WHERE location LIKE 'India'
ORDER BY 1 AND 2;


-- Looking at Total case VS Population
-- Percentage of people who got covid
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS InfectedPercentage
FROM covid.coviddeaths
ORDER BY 1 AND 2;


-- Showing Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100,2)) AS InfectedPercentage
FROM covid.coviddeaths
GROUP BY location, population
ORDER BY InfectedPercentage DESC;

-- Highest number of deaths
SELECT location, MAX(cast(total_deaths as DOUBLE)) Total_Death_Count
FROM covid.coviddeaths
WHERE continent != ''
GROUP BY location
ORDER BY Total_Death_Count DESC;



-- Grouping by continent 
SELECT continent, MAX(cast(total_deaths as DOUBLE)) Total_Death_Count
FROM covid.coviddeaths
WHERE continent != ''
GROUP BY continent
ORDER BY Total_Death_Count DESC;


-- New Covid Cases on each day
SELECT date, sum(new_cases) AS Total_New_Cases, sum(new_deaths) AS Total_New_Deaths, 
round((sum(new_deaths)/sum(new_cases))* 100,2) AS Death_Percentage
FROM covid.coviddeaths
WHERE continent !=''
GROUP BY date
ORDER BY cast(date AS date);


-- Joining tables coviddeaths and covidvaccination tables on location and date

SELECT *
FROM covid.coviddeaths AS d
JOIN covid.covidvaccinations AS c
	ON d.location = c.location
    AND d.date = c.date;
    
    
-- Looking at Total population VS vaccination
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations
FROM covid.coviddeaths AS d
JOIN covid.covidvaccinations AS c
	ON d.location = c.location
    AND d.date = c.date
WHERE d.continent != ''
ORDER BY 2,3;

-- Rolling count 
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations, SUM(c.new_vaccinations) OVER (PARTITION BY c.location ORDER BY d.location and CAST(d.date AS DATE)) AS Rolling_People_Vaccinated
FROM covid.coviddeaths AS d
JOIN covid.covidvaccinations AS c
	ON d.location = c.location
    AND d.date = c.date
WHERE d.continent != ''
ORDER BY 2 and 3 ;

-- CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations, SUM(c.new_vaccinations) OVER (PARTITION BY c.location ORDER BY d.location and CAST(d.date AS DATE)) AS Rolling_People_Vaccinated
FROM covid.coviddeaths AS d
JOIN covid.covidvaccinations AS c
	ON d.location = c.location
    AND d.date = c.date
WHERE d.continent != ''

)
SELECT *, (Rolling_People_Vaccinated/population)*100  FROM PopVsVac;



-- TEMP TABLE
DROP TABLE IF EXISTS PercentPopulationVaccinated;
USE covid;
CREATE TABLE PercentPopulationVaccinated 
(
continent char(255),
location char(255),
date char(255),
population numeric,
new_vaccinations char(255),
Rolling_People_Vaccinated int );

INSERT INTO PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations, SUM(c.new_vaccinations) OVER (PARTITION BY c.location ORDER BY d.location and CAST(d.date AS DATE)) AS Rolling_People_Vaccinated
FROM covid.coviddeaths AS d
JOIN covid.covidvaccinations AS c
	ON d.location = c.location
    AND d.date = c.date
WHERE d.continent != '';

SELECT *, (Rolling_People_Vaccinated/population)*100  FROM PercentPopulationVaccinated;


-- Create View to store for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, c.new_vaccinations, SUM(c.new_vaccinations) OVER (PARTITION BY c.location ORDER BY d.location and CAST(d.date AS DATE)) AS Rolling_People_Vaccinated
FROM covid.coviddeaths AS d
JOIN covid.covidvaccinations AS c
	ON d.location = c.location
    AND d.date = c.date
WHERE d.continent != '';