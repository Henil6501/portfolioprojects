select *
from Coviddeaths
order by 3,4

--select *
--from Covidvaccinations
--order by 3,4

-- select data that we are going to be using.

select location, date, total_cases , new_cases, total_deaths, population
from Coviddeaths
order by 1,2

-- Looking at the total cases vs total deaths.
-- Showing likelihood of dying if you contract covid in your counrty.

 select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from Coviddeaths
where location like '%states%'
order by 1,2

-- Looking at the totalcases vs totalpopulation.
-- Shows what percentage of population got Covid.
 select location, date, total_cases ,population, (total_cases/population)*100 as Effectedpercentage 
from Coviddeaths
where location like '%india%'
order by 1,2

--for australia..
 select location, date,population, total_cases , (total_cases/population)*100 as Effectedpercentage 
from Coviddeaths
where location like '%australia%'
order by 1,2

-- For all over the world.
 select location, date,population, total_cases , (total_cases/population)*100 as Infectionpercentage 
from Coviddeaths
order by 1,2

-- Looking at countries with the highest infrction rate compared to population.
 select location,population, max(total_cases) as Highestinfectionrate , max((total_cases/population))*100 as Effectedpercentage 
from Coviddeaths
group by location, population
order by 1,2

 select location,population, max(total_cases) as Highestinfectionrate , max((total_cases/population))*100 as Effectedpercentage 
from Coviddeaths
group by location, population
order by Effectedpercentage desc

--Showing the countries with the highest death count per population.
 select location,population, max(cast (total_deaths as int)) as TotalDeaths
 from Coviddeaths
 where  continent is not null
group by location, population
order by TotalDeaths desc

-- Let's break things down by continent.
 
  select continent, max(cast (total_deaths as int)) as TotalDeaths
 from Coviddeaths
 where  continent is not null
group by continent
order by TotalDeaths desc

-- showing the continent with the highest deathcount per population.
  select continent, max(cast (total_deaths as int)) as TotalDeaths
 from Coviddeaths
 where  continent is not null
group by continent
order by TotalDeaths desc

 --Global numbers
 select  date,sum( new_cases)as Totalcases , sum(cast(new_deaths as	int))as Total_deaths,sum(cast(new_deaths as int))/sum (new_cases)*100 as Deathpercentage 
from Coviddeaths
where continent is not null
group by date
order by 1,2

select sum( new_cases)as Totalcases , sum(cast(new_deaths as	int))as Total_deaths,sum(cast(new_deaths as int))/sum (new_cases)*100 as Deathpercentage 
from Coviddeaths
where continent is not null
order by 1,2


-- Looking at total population vs total vaccination.
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Coviddeaths dea
join Covidvaccinations vac
  on dea.location = vac.location 
  and dea.date = vac.date 
where dea.continent is not null
order by 2,3

SELECT 
    dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
    SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS RollingPeopleVaccinated
FROM Coviddeaths dea
JOIN Covidvaccinations vac
  ON dea.location = vac.location 
 and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3 -- Order by the second and third columns (location and date)

-- using CTEs
 
with popvsvac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Coviddeaths dea
JOIN Covidvaccinations vac
  ON dea.location = vac.location 
 and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3 -- Order by the second and third columns (location and date)
)
select *
from popvsvac

--Temp table
drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(255)	,
location nvarchar (255),
date datetime,
population numeric,
new_vaccination numeric,
 RollingPeopleVaccinated numeric
 )

 insert into  #percentagepopulationvaccinated
 SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Coviddeaths dea
JOIN Covidvaccinations vac
  ON dea.location = vac.location 
 and dea.date = vac.date 
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3 -- Order by the second and third columns (location and date)

select *, (RollingPeopleVaccinated/population)*100
from #percentagepopulationvaccinated

-- Creating view to store data for later visulizations

create view percentpopulationvaccinated as 
SELECT  dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Coviddeaths dea
JOIN Covidvaccinations vac
  ON dea.location = vac.location 
 and dea.date = vac.date 
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3 -- Order by the second and third columns (location and date)
