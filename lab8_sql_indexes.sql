-- Laboratory Work 8: SQL Indexes
-- Alpysbay Tomiris 
-- Part 1: Database Setup

-- Create tables
 CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
 );
 CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    dept_id INT,
    salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
 );
 CREATE TABLE projects (
    proj_id INT PRIMARY KEY,
    proj_name VARCHAR(100),
    budget DECIMAL(12,2),
    dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
 );-- Insert sample data
 INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
 (102, 'HR', 'Building B'),
 (103, 'Operations', 'Building C');
 INSERT INTO employees VALUES
 (1, 'John Smith', 101, 50000),
 (2, 'Jane Doe', 101, 55000),
 (3, 'Mike Johnson', 102, 48000),
 (4, 'Sarah Williams', 102, 52000),
 (5, 'Tom Brown', 103, 60000);
 INSERT INTO projects VALUES
 (201, 'Website Redesign', 75000, 101),
 (202, 'Database Migration', 120000, 101),
 (203, 'HR System Upgrade', 50000, 102);

select * from departments;

-- Part 2: Creating Basic Indexes

-- Exercise 2.1: Create a Simple B-tree Index
create index employees_salary_idx on employees(salary);

select indexname, indexdef
from pg_indexes
where tablename = 'employees';
-- Exercise 2.2: Create an Index on a Foreign Key
create index employees_dept_id_idx on employees(dept_id);

select * from employees where dept_id = 101;
-- Exercise 2.3: View Index Information
select tablename,
       indexname,
       indexdef
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;

-- Part 3: Multicolumn Indexes

-- Exercise 3.1: Create a Multicolumn Index
create index emp_dept_salary_idx on employees(dept_id,salary);

select emp_name,
       salary
from employees
where dept_id = 101 and salary > 52000;
-- Would this index be useful for a query that only filters by salary (without dept_id)? Why or why not?
-- Exercise 3.2: Understanding Column Order
create index emp_salary_dept_idx on employees(salary,dept_id);

select * from employees
where dept_id = 102 and salary > 50000;

select * from employees
where salary > 50000 and dept_id = 102;
--does the order matter?

-- Part 4: Unique Indexes

-- Exercise 4.1: Create a Unique Index
alter table employees
add column email varchar(120);

update employees set email = 'john.smith@company.com' where emp_id = 1;
update employees set email = 'jane.doe@company.com' where emp_id = 2;
update employees set email = 'mike.johnson@company.com' where emp_id = 3;
update employees set email = 'sarah.williams@company.com' where emp_id = 4;
update employees set email = 'tom.brown@company.com' where emp_id = 5;

create unique index emp_email_unique_idx on employees(email);

insert into employees(emp_id, emp_name, dept_id, salary,email)
values (6,'New Employee',101,55000,'john.smith@company.com');
-- this email is breaks the uniqueness of the index and cause the error
--Exercise 4.2: Unique Index vs UNIQUE Constraint
alter table employees add column phone varchar(20) unique;

select indexname,
       indexdef
from pg_indexes
where tablename = 'employees' and indexname like '%phone%';
-- Did SQL automatically create an index? What type of index?

-- Part 5: Indexes and Sorting

-- Exercise 5.1: Create an Index for Sorting
create index emp_salary_desc_idx on employees(salary desc);

select emp_name,
       salary
from employees
order by salary desc;

-- Exercise 5.2: Index with NULL Handling
create index proj_budget_nulls_first_idx on projects(budget nulls first);

select proj_name, budget
from projects
order by budget nulls first;

-- Part 6: Indexes on Expressions

-- Exercise 6.1: Create a Function-Based Index
create index emp_name_lower_idx on employees(lower(emp_name));

select * from employees where lower(emp_name) =  'john smith';
-- Exercise 6.2: Index on Calculated Values
alter table employees
add column hire_date date;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

create index emp_hire_year_idx on employees(extract(year from hire_date));

select emp_name, hire_date
from employees
where extract(year from hire_date) = 2020;

-- Part 7: Managing Indexes

-- Exercise 7.1: Rename an Index
alter index emp_salary_idx
rename to employees_salary_index;
-- Exercise 7.2: Drop Unused Indexes
drop index emp_salary_dept_idx;
-- Exercise 7.3: Reindex
reindex index employees_salary_index;

-- Part 8: Practical Scenarios

-- Exercise 8.1: Optimize a Slow Query
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d on e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;
-- Create indexes to optimize this query:
create index emp_salary_filter_idx on employees(salary) where salary > 50000;
-- Exercise 8.2: Partial Index
create index proj_high_budget_idx on projects(budget)
where budget > 80000;
-- Test the partial index:
select proj_name,budget
from projects
where budget > 80000;
-- Exercise 8.3: Analyze Index Usage
explain select * from employees
where salary > 52000;

-- Part 9: Index Types Comparison

-- Exercise 9.1: Create a Hash Index
create index dept_name_hash_idx on departments using hash(dept_name);
--Test the hash index:
select * from departments
where dept_name = 'IT';
-- Exercise 9.2: Compare Index Types
create index proj_name_btree_idx on projects(proj_name);
create index proj_name_btree_idx on projects using hash(proj_name);
-- Test with different queries:
-- Equality search (both can be used)
select * from projects
where proj_name = 'Website Redesign';
-- Range search (only B-tree can be used)
select * from projects
where proj_name > 'Database';

-- Part 10: Cleanup and Best Practices

--  Exercise 10.1: Review All Indexes
select
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
from pg_indexes
where schemaname = 'public'
order by tablename, indexname;
-- Exercise 10.2: Drop Unnecessary Indexes
drop index if exists proj_name_hash_idx;
--Exercise 10.3: Document Your Indexes
create view index_documentation as
select
    tablename,
    indexname,
    indexdef,
    'Improves salary-based queries' as purpose
from pg_indexes
where schemaname = 'public'
and indexname like '%salary%';

select * from index_documentation;