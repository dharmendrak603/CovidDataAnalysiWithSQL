--Check the death ratio of covid per country and all

Select * 
from CovidDeaths 
order by 3,4

Select location,date, population,total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) as Death_Ratio_Per_Day
from CovidDeaths 
where location like 'India'
order by 1,2 desc

---Currrent Death ration according to the new cases and new deaths happening daily.

Select location,date, population,new_cases,new_deaths, ROUND(new_deaths/nullif(new_cases,0)*100,2) as Current_Death_Ration
from CovidDeaths 
where location like 'India'
order by 1,2 desc

---Shows how much % of the total population got COVID

Select location,date, population,total_cases, ROUND(((total_cases/population)*100),2) as Infection_Rate
from PortfolioProject..CovidDeaths 
where location like 'India' and continent is not null
order by 1,2


---Looking at the countries with highest Infection rate compared to Popolation

Select location, population,max(total_cases) Maximum_Infection_Count, max(ROUND(((total_cases/population)*100),2)) as Max_Infection_Rate
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population
order by 4 desc


---Looking at the countries with highest Infection rate compared to Popolation

Select location, max(cast(total_deaths as int)) as TotalDeathCount ,population, max(cast(total_deaths as int)/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
group by location,population
order by TotalDeathCount desc




select *
from PortfolioProject.dbo.CovidDeaths


---LETS BREAK THING DOWN BY CONTINENT

Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc
=========================================

select location ,max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent is null
group by location 
order by 2 desc






---------GLOBAL DNUMBERS
select  sum(new_cases) as ToatalCases, SUM(cast(new_deaths as int)) TotalDeaths, SUM(cast(new_deaths as int))/NULLIF(sum(new_cases),0)*100 as SeathPercenatage
from PortfolioProject..CovidDeaths
---group by date
order by 4 desc


--------Population Table
---Looking at total vaccination vs Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
,(RollingPeopleVaccinated/dea.population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


-----USE CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/dea.population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null
--order by 2,3
)
Select *,
	CASE 
		WHEN population > RollingPeopleVaccinated THEN ((RollingPeopleVaccinated/population)*100 ) 
END as First_Dose,
	CASE 
		WHEN population < (RollingPeopleVaccinated) and (RollingPeopleVaccinated) < (2*population) THEN ((RollingPeopleVaccinated/population)*100 -100 )
END as Second_Dose,
	CASE 
		WHEN (RollingPeopleVaccinated) > (2*population) THEN ((RollingPeopleVaccinated/population)*100 -200 ) 
END as Third_Dose

from PopvsVac
where location='Austria'




----Let's do the same thing with the help of "CREATING A TEMP"

Drop table if Exists #VaccinatedPercenatge
Create table #VaccinatedPercenatge
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into  #VaccinatedPercenatge
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/dea.population)*100
from portfolioProject..CovidDeaths dea
join portfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 

---SELCTING FROM THE ABOVE TEMP TABLE
Select *,
	CASE 
		WHEN population > RollingPeopleVaccinated THEN ((RollingPeopleVaccinated/population)*100 ) 
END as First_Dose,
	CASE 
		WHEN population < (RollingPeopleVaccinated) and (RollingPeopleVaccinated) < (2*population) THEN ((RollingPeopleVaccinated/population)*100 -100 )
END as Second_Dose,
	CASE 
		WHEN (RollingPeopleVaccinated) > (2*population) THEN ((RollingPeopleVaccinated/population)*100 -200 ) 
END as Third_Dose
from #VaccinatedPercenatge
where location='Austria'
--order by 2,3


-----Creating Views to store data for later Visualization


---As we cannot create a  view from TEMP tables so let's create a static table from this temp table.

SELECT * 
INTO Tbl_VaccinatedPercenatge
from  #VaccinatedPercenatge






-------------------------------------------------------

DROP VIEW IF EXISTS VW_VaccinatedPercenatge
GO
Create  View VW_VaccinatedPercenatge
AS
Select *,
	CASE 
		WHEN population > RollingPeopleVaccinated THEN ((RollingPeopleVaccinated/population)*100 ) 
END as First_Dose,
	CASE 
		WHEN population < (RollingPeopleVaccinated) and (RollingPeopleVaccinated) < (2*population) THEN ((RollingPeopleVaccinated/population)*100 -100 )
END as Second_Dose,
	CASE 
		WHEN (RollingPeopleVaccinated) > (2*population) THEN ((RollingPeopleVaccinated/population)*100 -200 ) 
END as Third_Dose
from Tbl_VaccinatedPercenatge
where location='Austria'


SELECT * FROM VW_VaccinatedPercenatge

