-- all rows and coloumns from covid deaths table
select * from dbo.CovidDeaths

-- all rows and coloumns from covid vaccinationsntable
select * from dbo.CovidVaccinations

-- i executed the data that i wanted to use
select date,location, total_cases,new_cases, total_deaths, population
from dbo.CovidDeaths
order by 2,1





--total cases vs population
--this query shows how much percent population has been effected by covid in India
select date,location, total_cases, population, (total_cases/population)*100 as populationeffected
from dbo.CovidDeaths
where location like 'india'
order by 2,1

--this query shows the population effected through the world
select date,location, total_cases, population, (total_cases/population)*100 as populationeffected
from dbo.CovidDeaths
order by 2,1

--countries with highest infection rate compared  to population
select location, population, max(total_cases)as higestrateofinfection , max((total_cases/population))*100 as populationeffected
from dbo.CovidDeaths
--where location like 'india'
group by location, population 
order by populationeffected desc --andorra has the highest population affected by 17%, followed by montenegro and czechia by 15%

--highest death count by each country.

select location,max(cast(total_deaths as int)) as totaldeathcount
from dbo.CovidDeaths
--where location like 'india'
where  continent is not null-- used this where caluse cause there are some rows in the table where the values are null. this yields accurate results required.
group by location
order by totaldeathcount desc -- united states has more death count of nearly 60 thousand people followed by brazil by 40 thousand.


--the total death count by continent
select continent,max(cast(total_deaths as int)) as totaldeathcount -- used cast because the data is in the form of nvarchar
from dbo.CovidDeaths
--where location like 'india'
where  continent is  not null
group by continent
order by totaldeathcount desc




--global numbers

select sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as globaldeathpercent
from dbo.CovidDeaths
where continent is not null
--group by date, this gives the death percent on  a particular day 
order by 1,2 --2% of people died across the globe


--JOINING EVERYTHING FROM  COVIDDEATH AND COVIDVACCINATIONS TABLES BY USING COMMON JOIN

select* from dbo.CovidDeaths D
join dbo.CovidVaccinations V 
On d.location=V.location 
and d.date = V.date

--LOOKING AT TOTAL POPULATION AND VACCINATIONS

select d.continent,d.location,d.date,d.population,v.new_vaccinations
from dbo.CovidDeaths D
join dbo.CovidVaccinations V 
On d.location=V.location 
and d.date = V.date
where d.continent is not null
order by 2,3

--rolling count of new vaccinations
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast (v.new_vaccinations as int))over  (partition by d.location order by d.location,d.date) as rolling_count_people_vaccinated
from dbo.CovidDeaths D
join dbo.CovidVaccinations V 
On d.location=V.location 
and d.date = V.date
where d.continent is not null
order by 2,3


--totalpopulations vs vaccinations by using rolling feature from the above query
-- we cannot use the coloumn created in the table
--so cte or temp tables comes in handy

--USING CTEs

with PopulationvsVaccination(coontinent,location,date,population,new_vaccinations,rolling_count_people_vaccinated)
as
(
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast (v.new_vaccinations as int))over  (partition by d.location order by d.location,d.date) as rolling_count_people_vaccinated
from dbo.CovidDeaths D
join dbo.CovidVaccinations V 
On d.location=V.location 
and d.date = V.date
where d.continent is not null
)
select *,(rolling_count_people_vaccinated/population)*100 as rollingvaccinations
from PopulationvsVaccination


--TEMPTABLE
drop table if exists #percentagepopvacccinated
create table #percentagepopvacccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count_people_vaccinated numeric
)
insert into #percentagepopvacccinated
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast (v.new_vaccinations as int))over  (partition by d.location order by d.location,d.date) as rolling_count_people_vaccinated
from dbo.CovidDeaths D
join dbo.CovidVaccinations V 
On d.location=V.location 
and d.date = V.date
--where d.continent is not null

select *,(rolling_count_people_vaccinated/population)*100 as rollingvaccinations
from #percentagepopvacccinated

--creating views  for later
create view populationvaccination as
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(cast (v.new_vaccinations as int))over  (partition by d.location order by d.location,d.date) as rolling_count_people_vaccinated
from dbo.CovidDeaths D
join dbo.CovidVaccinations V 
On d.location=V.location 
and d.date = V.date

select*
from populationvaccination