select *
from dbo.salaries
--Checking for nulls
select *
from myskillsid.dbo.salaries
where work_year is null
--Checking for distinct job titles
select distinct job_title
from dbo.salaries
order by job_title

--Checking for similar data analyst roles
select distinct job_title
from dbo.salaries
where job_title like '%data analyst'
order by job_title


--Checking average salaries for all levels in IDR
select (avg(salary_in_usd) * 15000) / 12 as avg_salaries_IDR_monthly
from dbo.salaries


--Checking average salaries in IDR monthly based on expertise
SELECT experience_level, (avg(cast(salary_in_usd as bigint)) * 15000)/12 as avg_salaries_IDR_monthly
from dbo.salaries
group by experience_level


--Checking average salaries in IDR monthly based on expertise and employment type

SELECT experience_level, employment_type, (avg(cast(salary_in_usd as bigint)) * 15000)/12 as avg_salaries_IDR_monthly
from dbo.salaries
group by experience_level, employment_type
order by experience_level, employment_type

--Checking average salaries in IDR monthly based on expertise and location
SELECT  company_location,experience_level, (avg(cast(salary_in_usd as bigint)) * 15000)/12 as avg_salaries_IDR_monthly
from dbo.salaries
group by  company_location, experience_level
order by  company_location

--Countries with great salaries as a full time data analyst, with entry-level and intermediate experience

SELECT company_location, avg(salary_in_usd) as salary_usd
from dbo.salaries
where job_title like '%data analyst%'
	AND	employment_type = 'FT'
	AND experience_level in ('MI', 'EN')
group by company_location
having avg(salary_in_usd) >= 20000

--In what year is the increase in salary for fulltime data analysts intermediate to senior expertise the highest? 
select distinct work_year
from dbo.salaries


with ds_1 as (
	select work_year, avg(salary_in_usd) as sal_usd_ex
	from dbo.salaries
	where employment_type = 'FT'
		and experience_level = 'EX'
		and job_title like '%data analyst%'
	group by work_year
), ds_2 as (
select work_year, avg(salary_in_usd) as sal_usd_mi
	from dbo.salaries
	where employment_type = 'FT'
		and experience_level = 'MI'
		and job_title like '%data analyst%'
	group by work_year
)select ds_1.work_year, ds_1.sal_usd_ex, ds_2.sal_usd_mi, ds_1.sal_usd_ex - ds_2.sal_usd_mi as diff
from ds_1 LEFT OUTER JOIN ds_2 
on ds_1.work_year = ds_2.work_year








with ds_1 as (
	select work_year, avg(salary_in_usd) as sal_usd_ex
	from dbo.salaries
	where employment_type = 'FT'
		and experience_level = 'EX'
		and job_title like '%data analyst%'
	group by work_year
), ds_2 as (
select work_year, avg(salary_in_usd) as sal_usd_mi
	from dbo.salaries
	where employment_type = 'FT'
		and experience_level = 'MI'
		and job_title like '%data analyst%'
	group by work_year
), t_year as (
select distinct work_year
from dbo.salaries
) select t_year.work_year, ds_1.sal_usd_ex,ds_2.sal_usd_mi, ds_1.sal_usd_ex - ds_2.sal_usd_mi
	from t_year
	left join ds_1 on ds_1.work_year = t_year.work_year
	left join ds_2 on ds_2.work_year = t_year.work_year




select ds_1.work_year, ds_1.sal_usd_ex, ds_2.sal_usd_mi, ds_1.sal_usd_ex - ds_2.sal_usd_mi as diff
from ds_1 LEFT OUTER JOIN ds_2 
on ds_1.work_year = ds_2.work_year