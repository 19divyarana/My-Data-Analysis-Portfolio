use practice1;

select*from Customers;
select*from Orders;
select*from Employees;
select*from Departments;
select*from Projects;

#LEFT JOIN

#1.List all employees and their departments (include employees without department)
select emp_name,dept_name from Employees e left join Departments d on e.dept_id=d.dept_id;

#2. Find employees who are not assigned to any department
select emp_name,dept_name from Employees e left join Departments d on e.dept_id=d.dept_id where d.dept_id is null;

#3.Display all customers and their orders (even if no order)
select customer_name,order_id from Customers c left join Orders o on c.customer_id=o.customer_id;

#4.Show all departments with employee names (include empty departments)
select dept_name,emp_name from Departments d left join Employees e on e.dept_id=d.dept_id;

#5.List all employees and project names (employees without projects too)
select emp_name,project_name from Employees e left join Projects p on e.emp_id=p.emp_id;

#6.Find employees who have never worked on any project
select emp_name from Employees e left join Projects p on e.emp_id=p.emp_id where project_id is null;

#7.Display all employees with manager names (include top-level managers)
select e.emp_name , m.manager_id from Employees e left join Employees m on m.emp_id=e.manager_id;

#8.Get department list even if no employee is assigned
select dept_name,emp_name from Departments d left join Employees e on e.dept_id=d.dept_id;

#9.Count number of employees per department including zero count
select count(emp_id), dept_name from Employees e left join Departments d on e.dept_id = d.dept_id group by dept_name;

#10.Find employees whose department record is missing
select emp_name from Employees e left join Departments d on e.dept_id=d.dept_id where d.dept_id is null;


#RIGHT JOIN
#1. List all departments and employees working in them
select dept_name,d.dept_id,emp_name from Departments d right join Employees e on e.dept_id=d.dept_id; 

# 2. Find departments with no employees
select dept_name from Departments d right join Employees e on e.dept_id=d.dept_id where emp_id is null;

#3. Display all customers and their orders using RIGHT JOIN
select c.customer_id,customer_name ,order_id from Customers c right join Orders o on c.customer_id=o.customer_id;

#4. Show all projects even if no employee is assigned
select project_name ,emp_name from Projects p right join Employees e on p.emp_id=e.emp_id;

#5. Get department-wise employee list including empty departments
SELECT d.dept_name, emp_name
FROM Departments d
LEFT JOIN Employees e
ON d.dept_id = e.dept_id;

#6. Find departments that are not assigned to any employee
SELECT d.dept_name
FROM Departments d
LEFT JOIN Employees e
ON d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;

#7. Display all orders with customer info (even unmatched)
SELECT o.order_id, customer_name 
FROM Orders o
LEFT JOIN Customers c
ON o.customer_id = c.customer_id;

#8.Find departments where employee count is zero
SELECT d.dept_name, COUNT(e.emp_id) AS emp_count
FROM Departments d
LEFT JOIN Employees e
ON d.dept_id = e.dept_id
GROUP BY d.dept_name
HAVING COUNT(e.emp_id) = 0;

#9. Show all department names with employee names if available
SELECT d.dept_name, emp_name
FROM Departments d
LEFT JOIN Employees e
ON d.dept_id = e.dept_id;