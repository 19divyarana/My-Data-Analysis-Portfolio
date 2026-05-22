use practice1;

#CROSS JOIN

#1.Generate all combinations of employees and departments
select emp_name,dept_name from Employees e cross join Departments d;

#2.Create all possible customer–product pairs
select customer_name,order_id from Customers c cross join Orders o;

#3.Find total number of combinations possible

SELECT COUNT(*) AS total_combinations
FROM employees e
CROSS JOIN departments d;

#4.Create matrix-style output from two tables
SELECT
    e.emp_name,
    d.dept_name,
    'X' AS assigned_flag
FROM Employees e
CROSS JOIN Departments d
ORDER BY e.emp_name, d.dept_name;

#MULTIPLE JOIN
#1.Get employee name, department name, and project name
select emp_name,dept_name,project_name from Employees e inner join Departments d on e.dept_id=d.dept_id join Projects p on e.emp_id=p.emp_id; 

#2. Display employee with department and manager name
select e.emp_name,m.manager_id ,d.dept_name from Employees e join Employees m on m.emp_id=e.emp_id join Departments d on e.dept_id=e.dept_id;

#3. Show employees working on multiple projects
SELECT
    e.emp_name,
    COUNT(p.project_id) AS project_count
FROM Employees e
JOIN Projects p ON e.emp_id = p.emp_id
GROUP BY e.emp_name
HAVING COUNT(p.project_id) > 1;

#4.List employees, departments, and salaries

SELECT 
    e.emp_name,
    d.dept_name,
    e.salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id;

#5. Display full employee profile using 3 tables
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    p.project_name,
    e.salary
FROM Employees e
JOIN Departments d ON e.dept_id = d.dept_id
LEFT JOIN Projects p ON e.emp_id = p.emp_id;