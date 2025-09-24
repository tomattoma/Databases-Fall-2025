/*  Laboratory Work #2
Part 1: Multiple Database Management*/ 

-- Task 1.1: Database Creation with Parameters
--1
CREATE DATABASE university_main
WITH
OWNER = postgres
ENCODING = 'UTF8'
TEMPLATE = template0;

SELECT CURRENT_USER;

--2
CREATE DATABASE university_archive
WITH
CONNECTION LIMIT = 50
TEMPLATE = template0;

--3
CREATE DATABASE university_test
WITH
IS_TEMPLATE = true
CONNECTION LIMIT = 10;

--Task 1.2: Tablespace Operations
--1
CREATE TABLESPACE student_data
LOCATION 'C:/Users/Huawei/Downloads/data/students';

--2
CREATE TABLESPACE course_dataa
OWNER postgres
LOCATION 'C:\Users\Huawei\Downloads\data\courses';

--3 
CREATE DATABASE university_distributed
TABLESPACE student_data
ENCODING 'UTF8' --LATIN9 не работает 
TEMPLATE template0;

/* Part 2: Complex Table Creation

Task 2.1: University Management System

Table: Students */ 

CREATE TABLE students(
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa DECIMAL(3,2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

-- Table: professors 

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary DECIMAL(10,2),
    is_tenured BOOLEAN,
    years_experience INT
);

-- Table: courses 

CREATE TABLE courses(
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INT,
    course_fee DECIMAL(10,2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

-- Task 2.2: Time-based and Specialized Tables
-- Table: class_schedule

CREATE TABLE class_schedule(
    schedule_id SERIAL PRIMARY KEY,
    course_id INT REFERENCES courses(course_id),
    professor_id INT,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);

-- Table: student_records

CREATE TABLE student_records(
    record_id SERIAL PRIMARY KEY,
    student_id INT REFERENCES students(student_id),
    course_id INT REFERENCES courses(course_id),
    semester VARCHAR(20),
    year INT,
    grade CHAR(2),
    attendance_percentage DECIMAL(4,1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);

/* Part 3: Advanced ALTER TABLE Operations 
Task 3.1: Modifying Existing Tables */

-- Modify students table:  

--1
ALTER TABLE students
ADD COLUMN middle_name VARCHAR(30);
--2
ALTER TABLE students
ADD COLUMN student_status VARCHAR(20);
--3
ALTER TABLE students
ALTER COLUMN phone TYPE VARCHAR(20);
--4
ALTER TABLE students
ALTER COLUMN student_status SET DEFAULT 'ACTIVE';
--5
ALTER TABLE students
ALTER COLUMN gpa SET DEFAULT 0.00;

--Modify professors	table:

--1
ALTER TABLE professors
ADD COLUMN department_code CHAR(5);
--2
ALTER TABLE professors
ADD COLUMN research_area TEXT;
--3
ALTER TABLE professors
ALTER COLUMN years_experience TYPE SMALLINT;
--4
ALTER TABLE professors
ALTER COLUMN is_tenured SET DEFAULT FALSE;
--5
ALTER TABLE professors
ADD COLUMN last_promotion_date DATE;

--Modify courses table:

--1
ALTER TABLE courses
ADD COLUMN prerequisite_course_id INT;
--2
ALTER TABLE courses
ADD COLUMN difficulty_level SMALLINT;
--3
ALTER TABLE courses
ALTER COLUMN course_code TYPE VARCHAR(10);
--4
ALTER TABLE courses
ALTER COLUMN credits SET DEFAULT 3;
--5
ALTER TABLE courses
ADD COLUMN lab_required BOOLEAN DEFAULT FALSE;

--Task 3.2: Column Management Operations

--For class_schedule table:
--1
ALTER TABLE class_schedule
ADD COLUMN room_capacity INT;
--2
ALTER TABLE class_schedule
DROP COLUMN duration;
--3
ALTER TABLE class_schedule
ADD COLUMN session_type VARCHAR(15);
--4
ALTER TABLE class_schedule
ALTER COLUMN classroom TYPE VARCHAR(30);
--5
ALTER TABLE class_schedule
ADD COLUMN equipment_needed TEXT;

--For student_records table:
--1
ALTER TABLE student_records
ADD COLUMN extra_credit_points DECIMAL(3,1);
--2
ALTER TABLE student_records
ALTER COLUMN grade TYPE VARCHAR(5);
--3
ALTER TABLE student_records
ALTER COLUMN extra_credit_points SET DEFAULT 0.0;
--4
ALTER TABLE student_records
ADD COLUMN final_exam_date DATE;
--5
ALTER TABLE student_records
DROP COLUMN last_updated;

--Part 4: Table Relationships and Management
--Task 4.1: Additional Supporting Tables 

--Table: departments
CREATE TABLE departments(
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget DECIMAL(20,2),
    established_year INT
);

--Table: library_books
CREATE TABLE library_books(
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price DECIMAL(10,2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

--Table: student_book_loans
CREATE TABLE student_book_loans(
    loan_id SERIAL PRIMARY KEY,
    student_id INT,
    book_id INT,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount DECIMAL(10,2),
    loan_status VARCHAR(20)
); 

--Task 4.2: Table Modifications for Integration

--1. Add foreign key columns
ALTER TABLE professors
ADD COLUMN department_id INT;

ALTER TABLE students
ADD COLUMN advisor_id INT;

ALTER TABLE courses
ADD COLUMN department_id INT;

--2 
--Table: grade_scale	
CREATE TABLE grade_scale(
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(5,2)
);

--Table: semester_calendar	
CREATE TABLE semester_calendar(
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN 
);

/* Part 5: Table Deletion and Cleanup 
Task 5.1: Conditional Table Operations*/

--1. Drop tables if	they exist:	
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale; 

--2 Recreat one	of the dropped tables with modified	structure:	
CREATE TABLE grade_scale(
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage DECIMAL(4,1),
    max_percentage DECIMAL(4,1),
    gpa_points DECIMAL(5,2),
    description TEXT
);

--3 Drop and recreate with CASCADE:	
DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar(
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INT,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

-- Task 5.2: Database Cleanup 

--1 Database operations:	

DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;
CREATE DATABASE university_backup TEMPLATE university_main;