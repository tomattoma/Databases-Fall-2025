-- Laboratory Work 7: SQL Views and Roles
-- Alpysbay Tomiris

create database lab7;

-- Part 1: Database Setup (Use Lab 6 Tables)

-- Create table: employees
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

-- Create table: departments
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

-- Create table: projects
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- Part 2: Creating Basic Views

-- Exercise 2.1: Simple View Creation
create view employee_details as
select e.emp_name, e.salary, d.dept_name, d.location
from employees e
inner join departments d on d.dept_id = e.dept_id
where d.dept_name is not null;

select * from employee_details;

-- Exercise 2.2: View with Aggregation
create view dept_statistics as
select dept_name,
       count(distinct emp_id) as emp_count,
       avg(salary) as avg_salary,
       max(salary) as max_salary,
       min(salary) as min_salary
from departments d
left join employees e on e.dept_id = d.dept_id
group by dept_name;

SELECT * FROM dept_statistics
ORDER BY emp_count DESC;

-- Exercise 2.3: View with Multiple Joins
create view project_overview as
select project_name,
       budget,
       dept_name,
       location,
       count(distinct emp_id) as team_size
from projects p
left join departments d on p.dept_id = d.dept_id
left join employees e on d.dept_id = e.dept_id
group by project_name, budget, dept_name, location;

-- Exercise 2.4: View with Filtering
create view high_earners as
select emp_name, salary, dept_name
from employees e
inner join departments d on e.dept_id = d.dept_id
where salary > 55000;

select * from high_earners
order by salary desc;

-- Part 3: Modifying and Managing Views

-- Exercise 3.1: Replace a View
drop view employee_details;

create view employee_details as
select
    e.emp_name,
    e.salary,
    case
        when salary > 60000 then 'High'
        when salary > 50000 then 'Medium'
        else 'Standard'
    end as salary_grade,
    d.dept_name,
    d.location
from employees e
inner join departments d on d.dept_id = e.dept_id
where d.dept_name is not null;

select * from employee_details;

-- Exercise 3.2: Rename a View
alter view high_earners
rename to top_performers;

SELECT * FROM top_performers;

-- Exercise 3.3: Drop a View
create view temp_view as
select emp_name, salary, dept_name
from employees e
inner join departments d on e.dept_id = d.dept_id
where salary < 50000;

drop view temp_view;

-- Part 4: Updatable Views

-- Exercise 4.1: Create an Updatable View
create view employee_salaries as
select emp_id, emp_name, dept_id, salary
from employees;

select * from employee_salaries;

-- Exercise 4.2: Update Through a View
update employee_salaries
set salary = 52000
where emp_name = 'John Smith'

-- Exercise 4.3: Insert Through a View
insert into employee_salaries (emp_id, emp_name, dept_id, salary)
values ( 6 ,'Alice Johnson',102,58000);

-- Exercise 4.4: View with CHECK OPTION
create view it_employees as
select emp_id, emp_name, dept_id, salary
from employees
where dept_id = 101
with local check option;

-- This should fail because of dept_id = 103
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);

-- Part 5: Materialized Views

-- Exercise 5.1: Create a Materialized View
create materialized view dept_summary_mv as
select d.dept_id,
       d.dept_name,
       count(distinct emp_id) as total_employees,
       coalesce(sum(salary), 0) as total_salaries,
       count(distinct project_id) as total_projects,
       coalesce(sum(budget),0) as total_budjet
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by d.dept_id, d.dept_name
with data;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- Exercise 5.2: Refresh Materialized View
insert into employees (emp_id, emp_name, dept_id, salary)
values (8,'Charlie Brown', 101, 54000);

refresh materialized view dept_summary_mv;

select * from dept_summary_mv;

-- Exercise 5.3: Concurrent Refresh
create unique index idx_dept_summary_mv on dept_summary_mv(dept_id);

refresh materialized view concurrently dept_summary_mv;

-- Exercise 5.4: Materialized View with NO DATA
create materialized view project_stats_mv as
select project_name,
       budget,
       dept_name,
       count(distinct emp_id)
from projects p
left join departments d on d.dept_id = p.dept_id
left join employees e on p.dept_id = e.dept_id
group by project_name, budget, dept_name
with no data;

