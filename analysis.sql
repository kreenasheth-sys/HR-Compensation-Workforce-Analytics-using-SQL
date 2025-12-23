CREATE DATABASE hr_sql_practice;
USE hr_sql_practice;

CREATE TABLE Employee (
    BusinessEntityID INT PRIMARY KEY,
    Gender CHAR(1),
    HireDate DATE,
    SickLeaveHours INT,
    DepartmentID INT
);

CREATE TABLE EmployeePayHistory (
    BusinessEntityID INT,
    Rate DECIMAL(10,2),
    RateChangeDate DATE,
    FOREIGN KEY (BusinessEntityID) REFERENCES Employee(BusinessEntityID)
);

INSERT INTO Employee VALUES
(1, 'M', '2008-01-10', 40, 10),
(2, 'F', '2010-03-15', 50, 10),
(3, 'M', '2012-06-20', 45, 20),
(4, 'F', '2011-11-05', 55, 20),
(5, 'M', '2015-08-01', 30, 30),
(6, 'F', '2018-09-12', 35, 30);

INSERT INTO Employee VALUES
(1, 'M', '2008-01-10', 40, 10),
(2, 'F', '2010-03-15', 50, 10),
(3, 'M', '2012-06-20', 45, 20),
(4, 'F', '2011-11-05', 55, 20),
(5, 'M', '2015-08-01', 30, 30),
(6, 'F', '2018-09-12', 35, 30);

INSERT INTO EmployeePayHistory VALUES
-- Employee 1
(1, 25.00, '2009-01-01'),
(1, 30.00, '2011-01-01'),

-- Employee 2
(2, 28.00, '2010-01-01'),
(2, 32.00, '2013-01-01'),

-- Employee 3
(3, 22.00, '2012-01-01'),
(3, 26.00, '2014-01-01'),

-- Employee 4
(4, 24.00, '2011-01-01'),
(4, 29.00, '2014-01-01'),

-- Employee 5
(5, 20.00, '2015-01-01'),
(5, 27.00, '2018-01-01'),

-- Employee 6
(6, 23.00, '2018-01-01'),
(6, 31.00, '2020-01-01');

SELECT * FROM EMPLOYEE;
SELECT * FROM EMPLOYEEPAYHISTORY;

-- Q1: Identify employees whose most recent salary change occurred after 2010
-- Approach: Select the latest salary record per employee using ROW_NUMBER()
--           and filter by RateChangeDate

Select businessEntityID, Rate 
from (select businessEntityID, Rate, RateChangeDate, 
row_number() over (partition by businessEntityID order by RateChangeDate desc) as rn
from employeepayhistory) t 
where rn = 1 And year(ratechangedate) > 2010;

-- Q2: Retrieve employees whose rate is greater than the average rate
--     of employees hired after 2009
-- Approach: Compare employee rates against a calculated average using a subquery


SELECT DISTINCT eph.BusinessEntityID
FROM EmployeePayHistory eph
JOIN Employee e
  ON eph.BusinessEntityID = e.BusinessEntityID
WHERE eph.Rate >
(
    SELECT AVG(eph2.Rate)
    FROM EmployeePayHistory eph2
    JOIN Employee e2
      ON eph2.BusinessEntityID = e2.BusinessEntityID
    WHERE e2.HireDate > '2009-12-31'
);

-- Q3: List employees whose SickLeaveHours are within ±10% of the overall average
-- Approach: Calculate the average SickLeaveHours and filter using a range condition

Select BusinessEntityID, SickLeaveHours 
from employee
where SickLeaveHours 
between 0.9 * ( select avg(SickLeaveHours) from employee) 
and 1.1 * ( select avg(SickLeaveHours) from employee) ;

-- Q4: Find employees who share the same RateChangeDate with at least one other employee
-- Approach: Identify duplicate RateChangeDates and return associated employees

Select BusinessEntityID, RateChangeDate
from EmployeePayHistory
where ratechangedate 
IN ( SELECT RateChangeDate
    FROM EmployeePayHistory
    GROUP BY RateChangeDate
    HAVING COUNT(*) > 1
);

-- Q5: Show each employee’s rate and the running total of rate over time
-- Approach: Use SUM() as a window function ordered by RateChangeDate

Select BusinessEntityID, rate, 
sum(rate) over ( partition by BusinessEntityID order by RateChangeDate 
ROWS between unbounded preceding and current row) as Running_total
from employeepayhistory;

-- Q6: Display each employee’s latest rate and the difference from their department’s average rate
-- Tables used: EmployeePayHistory, Employee
-- Approach:
--   Layer 1: Identify the latest salary record per employee using ROW_NUMBER()
--   Layer 2: Join department information from the Employee table
--   Layer 3: Calculate department-level average rate using a window function
--   Layer 4: Compute the difference between each employee’s rate and their department average


With latest as (
Select businessEntityID, Rate 
from (
select businessEntityID, Rate, RateChangeDate, 
row_number() over (partition by businessEntityID order by RateChangeDate desc) as rn
from employeepayhistory) t 
where rn = 1)
Select e.departmentid, latest.businessEntityID, latest.Rate, 
round(avg(latest.rate) over (partition by e.departmentid),0) as avg_rate, 
latest.Rate - round(avg(latest.rate) over (partition by e.departmentid),0) as difference  
from latest
join employee e on e.businessEntityID = latest.businessEntityID;

-- Q7: Show the top 2 employees per department with the highest latest rate
-- Tables used: EmployeePayHistory, Employee
-- Approach:
--   Layer 1: Identify the latest salary record per employee
--   Layer 2: Join department information
--   Layer 3: Rank employees within each department by latest rate using RANK()
--   Layer 4: Filter to keep only the top 2 employees per department

With latest as (
Select businessEntityID, Rate 
from (
select businessEntityID, Rate, RateChangeDate, 
row_number() over (partition by businessEntityID order by RateChangeDate desc) as rn
from employeepayhistory) t 
where rn = 1),
highest as (
Select e.departmentid, latest.businessEntityID, latest.Rate, 
Rank() over (partition by e.departmentid order by latest.rate desc)  as highest_latest_rate
from latest
join employee e 
on e.businessEntityID = latest.businessEntityID)
Select departmentid, businessEntityID, Rate
from highest 
where  highest_latest_rate>=2;

-- Q8: Display each employee’s latest rate and the average rate within their gender.
--     Show only employees whose rate is higher than their gender’s average.
-- Tables used: EmployeePayHistory, Employee
-- Approach:
--   Layer 1: Identify the latest salary record per employee
--   Layer 2: Join gender information from the Employee table
--   Layer 3: Calculate gender-level average rate using a window function
--   Layer 4: Filter employees whose rate is greater than their gender average

With latest as (
Select businessEntityID, Rate 
from (
select businessEntityID, Rate, RateChangeDate, 
row_number() over (partition by businessEntityID order by RateChangeDate desc) as rn
from employeepayhistory) t 
where rn = 1),
gender_avg as (
Select latest.businessEntityID, latest.Rate, e.gender,
avg(latest.Rate) over (partition by gender)  as avg_rate_per_gender
from latest
join employee e 
on e.businessEntityID = latest.businessEntityID)
Select  businessEntityID, Rate, gender, avg_rate_per_gender
from gender_avg
where rate> avg_rate_per_gender;


