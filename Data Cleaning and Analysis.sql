Use SampleProjects;
Select * from hr;

-- Data Cleaning
Alter table hr
change Column ï»¿id  emp_id varchar(20);

Describe HR;

Select birthdate from hr;

Set sql_safe_updates=0;
   
UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

Select hire_date from hr;
   
Alter table hr
Modify column hire_date date;

Describe HR;
Select termdate from hr;

UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

Alter table hr modify column termdate date;

SELECT @@GLOBAL.sql_mode global, @@SESSION.sql_mode SESSION;

SET GLOBAL sql_mode = '';

alter table hr add column age int;

update hr
set age = timestampdiff(YEAR,birthdate,CURDATE());

select age from hr;

SELECT min(age) as yongest, max(age) as oldest from hr;

select count(*) from hr where age<18;
select count(*) from hr where termdate > curdate();

SELECT COUNT(*)
FROM hr
WHERE termdate = '0000-00-00';

select location from hr;

-- QUESTIONS

-- 1.What is the gender breakdown of employees in the company?
SELECT gender,count(*) as count from hr 
where age >= 18 and termdate = '0000-00-00'
GROUP BY GENDER;


-- 2.What is the race/ethnicity breakdown of employees in the company?
SELECT race,count(*) from hr
where age>=18 and termdate = '0000-00-00'
group by race;


-- 3.What is the age distribution of employees in the country?
select case when age>= 18 and age<=24 then '18-24'
			when age>= 25 and age<=34 then '25-34'
			when age>= 35 and age<=44 then '35-44'
            when age>= 45 and age<=54 then '45-54'
            else '65+'
            end as age_group,gender,
            count(*) as count 
            from hr
            where age>= 18 and termdate = '0000-00-00'
            group by age_group,gender
            order by age_group;
            
            
-- 4.How many employees work at headquarters versus remote location?
SELECT location,count(*) from hr
where age>=18 and termdate = '0000-00-00'
group by location;


-- 5.What is the average length of employement for employees who have been terminated?
select round(avg(datediff(termdate,hire_date))/365,0) as average_len_of_employement from hr
where age>=18 and termdate <> '0000-00-00' and termdate <= curdate();


-- 6.How does the gender distribution vary across departments and job titles?
select gender,department,count(*) from hr
where age>= 18 and termdate = '0000-00-00'
group by gender,department
order by department;


-- 7.What is the distribution of job titles across the country?
select jobtitle,count(*) from hr
where age>= 18 and termdate = '0000-00-00'
group by jobtitle
order by jobtitle desc;

-- 8.Which department has the highest longevity rate?
SELECT department, COUNT(*) as total_count, 
    SUM(CASE WHEN termdate <= CURDATE() AND termdate <> '0000-00-00' THEN 1 ELSE 0 END) as terminated_count, 
    SUM(CASE WHEN termdate = '0000-00-00' THEN 1 ELSE 0 END) as active_count,
    (SUM(CASE WHEN termdate <= CURDATE() THEN 1 ELSE 0 END) / COUNT(*)) as termination_rate
FROM hr
WHERE age >= 18
GROUP BY department
ORDER BY termination_rate DESC;


-- 9.What is the distribution of employees across locations by city and state?
select location_city,location_state,count(*) from hr
where age>= 18 and termdate = '0000-00-00'
group by location_city,location_state;

-- 10.How has the companys employee count changed over time based on hire and term dates?
SELECT 
    YEAR(hire_date) AS year, 
    COUNT(*) AS hires, 
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations, 
    COUNT(*) - SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS net_change,
    ROUND(((COUNT(*) - SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END)) / COUNT(*) * 100),2) AS net_change_percent
FROM 
    hr
WHERE age >= 18
GROUP BY 
    YEAR(hire_date)
ORDER BY 
    YEAR(hire_date) ASC;
    
SELECT year, hires, terminations, 
    (hires - terminations) AS net_change,
    ROUND(((hires - terminations) / hires * 100), 2) AS net_change_percent
FROM (
    SELECT 
        YEAR(hire_date) AS year, 
        COUNT(*) AS hires, 
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
        hr
    WHERE age >= 18
    GROUP BY 
        YEAR(hire_date)
) subquery
ORDER BY 
    year ASC;
    
-- 11.what is the tenure distribution of each department?
select department,round(avg(datediff(curdate(),termdate))/365,0) as average_tenure from hr
where termdate<= curdate() and termdate != '0000-00-00' and age>= 18
group by department;
