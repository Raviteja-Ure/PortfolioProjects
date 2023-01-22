select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select*
from PortfolioProject..CovidVaccinations
order by 3,4

--select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total cases vs Total deaths
--Shows likelihood of dying if you get in contact with your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population was infected by Covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2


--Looking at countries with highest infection rate compared to population
select location, population, Max(Total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as InfectionRate
from PortfolioProject..CovidDeaths
Group by location, population
order by InfectionRate desc

--showing countries with highest death count per population
select location,  Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as TotalDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing Continents with highest death count per population
select continent, Max(cast(total_deaths as int)) as TotalDeathCount, Max((total_deaths/population))*100 as TotalDeathRate
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS FOR NEW CASES AND NEW DEATHS

select SUM(new_cases) as totalnewcases, sum(cast(new_deaths as int)) as totalnewdeaths,sum(cast(new_deaths as int))/SUM(new_cases)*100 as newDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by continent
order by 1,2	


-- GLOBAL NUMBERS FOR TOTAL CASES AND TOTAL DEATHS as per CONTINENT WISE	

select continent, SUM(total_cases) as Allcases, SUM(cast(total_deaths as int)) as Alldeaths, SUM(cast(total_deaths as int))/SUM(total_cases)*100 as CompleteDeathrate
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by 1,2


-- GLOBAL NUMBERS FOR TOTAL CASES AND TOTAL DEATHS as a whole world
select SUM(total_cases) as Allcases, SUM(cast(total_deaths as int)) as Alldeaths
from PortfolioProject..CovidDeaths
where continent is not null
--Group by continent



--JOINING THE 2 DATASETS DEATHS AND VACCINATIONS

select*
from PortfolioProject..CovidDeaths Deaths
join PortfolioProject..CovidVaccinations vaccine
on Deaths.location = vaccine.location and Deaths.date = vaccine.date

--LOOKING AT TOTAL POPULATION VS VACCINATIONS
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vaccine.new_vaccinations
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations vaccine
on Deaths.location = vaccine.location and Deaths.date = vaccine.date
where Deaths.continent is not null
Order by 1,2,3

--ADD NEW_VACCINATIONS AND PARTITION BY LOCATION
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER(Partition by Deaths.location order by  Deaths.location, Deaths.date) as totalnewvaccines
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations vaccine
  on Deaths.location = vaccine.location and Deaths.date = vaccine.date
where Deaths.continent is not null
Order by 2,3

--USE CTE

With PopVsVac (continent, location, date, population, new_vaccinations, totalnewvaccines)
as
(
select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations AS bigint)) OVER(Partition by Deaths.location order by  Deaths.location, Deaths.date) as totalnewvaccines
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations vaccine
  on Deaths.location = vaccine.location and Deaths.date = vaccine.date
where Deaths.continent is not null
--Order by 2,3
)
select*, (totalnewvaccines/population)*100 as vaccinationrate
from PopVsVac

--TEMP TABLE--------------

DROP TABLE if exists #PercentPopulationVaccination
Create Table #PercentPopulationVaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalnewvaccines numeric
)
Insert into #PercentPopulationVaccination
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations AS bigint)) OVER(Partition by Deaths.location order by  Deaths.location, Deaths.date) as totalnewvaccines
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations vaccine
  on Deaths.location = vaccine.location and Deaths.date = vaccine.date
--where Deaths.continent is not null
--Order by 2,3

select*, (totalnewvaccines/population)*100 as vaccinationrate
from #PercentPopulationVaccination


------CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS-----------

create view PercentPopulationVaccination as
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, vaccine.new_vaccinations
, SUM(CAST(vaccine.new_vaccinations AS bigint)) OVER(Partition by Deaths.location order by  Deaths.location, Deaths.date) as totalnewvaccines
from PortfolioProject..CovidDeaths Deaths
Join PortfolioProject..CovidVaccinations vaccine
  on Deaths.location = vaccine.location and Deaths.date = vaccine.date
where Deaths.continent is not null
--Order by 2,3

select*
from PercentPopulationVaccination