SELECT * FROM project_stats_mv;
-- error no data

-- Part 6: Database Roles

-- Exercise 6.1: Create Basic Roles
create role analyst;
create role data_viewer with login password 'viewer123';
create user report_user with password 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

-- Exercise 6.2: Role with Specific Attributes
create role db_creator with createdb login password 'creator789';
create role user_manager with createrole login password 'manager101';
create role admin_user with superuser login password 'admin999' -- use carefully!

-- Exercise 6.3: Grant Privileges to Roles
grant select on employees, departments, projects to analyst;
grant all on employee_details to data_viewer;
grant select,insert on employees to report_user;

-- Exercise 6.4: Create Group Roles
create role hr_team;
create role finance_team;
create role it_team;

create user hr_user1 with password 'hr001';
create user hr_user2 with password 'hr002';
create user finance_user1 with password 'fin001';

grant hr_team to hr_user1, hr_user2;
grant finance_team to finance_user1;

grant select,update on employees to hr_team;
grant select on dept_statistics to finance_team;

-- Exercise 6.5: Revoke Privileges
revoke update on employees from hr_team;
revoke hr_team from hr_user2;
revoke all on employee_details from data_viewer;

-- Exercise 6.6: Modify Role Attributes
alter role analyst with login password 'analyst123';
alter role user_manager with superuser;
alter role analyst with password null;
alter role data_viewer with connection limit 5;

-- Part 7: Advanced Role Management

-- Exercise 7.1: Role Hierarchies
create role read_only;
grant select on all tables in schema public to read_only;

create role junior_analyst with login password 'junior123';
create role senior_analyst with login password 'senior123';

grant read_only to junior_analyst,senior_analyst;
grant insert,update on employees to senior_analyst;

-- Exercise 7.2: Object Ownership
create role project_manager with login password 'pm123';
alter view dept_statistics owner to project_manager;
alter table projects owner to project_manager;
-- Check ownership:
SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

-- Exercise 7.3: Reassign and Drop Roles
create role temp_owner with login;
create table temp_table(
    id int
);

alter table temp_table owner to temp_owner;
reassign owned by temp_owner to postgres;

drop owned by temp_owner;
drop role temp_owner;

-- Exercise 7.4: Row-Level Security with Views
create view hr_employee_view as
select *
from employees
where dept_id = 102;

grant select on hr_employee_view to hr_team;

create view finance_employee_view as
select emp_id, emp_name, salary
from employees;

grant select on finance_employee_view to finance_team;

-- Part 8: Practical Scenarios

-- Exercise 8.1: Department Dashboard View
create view dept_dashboard as
select dept_name,
       location,
       count(distinct emp_id) as emp_count,
       round(avg(salary), 2),
       count(distinct project_id),
       sum(budget),
       coalesce(round(budget/nullif(count(distinct emp_id), 0), 2),0)
from departments d
left join employees e on d.dept_id = e.dept_id
left join projects p on d.dept_id = p.dept_id
group by d.dept_id, dept_name, location, p.budget;


-- Exercise 8.2: Audit View
alter table projects
add column created_date timestamp default current_timestamp;
create view high_budget_projects as
select project_name,
       budget,
       dept_name,
       case
           when budget > 150000 then 'Critical Review Required'
           when budget > 100000 then 'Management Approval Needed'
           else 'Standard Process'
       end as approval_status
from projects p
left join departments d on p.dept_id = d.dept_id
where budget > 75000;

-- Exercise 8.3: Create Access Control System

-- Level 1 - Viewer Role:
create role viewer_role;
grant select on all tables in schema public to viewer_role;

-- Level 2 - Entry Role:
create role entry_role;
grant viewer_role to entry_role;
grant insert on employees, projects to entry_role;

-- Level 3 - Analyst Role:
create role analyst_role;
grant entry_role to analyst_role;
grant update on employees, projects to analyst_role;

-- Level 4 - Manager Role:
create role manager_role;
grant analyst_role to manager_role;
grant delete on employees, projects to manager_role;

-- Create Users:
create user alice with password 'alice123';
create user bob with password 'bob123';
create user charlie with password 'charlie123';

-- Assign users to roles:
grant viewer_role to alice;
grant analyst_role to bob;
grant manager_role to charlie;  
