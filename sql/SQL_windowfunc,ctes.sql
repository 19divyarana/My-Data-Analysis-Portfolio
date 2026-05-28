use practice3;
CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    joining_date DATE
);

INSERT INTO employees VALUES
(1, 'Amit', 'HR', 50000, '2021-01-10'),
(2, 'Neha', 'HR', 60000, '2020-03-15'),
(3, 'Raj', 'IT', 70000, '2019-07-20'),
(4, 'Priya', 'IT', 80000, '2018-05-25'),
(5, 'Karan', 'IT', 70000, '2022-02-10'),
(6, 'Sneha', 'Finance', 90000, '2017-11-30'),
(7, 'Ravi', 'Finance', 85000, '2019-09-05');

#1. Assign row numbers to employees by salary (highest first)
SELECT emp_name, salary,
ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

#2. Rank employees by salary
SELECT emp_name, salary,
RANK() OVER (ORDER BY salary DESC) AS rank_
FROM employees;

#3. Dense Rank employees
SELECT emp_name, salary,
DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rank_
FROM employees;

#4. Running total salary by department
SELECT emp_name, department, salary,
SUM(salary) OVER (PARTITION BY department ORDER BY salary) AS running_total
FROM employees;

#5. Show highest salary per department (using window)
SELECT emp_name, department, salary,
MAX(salary) OVER (PARTITION BY department) AS max_salary
FROM employees;

#6. Show previous employee salary (LAG)
SELECT emp_name, salary,
LAG(salary) OVER (ORDER BY salary) AS prev_salary
FROM employees;

#7. Show next employee salary (LEAD)
SELECT emp_name, salary,
LEAD(salary) OVER (ORDER BY salary) AS next_salary
FROM employees;

#8. Compare salary with department average
SELECT emp_name, department, salary,
AVG(salary) OVER (PARTITION BY department) AS avg_salary
FROM employees;

#9. Find employees earning above department average
SELECT *
FROM (
    SELECT emp_name, department, salary,
           AVG(salary) OVER (PARTITION BY department) AS avg_salary
    FROM employees
) t
WHERE salary > avg_salary;

#10. Use CTE to find top salaried employee per department
WITH ranked_employees AS (
    SELECT emp_name, department, salary,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS rnk
    FROM employees
)
SELECT emp_name, department, salary
FROM ranked_employees
WHERE rnk = 1;