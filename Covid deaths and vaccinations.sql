Select *
From PortfolioProject..CovidDeaths
Order by 3,4

-- Select the data that we will be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

--Total Cases vs Total Deaths in Singapore
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Singapore%'
Order by 1,2

--Total Cases vs Population in Singapore
Select Location, date, total_cases, total_deaths, population, (total_cases/population)*100 as CasePercentage
From PortfolioProject..CovidDeaths
Where location like '%Singapore%'
Order by 1,2

--Countries with the highest infection rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CasePercentage
From PortfolioProject..CovidDeaths
Group by location, population
Order by CasePercentage desc

--Countries with the highest Death Count per Population
Select Location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location, population
Order by HighestDeathCount desc

--Continents with the highest Death Count per Population
Select location, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is NULL
Group by location
Order by HighestDeathCount desc

--Global numbers
Select date, SUM(total_cases) as TotalCases, SUM(total_deaths) as TotalDeaths, SUM(total_deaths)/SUM(total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group By date
Order by 1

--Look at CovidVaccinations table
Select*
From PortfolioProject..CovidVaccinations

--Join CovidDeaths and CovidVaccinations table, looking at total Population vs Vaccinations
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations
From PortfolioProject..CovidVaccinations CV
Join PortfolioProject..CovidDeaths CD
	on CV.location = CD.location
	and CV.date = CD.date
Where CD.continent is not null
Order By 2,3

--Partition the above by Location
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(Convert(int,CV.new_vaccinations)) Over (Partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations CV
Join PortfolioProject..CovidDeaths CD
	on CV.location = CD.location
	and CV.date = CD.date
Where CD.continent is not null
Order By 2,3

--Find total number of poeple vaccinated over total population by location (by using CTE)
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(Convert(int,CV.new_vaccinations)) Over (Partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations CV
Join PortfolioProject..CovidDeaths CD
	on CV.location = CD.location
	and CV.date = CD.date
Where CD.continent is not null
)
Select*, (RollingPeopleVaccinated/population)*100 
From PopvsVac

--Create view (permanent table)
Create view PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, 
SUM(Convert(int,CV.new_vaccinations)) Over (Partition by CD.location Order by CD.location, CD.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations CV
Join PortfolioProject..CovidDeaths CD
	on CV.location = CD.location
	and CV.date = CD.date
Where CD.continent is not null
