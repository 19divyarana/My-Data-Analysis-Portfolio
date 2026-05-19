create database my_sql1;

use my_sql1;

create table Employees(
emp_id int PRIMARY KEY,
name varchar(30),
department varchar(20),
salary int );


insert into Employees values(1,"Ram","IT",30000),
(2,"Raj","HR",50000);

select * from Employees;

select name,salary from Employees;

select name, salary *12 as annual_salary from Employees;

select distinct department from Employees;

select name,salary as max_salary from Employees order by salary DESC  limit 2;

select * from Employees where salary > 35000;

drop table sales;

create table sales(
id int,
products varchar(20),
quantity int,
year datetime,
price int);


insert into sales value (101,"Brush",10,"2014-01-01",20), 
(102,"Paste",10,"2016-01-01",20),
(103,"Pen",10,"2014-01-01",50),
(104,"jeans",10,"2014-01-01",40),
(105,"shirts",10,"2014-01-01",100),
(106,"scale",10,"2014-01-01",10),
(107,"Books",10,"2014-01-01",400);

select * from sales;

select * from sales where quantity= "null";

select year=2012 from sales;

select employee_name from sales where hiring_date between "2012-01-01" and "2014-01-01";


select products like "B%" from sales;