-- to standardise the termdate format
Select Convert(DATE,LEFT(termdate,10)) as termdate
From HumanResource..HR_Data

--to update the termdate format to date
Update HumanResource..HR_Data
Set termdate = Convert(DATE,LEFT(termdate,10)) 

--to add new column 'new_termdate'
Alter Table HumanResource..HR_Data
Add new_termdate Date

--to copy converted time values from termdate to new_termdate
Update HumanResource..HR_Data
Set new_termdate = termdate

--to find the age of the employees
Select birthdate, 
DATEDIFF(year, birthdate, GETDATE()) as age
From HumanResource..HR_Data

--to create new column "age"
Alter table HumanResource..HR_Data
Add age nvarchar(50)

--to update new column "age"
Update HumanResource..HR_Data
Set age = DATEDIFF(year, birthdate, GETDATE())

--QUESTIONS TO ANSWER FROM THE DATA
--1) what is the age distribution in the company?
Select age, COUNT(id) as number_of_employees
From HumanResource..HR_Data
Group by age 
Order by age asc

Select MIN(age) as youngest, Max(age) as oldest
From HumanResource..HR_Data

--2) age group for existing employees
Select age_group, COUNT(*) as 'Count'
From
(Select age,
	Case
		When age >= 21 and age <= 30 Then '21 to 30'
		When age >= 31 and age <= 40 Then '31 to 40'
		When age >= 41 and age <= 50 Then '41 to 50'
		When age >= 51 and age <= 60 Then '50+'
		End as age_group
From HumanResource..HR_Data
Where new_termdate IS NULL
) as sub
Group by age_group
Order by age_group

--age group by gender
With temp_table as
(Select age, gender,
	Case
		When age >= 21 and age <= 30 Then '21 to 30'
		When age >= 31 and age <= 40 Then '31 to 40'
		When age >= 41 and age <= 50 Then '41 to 50'
		When age >= 51 and age <= 60 Then '50+'
		End as age_group
From HumanResource..HR_Data
Where new_termdate IS NULL
)
Select age_group, gender, Count(*) as Count
From temp_table
Group by gender, age_group
Order by gender, age_group

--3) what is the gender breakdown in the company?
Select gender, count(gender) as count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by gender

--4) how does gender vary across departments and job titles?
Select department, gender, count(gender) as count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by department, gender
Order by department, gender

Select department, jobtitle, gender, count(gender) as count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by department, jobtitle, gender
Order by department, jobtitle, gender

--5) what is the race distribution in the company?
Select race, count(race) as count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by race

--6) what is the average length of employment in the company?
Select AVG(DATEDIFF(year, hire_date, new_termdate)) as tenure
From HumanResource..HR_Data
Where new_termdate IS NOT NULL and new_termdate <= GETDATE()

--7) which department has the highest turnover rate?
--get total count
--get terminated count
--get terminated/total count
With temp_table as 
(Select department, 
count(*) as total_count,
	sum(Case 
	When new_termdate IS NOT NULL and new_termdate <= GETDATE() Then 1 Else 0
	End) as terminated_count
From HumanResource..HR_Data
Group by department
)
Select department, 
total_count, 
terminated_count, 
Round(CAST(terminated_count AS FLOAT) / CAST(total_count AS FLOAT),2) as turnover_rate
From temp_table

--8) what is the tenure distribution for each department?
Select department, AVG(DATEDIFF(year, hire_date, new_termdate)) as tenure
From HumanResource..HR_Data
Where new_termdate IS NOT NULL and new_termdate <= GETDATE()
Group by department
Order by tenure desc

--9) how many employees work remotely for each department?
Select department, location, count(*) as Count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by department, location
Order by location

--10) what is the distribution of employees across different states?
Select location_state, count(*) as Count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by location_state

--11) How are job titles distributed in the company?
Select jobtitle, count(*) as Count
From HumanResource..HR_Data
Where new_termdate IS NULL
Group by jobtitle

--12) how have employee hire counts varied over time?
--calculate hires
--calculate terminations
--(hires-termination)/hires 

With temp_table as
(Select Year(hire_date) as year_of_hire, count(*) as no_of_hires,
	SUM(Case
	When new_termdate IS NOT NULL and new_termdate <= GETDATE() Then 1 Else 0
	end) as no_of_terminates
From HumanResource..HR_Data
Group by Year(hire_date)
)
Select 
year_of_hire, 
no_of_hires, 
no_of_terminates, 
ROUND((CAST(no_of_hires as FLOAT)-CAST(no_of_terminates as FLOAT))/CAST(no_of_hires as FLOAT),2) as hire_rates
From temp_table
Order by year_of_hire

--to see all data
Select *
From HumanResource..HR_Data

