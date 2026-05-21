use practice1;

CREATE TABLE headquarters_employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    hire_date DATE,
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

CREATE TABLE branch_employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    hire_date DATE,
    department VARCHAR(50),
    salary DECIMAL(10,2)
);

CREATE TABLE customers2 (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    signup_date DATE,
    status VARCHAR(20)
);

INSERT INTO headquarters_employees VALUES
(101, 'John', 'Smith', 'john.smith@company.com', '2018-03-15', 'IT', 75000.00),
(102, 'Mary', 'Johnson', 'mary.johnson@company.com', '2019-06-22', 'HR', 65000.00),
(103, 'Robert', 'Williams', 'robert.williams@company.com', '2017-11-08', 'Finance', 82000.00),
(104, 'Susan', 'Brown', 'susan.brown@company.com', '2020-01-30', 'Marketing', 68000.00),
(105, 'Michael', 'Davis', 'michael.davis@company.com', '2018-09-12', 'IT', 78000.00);

INSERT INTO branch_employees VALUES
(201, 'James', 'Wilson', 'james.wilson@company.com', '2019-04-18', 'Sales', 62000.00),
(202, 'Patricia', 'Moore', 'patricia.moore@company.com', '2020-07-25', 'Marketing', 59000.00),
(203, 'Linda', 'Taylor', 'linda.taylor@company.com', '2018-08-15', 'HR', 61000.00),
(204, 'Robert', 'Williams', 'robert.williams@company.com', '2017-11-08', 'Finance', 82000.00), -- Duplicate employee who works at both locations
(205, 'Elizabeth', 'Anderson', 'elizabeth.anderson@company.com', '2019-12-03', 'Sales', 64000.00);

INSERT INTO customers2 VALUES
(1001, 'David', 'Miller', 'david.miller@email.com', '2019-02-14', 'Active'),
(1002, 'Sarah', 'Wilson', 'sarah.wilson@email.com', '2020-05-20', 'Active'),
(1003, 'Michael', 'Davis', 'michael.davis@email.com', '2018-11-30', 'Inactive'), -- Same name as an employee
(1004, 'Jennifer', 'Garcia', 'jennifer.garcia@email.com', '2021-01-05', 'Active'),
(1005, 'Robert', 'Martinez', 'robert.martinez@email.com', '2019-08-22', 'Active');

SELECT * FROM headquarters_employees;
SELECT * FROM branch_employees;
SELECT * FROM customers2;

# Example 1: UNION vs UNION ALL
#Get a list of all employees from both locations (without duplicates) Example 1: UNION vs UNION ALL
#1 Get a list of all employees from both locations (without duplicates)
SELECT first_name, last_name, email FROM headquarters_employees
UNION
SELECT first_name, last_name, email FROM branch_employees;


-- Get a list of all employees from both locations (including duplicates)
SELECT first_name, last_name, email FROM headquarters_employees
UNION ALL
SELECT first_name, last_name, email FROM branch_employees;

#3.Combining full tables
SELECT * FROM headquarters_employees
UNION ALL
SELECT * FROM branch_employees;

#4.Combine employee and customer contact information with a type indicator
SELECT first_name, last_name, email, 'Employee' AS contact_type
FROM headquarters_employees
UNION
SELECT first_name, last_name, email, 'Customer' AS contact_type
FROM customers2;

#5.Get all employees sorted by last name
SELECT employee_id, first_name, last_name, department
FROM headquarters_employees
UNION
SELECT employee_id, first_name, last_name, department
FROM branch_employees
ORDER BY last_name;

#6.Get employees with salary over 70000
SELECT employee_id, first_name, last_name, department, salary
FROM headquarters_employees
WHERE salary > 70000
UNION
SELECT employee_id, first_name, last_name, department, salary
FROM branch_employees
WHERE salary > 70000
ORDER BY salary DESC;

#7.Handling different table structures with NULL values
SELECT employee_id, first_name, last_name, department, salary, NULL AS status
FROM headquarters_employees
UNION
SELECT customer_id, first_name, last_name, NULL, NULL, status
FROM customers2
ORDER BY first_name, last_name;

#8.Finding all unique departments across locations
SELECT department
FROM headquarters_employees
UNION
SELECT department
FROM branch_employees;

#9.Departments that exist in both headquarters and branch offices
SELECT department FROM (
    SELECT DISTINCT department
    FROM headquarters_employees
    UNION ALL
    SELECT DISTINCT department
    FROM branch_employees
) AS combined 
GROUP BY department 
HAVING COUNT(*) = 2;

#SELFJOIN
#1.. Display employee name and their manager’s name
select e.emp_name,e.manager_id from Employees e left join Employees m on e.manager_id=m.manager_id;

#2. Find employees who report to the same manager
SELECT e1.emp_name AS emp1,
       e2.emp_name AS emp2,
       e1.manager_id
FROM Employees e1
JOIN Employees e2
ON e1.manager_id = e2.manager_id
AND e1.emp_id < e2.emp_id;

#3.3. List managers and number of employees reporting to them
SELECT m.emp_name AS manager,
       COUNT(e.emp_id) AS report_count
FROM Employees e
JOIN Employees m
ON e.manager_id = m.emp_id
GROUP BY m.emp_name;

#4.4. Find employees earning more than their managers
SELECT e.emp_name AS employee,
       e.salary AS employee_salary,
       m.emp_name AS manager,
       m.salary AS manager_salary
FROM Employees e
JOIN Employees m
ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;


#5. Show employee hierarchy up to one level
SELECT e.emp_name AS employee,
       m.emp_name AS manager,
       gm.emp_name AS grand_manager
FROM Employees e
LEFT JOIN Employees m
ON e.manager_id = m.emp_id
LEFT JOIN Employees gm
ON m.manager_id = gm.emp_id;


