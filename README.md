# HR-Compensation-Workforce-Analytics-using-SQL
Advanced SQL project analyzing employee compensation trends, salary progression, and pay benchmarking across departments and genders using window functions and subqueries.

# Project Overview 
This project demonstrates how SQL can be used to analyze employee compensation data and derive actionable HR and workforce insights.

Using advanced SQL techniques such as window functions, CTEs, ranking, and running aggregates, the project answers real-world HR analytics questions related to salary progression, departmental pay benchmarking, and employee compensation comparisons. This project uses a synthetic HR dataset inspired by real-world employee and compensation structures. The data includes employee details, departments, genders, and historical salary changes.

# Business Questions Answered 
1. Which employees had salary changes after a specific year?
2. How does an employee’s latest salary compare to their department’s average?
3. Who are the top earners within each department based on their latest salary?
4. How does compensation vary across genders relative to group averages?
5. How have employee salaries evolved over time?

# SQL Concepts & Techniques Used
- Common Table Expressions (CTEs) for step-by-step query structuring
- Window functions: ROW_NUMBER(), RANK(), AVG(), SUM()
- Partitioning and ordering within window functions
- Running totals and salary trend analysis
- Ranking and top-N analysis within groups
- Subqueries vs CTE-based query design

# Analytical Approach

Each problem in this project was solved using a layered SQL approach:

1. Identify the latest salary record per employee using window functions
2. Join employee attributes such as department and gender
3. Calculate group-level benchmarks (department / gender averages)
4. Compare individual employee metrics against group benchmarks
5. Filter and rank results to answer specific business questions

This layered approach improves query readability, debugging, and scalability.

# Why This Project Matters

This project reflects common HR and compensation analysis scenarios faced by HR, Finance, and Business Analytics teams.  
It demonstrates the ability to translate business questions into efficient SQL queries and interpret results meaningfully.

# Skills Demonstrated

- Analytical thinking and problem decomposition
- Writing readable and maintainable SQL
- Using window functions for business analysis
- Translating data outputs into insights


