/*Laboratory Work #3 - DML Operations
Part A: Database and Table Setup 

1. Create database and tables */

CREATE TABLE employees(
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(120),
    last_name VARCHAR(120),
    department VARCHAR(120),
    salary INT,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments(
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(120),
    budget INT,
    manager_id INT
);

CREATE TABLE projects(
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(120),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

--Part B: Advanced INSERT Operations 

--2. INSERT with column specification 
INSERT INTO employees (first_name, last_name, department)
VALUES ('Rin', 'Itoshi', 'Marketing' );

--3. INSERT with DEFAULT values
INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Kotaro', 'Bokuto', 'IT', '2025-05-24');

--4. INSERT multiple rows in single statement 
INSERT INTO departments(dept_name, budget, manager_id)
VALUES ('Sales', 100000, 001),
       ('Finance',75000, 002),
       ('HR', 128000, 003);

--5. INSERT with expressions 
INSERT INTO employees(first_name, last_name, department, salary, hire_date, status)
VALUES ('Kakashi','Hatake','HR', 50000*1.1,CURRENT_DATE,'Inactive');

--6. INSERT from SELECT (subquery) 
CREATE TEMPORARY TABLE temp_employees AS
SELECT * FROM employees WHERE department = 'IT';

--Part C: Complex UPDATE Operations

--7. UPDATE with arithmetic expressions 
UPDATE employees
SET salary = salary*1.1;

--8. UPDATE with WHERE clause and multiple conditions 
UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

--9. UPDATE using CASE expression 
UPDATE employees
SET department  = CASE
    WHEN salary > 80000 then 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;

--10. UPDATE with DEFAULT 
UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

--11. UPDATE with subquery 
UPDATE departments d
SET budget = (
    SELECT AVG(salary) * 1.2
    FROM employees e
    WHERE e.department = d.dept_name
    );

--12. UPDATE multiple columns 
UPDATE employees
SET salary = salary	*	1.15,
    status = 'Promoted'
WHERE department = 'Sales';

--Part D: Advanced DELETE Operations  

--13. DELETE with simple WHERE condition
DELETE FROM employees
WHERE status = 'Terminated';

--14. DELETE with complex WHERE clause
DELETE FROM employees
WHERE salary < 40000 AND hire_date >'2023-01-01' AND department IS NULL;

--15. DELETE with subquery
DELETE FROM departments
WHERE dept_id NOT IN(
    SELECT DISTINCT department FROM employees
                               WHERE department IS NOT NULL
    );

--16. DELETE with RETURNING clause 
DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--Part E: Operations with NULL Values 

--17. INSERT with NULL values 
INSERT INTO employees(first_name, last_name, department, salary, hire_date, status)
VALUES ('Eren','Yeager',NULL,NULL,'2025-02-20', DEFAULT);

--18. UPDATE NULL handling 
UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

--19. DELETE with NULL conditions 
DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

--Part F: RETURNING Clause Operations 

--20. INSERT with RETURNING 
INSERT INTO employees (first_name, last_name, department, hire_date)
VALUES ('Naruto', 'Uzumaki', 'Sales', '2025-01-24')
RETURNING emp_id, first_name || ' ' || last_name AS full_name;

--21. UPDATE with RETURNING 
UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

--22. DELETE with RETURNING all columns 
DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--Part G: Advanced DML Patterns  

--23. Conditional INSERT 
INSERT INTO employees (first_name, last_name, department,salary, hire_date, status)
SELECT 'Ichigo','Kurosaki','IT',75000,'2025-07-15', DEFAULT
WHERE NOT EXISTS( -- we check that if this valuaes(f name, l name) exists or not, if ir exists it returns true, otherwise it returns false
    SELECT * FROM employees  
    WHERE first_name = 'Ichigo' 
    AND last_name = 'Kurosaki'
);
--24. UPDATE with JOIN logic using subqueries 
UPDATE employees e
SET salary = CASE
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department)> 100000
    THEN salary * 1.1
    ELSE salary * 1.05
END;

--25. Bulk operations 
INSERT INTO employees (first_name, last_name, department,salary, hire_date, status)
VALUES ('Ken', 'Kaneki', 'Sales',60000 ,'2023-08-23', 'Inactive'),
       ('Light','Yagami','IT',100000,'2024-05-27',DEFAULT),
       ('Killua','Zoldyck','HR',75000,'2025-07-15', DEFAULT),
       ('Levi', 'Ackerman', 'Finance',63000 ,'2022-04-14', 'Inactive'),
       ('Kaguya','Shinomiya','IT',85000,'2025-11-08', DEFAULT);

UPDATE employees
SET salary = salary * 1.10
WHERE first_name IN ('Ken', 'Light', 'Killua', 'Levi', 'Kaguya')
   AND last_name IN ('Kaneki', 'Yagami', 'Zoldyck', 'Ackerman', 'Shinomiya');

--26. Data migration simulation 
CREATE TABLE employee_archive(
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(120),
    last_name VARCHAR(120),
    department VARCHAR(120),
    salary INT,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

INSERT INTO employee_archive(emp_id,first_name, last_name, department, salary, hire_date,status)
SELECT emp_id, first_name, last_name, department, salary, hire_date, status
FROM employees
WHERE status = 'Inactive';

DELETE FROM employees
WHERE status = 'Inactive';

--27. Complex business logic 
SELECT department, COUNT(*)
FROM employees
GROUP BY department;

SELECT dept_id, dept_name FROM departments;

UPDATE projects
SET end_date = end_date - INTERVAL '30 days'
WHERE budget > 50000
AND dept_id IN (1,3);

