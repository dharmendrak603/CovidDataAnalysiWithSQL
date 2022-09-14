
----Data for Tableau Visualization

---Lets create a View with All countries population, total-case, total deaths and DeathPercentage
DROP VIEW IF EXISTS VW_DeathPercenatge
GO
Create  View VW_DeathPercenatge
AS
Select distinct location,population , SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
---Where location like '%India%'
where continent is not null 
group by location, population

---2. Deaths by Continents

DROP VIEW IF EXISTS VW_DeathContinet
GO
Create  View VW_DeathContinet
AS
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International') and location not like '%income%'
Group by location



---3. Looking at the countries with highest Infection rate compared to Popolation

DROP VIEW IF EXISTS VW_InfectionRate
GO
Create  View VW_InfectionRate
AS
Select location, population,max(total_cases) Maximum_Infection_Count, max(ROUND(((total_cases/population)*100),2)) as Max_Infection_Rate
from PortfolioProject..CovidDeaths 
where continent is not null
group by location, population


---4. Looking at the countries with highest Death rate compared to Popolation

DROP VIEW IF EXISTS VW_DeathRate
GO
Create  View VW_DeathRate
AS
Select location, max(cast(total_deaths as int)) as TotalDeathCount ,population, max(cast(total_deaths as int)/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
group by location,population


-- 5. Contry wise Vaccination Pattern 

DROP VIEW IF EXISTS VW_PopvsVac
GO
Create  View VW_PopvsVac
AS
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


----6. IncomeWise Infection & Death percentage

DROP VIEW IF EXISTS VW_IncomeWiseCovid
GO
Create  View VW_IncomeWiseCovid
AS
Select location, population,max(total_cases) Maximum_Infection_Count, max(ROUND(((total_cases/population)*100),2)) as Max_Infection_Rate,max(cast(total_deaths as int)/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where location like '%income%'
group by location, population