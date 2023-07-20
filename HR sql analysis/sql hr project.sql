select * from hr;
--data cleaning and preprocessing

--formating the birthdate column in order to conver to date type
update  hr
set  birthdate =  replace(birthdate ,'/' ,'-');

--formating the hire_date column in order to conver to date type
update hr
set hire_date = replace(hire_date , '/' , '-');

--formating the termdate column in order to conver to date type
update hr
set termdate = left(replace(termdate , '/' , '-'),10)

--converting the bithdate column to date type
alter table hr
alter column birthdate type date using to_date(birthdate , 'mm-dd-yyyy');

--converting the hire_date column to date type
alter table hr
alter column hire_date type date using to_date(hire_date , 'mm-dd-yyyy');

--converting the termdate column to date type
alter table hr
alter column termdate type date using to_date(termdate , 'yyyy-mm-dd ');

--creating the new column named age 
alter table hr
add column age int;

--calculating the age and update the same in age column 
update hr
set age =  (current_date - birthdate)/365;

select * from hr

-- Question 1  what is the gender breakdown of current employee in both number and in percentage
with total_current_employee as (
			select count(*) 
			from hr
			where termdate is null)
select gender,count(*) :: int as employer_count,
		concat(
			round(
				count(*)  * 100.00 / (select count from total_current_employee)
				,2) --round to two decimal
			,'%') as percentege
from hr
where termdate is null
group by gender;

--what is the age distribution of employees in the company (current employee)
select case
			when age < 18 then '<18'
			when age between 18 and 24 then '18-24'	
			when age between 25 and 34 then '25-34'
			when age between 35 and 44 then '35-44'
			when age between 45 and 54 then '45-54'
			else '>55'
		end as age_category,
		count(*)
			
from hr
where termdate is null
group by age_category;

--How many employees work at HQ VS Remote
select location , count(*) as number_of_employee
from hr
where termdate is null
group by location;

--What is the average length of the employeement who have be terminated
select round(avg(termdate - hire_date) / 365,0) as avg_len_of_term_employee
from hr
where termdate is not null and termdate < current_date;

--how does the gender ditributed among the dept 
select department , gender , count(*) as count_of_employee
from hr
where termdate is null
group by department , gender
order by 1,2,3;
 
--which department has a highest turnover/termination rate
select department ,
		round(
			count(
				case when termdate > current_date  or termdate is null then null else 1 end) *100.00
			/ 
			count(*)
		,2) as termination_rate --avg(case when termdate is not null and termdate < current_date then 1 else 0 end) *100
from hr
group by department
order by 2 desc;

--distribution of employee among the state
select location_state , count(*) as no_of_employee
from hr
where termdate is null
group by location_state
order by 2 desc;

--how company employees change over the time based on hire and retirement
with cte as(
		select to_char(hire_date , 'yyyy') as year , 
				count(hire_date) as hire ,
				count(case 
						  when termdate is not null and termdate < current_date then termdate
					  	  else null
					  end) as termination
		from hr
		group by year
		order by 1),

	total_emp as(
		select year , hire , termination , 
				sum(hire - termination) over(order by year) as total_employee
		from cte)

select * , round((total_employee - lag(total_employee , 1 , 0) over(order by year))*100.00 / lag(total_employee , 1 , total_employee) over(order by year),2) as percentage_changes
from total_emp;

--find the employee id whoes age is less then 18 at the time of hiring
select emp_id , (hire_date - birthdate) / 365 as age_at_the_hiring
from hr
where (hire_date - birthdate) / 365 < 18
