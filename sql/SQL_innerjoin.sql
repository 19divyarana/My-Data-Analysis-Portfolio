use practice1;

show tables;

select *from Customers;
select *from Employees;
select*from Departments;
select *from Projects;
select *from Orders;

#INNER JOIN

#1. Fetch employee name and department name for employees assigned to a department

SELECT emp_name, dept_name
FROM Employees e
INNER JOIN Departments d
ON e.dept_id = d.dept_id;

#2. Find employees working on at least one project
SELECT DISTINCT emp_name
FROM Employees e
INNER JOIN Projects p
ON e.emp_id = p.emp_id;


#3. List orders placed by customers (exclude customers with no orders)

select customer_name, order_id
FROM Customers c
INNER JOIN Orders o
ON c.customer_id = o.customer_id;

#4. Get department‑wise employee list where both exist
SELECT dept_name, emp_name
FROM Departments d
INNER JOIN Employees e
ON d.dept_id = e.dept_id;

#5. Find employees whose department name is “IT”
SELECT e.emp_name
FROM Employees e
INNER JOIN Departments d
ON e.dept_id = d.dept_id
WHERE d.dept_name = 'IT';

#6. Display project name with employee name who is working on it
SELECT e.emp_name, p.project_name
FROM Employees e
INNER JOIN Projects p
ON e.emp_id = p.emp_id;

#7. Find employees earning more than 50,000 and having a department
SELECT e.emp_name, e.salary
FROM Employees e
INNER JOIN Departments d
ON e.dept_id = d.dept_id
WHERE e.salary > 50000;

# 8. Get customers who have placed orders in the system
SELECT DISTINCT c.customer_name
FROM Customers c
INNER JOIN Orders o
ON c.customer_id = o.customer_id;

# 9. Fetch employees whose dept_id matches a valid department
SELECT e.emp_name
FROM Employees e
INNER JOIN Departments d
ON e.dept_id = d.dept_id;

# 10. Find common records between Employees and Departments tables
SELECT DISTINCT e.dept_id
FROM Employees e
INNER JOIN Departments d
ON e.dept_id = d.dept_id;