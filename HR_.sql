Create Database hr;
use hr_data;

select *
from hr_data

select termdate
from hr_data
order by termdate desc

update hr_data
set termdate = format(convert(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd')

alter table hr_data
add new_termdate = Case

--copy converted time values from termdate to new_termdate
update hr_data
set new_termdate = case
	when termdate is not null and ISDATE(termdate) = 1 then cast (termdate as datetime) else null end;

--create new column "age"
alter table hr_data
add age nvarchar(50);

--populate new column with age
update hr_data
set age = datediff(year, birthdate, getdate());

--age distribution 
select 
min(age) as youngest, 
max(age) as oldest
from hr_data

--age_group distribution 
SELECT age_group,
count(*) AS count
FROM
(SELECT 
 CASE
  WHEN age >= 21 AND age <= 30 THEN '21 to 30'
  WHEN age <= 31 AND age <= 40 THEN '31 to 40'
  WHEN age <= 41 AND age <= 50 THEN '41 to 50'
  ELSE '50+'
  END AS age_group
 FROM hr_data
 WHERE new_termdate IS NULL
 ) AS subquery
GROUP BY age_group
ORDER BY age_group;
--age group by gender 
select age_group,
count (*) as count 
from 
(select
  case 
	WHEN age >=21 AND age <=30 THEN '21 to 30'
	WHEN age >=31 AND age <=40 THEN '31 to 40'
	WHEN age >=41 AND age <=50 THEN '41 to 50'
	Else '50+' 
	end as age_group 
   from hr_data
   where new_termdate is null
   ) as subquery
group by age_group
order by age_group;


--Age Group By Gender
select age_group,gender,
count (*) as count 
from 
(select
  case 
	WHEN age >=21 AND age <=30 THEN '21 to 30'
	WHEN age >=31 AND age <=40 THEN '31 to 40'
	WHEN age >=41 AND age <=50 THEN '41 to 50'
	Else '50+' 
	end as age_group, gender
   from hr_data
   where new_termdate is null
   ) as subquery
group by age_group, gender
order by age_group, gender;

--gender breakdown in the company

select
gender,
count(gender) as count 
from hr_data
where new_termdate is null
group by gender
order by gender asc;

--gender by department
SELECT
  gender,
  department,
  COUNT(gender) AS count 
FROM
  hr_data
WHERE
  new_termdate IS NULL
GROUP BY
  department,
  gender
ORDER BY
  department,
  gender ASC;

--job titles
SELECT
  department,
  jobtitle,
  gender,
  COUNT(gender) AS count 
FROM
  hr_data
WHERE
  new_termdate IS NULL
GROUP BY
  department,
   jobtitle,
  gender
ORDER BY
  department,
   jobtitle,
  gender ASC;

--race distribution 
select 
race,
count(*) as count 
from 
hr_data
where new_termdate is null
group by race
order by count desc;

--average length of the employement
select 
AVG(datediff(year,hire_date, new_termdate)) as tenure
from hr_data
where new_termdate is not null and new_termdate <=GETDATE();

--department has highest turnover rate
SELECT 
  department,
  total_count,
  terminated_count,
  ROUND(CAST(terminated_count AS FLOAT) / total_count, 2) *100 AS turnover_rate
FROM 
  (SELECT 
     department, 
     COUNT(*) AS total_count,
     SUM(CASE 
           WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 
           ELSE 0 
         END) AS terminated_count
   FROM 
     hr_data
   GROUP BY 
     department) AS subquery
ORDER BY 
  turnover_rate DESC;

--tenure distribution by department
select 
department,
AVG(datediff(year,hire_date, new_termdate)) as tenure
from hr_data
where new_termdate is not null and new_termdate <=GETDATE()
group by department
order by tenure desc;

--work remotely by department
select 
 location, 
 count(*) as count 
from hr_data
where new_termdate is null 
group by location;

--employees across different states
select 
 location_state,
 count(*) as count 
from hr_data
where new_termdate is null
group by location_state
order by count desc;

--job title distributed in the company 
select 
 jobtitle,
 count(*) as count 
 from hr_data
 where new_termdate is null
 group by jobtitle
 order by count desc;

--hire counts varied over times
 Select 
 hire_year,
 hires,
 terminations,
 hires - terminations AS net_change,
 (round(CAST(hires-terminations AS FLOAT)/hires, 2)) * 100 AS percent_hire_change
 FROM
	(SELECT 
	 YEAR(hire_date) AS hire_year,
	 count(*) AS hires,
	 SUM(CASE
			WHEN new_termdate is not null and new_termdate <= GETDATE() THEN 1 ELSE 0
			END
			) AS terminations
	FROM hr_data
	GROUP BY YEAR(hire_date)
	) AS subquery
ORDER BY percent_hire_change ASC;