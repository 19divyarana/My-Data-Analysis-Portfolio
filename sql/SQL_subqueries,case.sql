use practice2;

CREATE TABLE departments (
    department_id INT,
    department_name VARCHAR(50)
);

INSERT INTO departments VALUES
(1, 'HR'),
(2, 'IT'),
(3, 'Sales'),
(4, 'Finance');

CREATE TABLE employees (
    id INT,
    name VARCHAR(50),
    salary INT,
    department_id INT,
    manager_id INT,
    experience INT,
    phone VARCHAR(20)
);

INSERT INTO employees VALUES
(1, 'John', 90000, 2, NULL, 6, '12345'),
(2, 'Alice', 60000, 2, 1, 3, NULL),
(3, 'Bob', 40000, 1, 1, 2, '67890'),
(4, 'David', 80000, 3, NULL, 7, '22222'),
(5, 'Eva', 30000, 3, 4, 1, NULL),
(6, 'Frank', 70000, 4, NULL, 5, '99999'),
(7, 'Grace', 85000, 2, 1, 8, NULL);

CREATE TABLE customers (
    customer_id INT,
    customer_name VARCHAR(50)
);

INSERT INTO customers VALUES
(101, 'Ravi'),
(102, 'Sita'),
(103, 'Amit'),
(104, 'Neha');

CREATE TABLE orders (
    order_id INT,
    customer_id INT,
    amount INT,
    order_date DATE,
    status INT
);

INSERT INTO orders VALUES
(1, 101, 500, '2025-01-01', 1),
(2, 101, 2000, '2025-01-02', 1),
(3, 102, 7000, '2025-01-03', 0),
(4, 103, 300, '2025-01-04', 1),
(5, 102, 1200, '2025-01-05', 0);

CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(50),
    price INT,
    category_id INT
);

INSERT INTO products VALUES
(1, 'Laptop', 60000, 1),
(2, 'Mouse', 500, 1),
(3, 'Phone', 20000, 1),
(4, 'Table', 3000, 2),
(5, 'Chair', 1500, 2);

CREATE TABLE order_items (
    order_id INT,
    product_id INT
);

INSERT INTO order_items VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 1),
(4, 2);

CREATE TABLE students (
    id INT,
    name VARCHAR(50),
    marks INT
);

INSERT INTO students VALUES
(1, 'Anu', 95),
(2, 'Bala', 75),
(3, 'Charan', 65),
(4, 'Divya', 45),
(5, 'Esha', 85);

CREATE TABLE logins (
    user_id INT,
    login_date DATE
);

INSERT INTO logins VALUES
(1, '2025-01-01'),
(1, '2025-01-02'),
(1, '2025-01-03'),
(2, '2025-01-01'),
(2, '2025-01-03');

CREATE TABLE rides (
    user_id INT,
    ride_date DATE,
    ride_time DATETIME
);

INSERT INTO rides VALUES
(1, '2025-01-01', '2025-01-01 10:00:00'),
(1, '2025-01-02', '2025-01-02 11:00:00'),
(1, '2025-01-03', '2025-01-03 09:00:00'),
(2, '2025-01-01', '2025-01-01 12:00:00'),
(2, '2025-01-03', '2025-01-03 14:00:00');

#SUBQUERIES
#1.Write a query to find employees whose salary is higher than the average salary of all employees.
SELECT name, salary 
	from employees 
	where salary  >(select AVG(salary) from employees);

#2.Retrieve the names of employees who work in the same department as 'John' using a subquery.

SELECT name
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE name = 'John'
);

#3.Write a query to find products whose price is greater than the average price in their category.
select product_name,price 
	from products p
	where price >(select avg(price) from products where category_id=p.category_id);

#4.Get customers who have placed at least one order using a subquery.
select customer_name 
	from customers 
    where customer_id in(select customer_id from orders);

#5.Write a query to find departments that have more than 5 employees.
select department_id 
	from employees 
	group by department_id 
	having count(*)>5;

#6.Retrieve the employee(s) who earn the maximum salary in the company using a subquery.
select name,id,salary 
	from employees 
	where salary = (select MAX(salary) from employees);

#7.Find orders where the order amount is greater than all orders placed by customer ID 101.
select * 
	from orders
	where amount > ALL (select amount from orders where customer_id=101);
#8.Write a query to list students who scored above average marks in a subject.
select * 
	from students 
	where marks> (select avg(marks) from students);

#9.Retrieve products that are not present in any order (use NOT IN subquery).
select product_name 
	from products 
    where product_id not in(select product_id from order_items);

#10.Find employees whose salary is higher than the average salary of their own department (correlated subquery).
select name,department_id,salary 
	from employees e 
    where salary>(select avg(salary) from employees where department_id = e.department_id);

#CASE
/*1.Write a query to categorize employees as:
'High' if salary > 80,000
'Medium' if between 50,000–80,000
'Low' if < 50,000*/

select name,salary,
	CASE
    when salary >80000 then 'high'
    when salary between 50000 and 80000 then 'medium'
    when salary < 50000 then 'low'
end as salary_category
from employees;

/*2.Display order status as:
'Completed' if status = 1
'Pending' if status = 0*/
select order_id,
CASE
when status = 1 then'Completed'
when status = 0 then 'PEnding'
end as order_status
from orders;

/*3.Show students' grades based on marks:
A (≥90), B (70–89), C (50–69), F (<50)*/
select id,name,
CASE
when marks >= 90 then 'A'
when marks between 70 and 89 then 'B'
when marks between 50 and 69 then 'C'
when marks < 50 then 'F'
end as grades
from students;



/*4.Write a query to show a bonus column:
10% bonus if salary > 70,000
5% if between 40,000–70,000
2% otherwise*/
select name,salary,
	CASE 
	when salary > 70000 then salary*0.10
	when salary between 40000 and 70000 then salary*0.05
	else salary *0.02
end as bonus
from employees;

/*5. Display "Experienced" if employee experience > 5 years, otherwise "Fresher".*/
select name,
	CASE
    when experience >5 then 'experinced'
    else 'Fresher'
end as level
from employees;

/*6.Use CASE to replace NULL values in a column with 'Not Available'.*/
select name,
	CASE
    when phone is null then 'not available'
    else phone
end as phone_number
from employees;

/*7.Show department names in uppercase if the number of employees > 10, otherwise lowercase.*/
select department_name,
CASE
when count(*)>10 then upper(department_name)
else lower(department_name)
end 
from employees
join departments using (department_id)
group by department_id,department_name;

/*8.Categorize orders based on amount:
'Small' (<1000)
'Medium' (1000–5000)
'Large' (>5000)*/

select order_id,
CASE
when amount <1000 then 'Small'
when amount between 1000 and 5000 then 'Medium'
when amount >5000 then 'Large'
end as categories
from orders;

/*9.Write a query to show:
'Weekday' if order date is Monday–Friday
'Weekend' otherwise*/
select order_id,order_date,
CASE
when dayofweek(order_date) in (1,7) then 'weekend'
else 'weekday'
end as day_type
from orders;


/*10.Use CASE to calculate tax:
15% if income > 100,000
10% if between 50,000–100,000
5% otherwise*/
select name,salary,
CASE
when salary > 100000 then salary*0.15
when salary between  50000 and 100000 then salary*0.10
else salary*0.05
end as tax
from employees;

