select * 
from portfolio..CovidDeaths
where continent is not null

--importent columns (country)
select continent , location,date,population,total_cases,new_cases,total_deaths
from portfolio..CovidDeaths
where continent is not null

--importent columns (continent)
select continent , location,date,population,total_cases,new_cases,total_deaths
from portfolio..CovidDeaths
where continent is null

                         --country data

--death percentage ( total_deaths/total_cases*100)
-- show likely hood of dying due to covid
select location,date,total_cases,total_deaths ,
case
 when total_deaths is null then '0%'
  else 
  concat(round(( total_deaths/total_cases)*100,2),'%') 
  end as death_percentage
from portfolio..CovidDeaths
where continent is not null


--percent of population infected 
-- show likely hood of you got infected
select location,date,population,total_cases,
case
 when total_cases is null then '0%'
  else 
  concat(round(( total_cases/population)*100,3),'%') 
  end as Infected_population
from portfolio..CovidDeaths
where continent is not null


-- country with higest infection rate
select location,population,max(total_cases)as max_cases, concat(round(max(( total_cases/population))*100,3),'%')  death_percentage
from portfolio..CovidDeaths
where continent is not null
group by location,population
order by round(max(( total_cases/population))*100,3) desc


--county with highest death percentage
select location,population,max(total_deaths)as total_death, concat(round(max(( total_deaths/population))*100,3),'%')  death_percentage
from portfolio..CovidDeaths
where continent is not null
group by location,population
order by round(max(( total_deaths/population))*100,3) desc


--country with higest population lost ( heigest total_deaths)
select location , max(cast(total_deaths as int)) as people_lost
from portfolio..CovidDeaths
where continent is not null
group by location 
order by people_lost desc

                    --continent data 
--continent with heighest case 
select location as continent ,max(total_cases) total_case
from portfolio..CovidDeaths
where continent is null
and location  not in('World','European Union' )
group by location
order by total_case desc

--continent with highest population lost
select location ,population, max(cast(total_deaths as int)) as people_lost,concat(round(max(( total_deaths/population))*100,3),'%')  death_percentage
from portfolio..CovidDeaths
where continent is  null
and location  not in('World','European Union','international' )
group by location ,population
order by location 


                    --globle data
select sum(new_cases) as total_case ,sum(cast(new_deaths as int)) as total_death ,concat( (sum(cast(new_deaths as int))/sum(new_cases))*100,'%') as death_percent
from portfolio..CovidDeaths
where continent is not null
-- population vacinated ( in 3 diffetent way )
-- 1 singal query
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cv.new_vaccinations as int)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
, round((SUM(Cast(cv.new_vaccinations as int)) OVER (Partition by cd.Location Order by cd.location, cd.Date)/population)*100,2) as population_vaccnated
From Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 
order by cd.location , cd.date


-- 2 with CTE
with vacper as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cv.new_vaccinations as int)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null )
select*,round((RollingPeopleVaccinated/population)*100,2) as population_vaccnated
from vacper

--3 temp table 
DROP Table if exists #PopulationVaccinated
Create Table #PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(Cast(cv.new_vaccinations as int)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths cd
Join Portfolio..CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 


select*,round((RollingPeopleVaccinated/population)*100,2) as population_vaccnated
from #PopulationVaccinated
order by Location,date
