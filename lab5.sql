--Name: Tomiris
--ID: 24B031626

-- Part 1: CHECK Constraints

-- Task 1.1: Basic CHECK Constraint
create table employees(
    employee_id integer,
    first_name varchar(120),
    last_name varchar(120),
    age integer check(age between 18 and 65),
    salary numeric check(salary>0)
);
-- check(age between 18 and 65) check that age between 18 annd 65
-- check(salary>0) check that salary is greater than 0

-- Task 1.2: Named CHECK Constraint
create table products_catalog(
    product_id int,
    product_name varchar(200),
    regular_price numeric,
    discount_price numeric,
    constraint valid_discount check (regular_price > 0 and discount_price > 0 and discount_price < regular_price)
);
--Task 1.3: Multiple Column CHECK
create table bookings(
    booking_id integer,
    check_in_date date,
    check_out_date date,
    num_guests integer,
    check(num_guests between 1 and 10),
    check(check_out_date > check_in_date)
);

--Task 1.4: Testing CHECK Constraints
insert into employees(employee_id, first_name, last_name, age, salary)
values ('1','Babette', 'Hyeon-suk',22, 250000),
       ('2','Evalyn','Baldwin',19,200000);
insert into employees(employee_id, first_name, last_name, age, salary)
values ('3','Olga','Caradoc',67, -100000); -- age > 65 and salary < 0

insert into products_catalog(product_id,product_name,regular_price,discount_price)
values ('1','K-pop albums',70000,7000),
       ('2','Manga', 9000, 1800);
insert into products_catalog(product_id,product_name,regular_price,discount_price)
values ('3','Lipstick', 3500, 4000); -- regular_price < discount_price

insert into bookings(booking_id,check_in_date,check_out_date,num_guests)
values ('1','2025-01-01','2025-06-23', 3),
       ('2','2024-04-30','2025-01-03', 7);
insert into bookings(booking_id,check_in_date,check_out_date,num_guests)
values ('3','2025-04-04','2024-04-04',5); -- check_in_date > check_out_date

-- Part 2: NOT NULL Constraints

-- Task 2.1: NOT NULL Implementation
create table customers(
    customer_id integer not null,
    email varchar(50) not null,
    phone char(11) null,
    registration_date date not null
);

-- Task 2.2: Combining Constraints
create table inventory(
    item_id integer not null,
    item_name text not null,
    quantity integer not null check (quantity >= 0),
    unit_price numeric not null check (unit_price > 0),
    last_updated timestamp not null
);

-- Task 2.3: Testing NOT NULL
insert into customers
values (1,'akadksk_qw@mail.ru',null,'2025-09-08'),
       (2,'asa_cdc@gmail.com','87718980976','2024-12-25');

insert into inventory
values (1,'apple',500,200,'2024-01-15 14:30:25');

insert into inventory
values (2,'chocolate',null, 9,'2025-03-03'); -- "inventory" violates the NOT NULL restriction

-- Part 3: UNIQUE Constraints

-- Task 3.1: Single Column UNIQUE
create table users(
    user_id integer,
    username text unique,
    email text unique,
    created_at timestamp
);

-- Task 3.2: Multi-Column UNIQUE
create table course_enrollments(
    enrollment_id integer,
    student_id integer,
    course_code text,
    semester text,
    unique (student_id,course_code,semester)
);

-- Task 3.3: Named UNIQUE Constraints
alter table users
add constraint unique_username unique (username),
add constraint unique_email unique (email);

insert into users
values (1,'Toma','appaapa@mmail.ru','2024-08-12'),
       (2,'Toma','sdkdkw@m.ru','2023-04-04');

-- Part 4: PRIMARY KEY Constraints

-- Task 4.1: Single Column Primary Key
create table departments(
    dept_id integer primary key,
    dept_name text not null,
    location text
);

insert into departments
values (1, 'IT', 'Tole bi 75'),
       (2, 'HR', 'Tole bi 45'),
       (3, 'Finance', 'Abay 100');

insert into departments
values (1, 'Marketing', 'Pushkin 50');

insert into departments
values (null, 'Marketing', 'Pushkin 50');

-- Task 4.2: Composite Primary Key
create table student_courses(
    student_id integer,
    course_id integer,
    enrollment_date date,
    grade text,
    primary key (student_id, course_id)
);
-- Task 4.3: Comparison Exercise
/*UNIQUE vs PRIMARY KEY:
PRIMARY KEY: Only one per table, cannot contain NULLs.
UNIQUE: Multiple allowed per table, can contain one NULL.
Single vs Composite PRIMARY KEY:
Single-column PK: Used when one column uniquely identifies a record.
Composite PK: Used when a combination of columns creates uniqueness.
One PRIMARY KEY but multiple UNIQUE constraints:
The PRIMARY KEY is the main identifier for a record.
UNIQUE constraints are for business rules that require uniqueness.*/

-- Part 5: FOREIGN KEY Constraints

-- Task 5.1: Basic Foreign Key
insert into employees_dept
values (1, 'Alice Smith', 1, '2023-01-15'),
       (2, 'Bob Johnson', 2, '2023-03-20'),
       (3, 'Carol Davis', 1, '2023-05-10');

insert into employees_dept
values (4, 'David Wilson', 34, '2023-07-01');

-- Task 5.2: Multiple Foreign Keys
create table authors(
    author_id integer primary key ,
    author_name text not null ,
    country text
);

create table publishers(
    publisher_id integer primary key ,
    publisher_name text not null ,
    city text
);

create table books(
    book_id integer primary key ,
    title text not null ,
    author_id integer references authors,
    publisher_id integer references publishers,
    publication_year integer,
    isbn text unique
);

insert into authors (author_id, author_name, country)
values  (1, 'Fyodor Dostoevsky', 'Russia'),
        (2, 'Jane Austen', 'United Kingdom'),
        (3, 'George Orwell', 'United Kingdom'),
        (4, 'Haruki Murakami', 'Japan'),
        (5, 'Gabriel Garcia Marquez', 'Colombia'),
        (6, 'Agatha Christie', 'United Kingdom');

insert into publishers (publisher_id, publisher_name, city)
values  (1, 'Penguin Classics', 'London'),
        (2, 'Vintage Books', 'New York'),
        (3, 'HarperCollins', 'New York'),
        (4, 'Progress Publishers', 'Moscow'),
        (5, 'Shinchosha', 'Tokyo'),
        (6, 'Editorial Sudamericana', 'Buenos Aires');

insert into books (book_id, title, author_id, publisher_id, publication_year, isbn)
values  (1, 'Crime and Punishment', 1, 1, 1866, '978-0143058144'),
        (2, 'The Brothers Karamazov', 1, 4, 1880, '978-0140449242'),
        (3, 'Pride and Prejudice', 2, 1, 1813, '978-0141439518'),
        (4, '1984', 3, 2, 1949, '978-0451524935'),
        (5, 'Animal Farm', 3, 2, 1945, '978-0451526342'),
        (6, 'Norwegian Wood', 4, 5, 1987, '978-0375704024'),
        (7, 'Kafka on the Shore', 4, 3, 2002, '978-1400079278'),
        (8, 'One Hundred Years of Solitude', 5, 6, 1967, '978-0060883287'),
        (9, 'Love in the Time of Cholera', 5, 3, 1985, '978-0307389732'),
        (10, 'Murder on the Orient Express', 6, 1, 1934, '978-0062693662'),
        (11, 'And Then There Were None', 6, 3, 1939, '978-0062073488');

-- Task 5.3: ON DELETE Options

create table categories(
    category_id integer primary key ,
    category_name text not null
);

create table products_fk(
    product_id integer primary key ,
    product_name text not null ,
    category_id integer references categories on delete restrict -- doesnt allow to delete if it has relation
);

create table orders(
    order_id integer primary key ,
    order_date date not null
);

create table order_items(
    item_id integer primary key ,
    order_id integer references orders on delete cascade , -- delete all
    product_id integer references products_fk,
    quantity integer check ( quantity > 0 )
);


insert into categories
values (1,'fruits'),
       (2,'sweets'),
       (3,'dairy');

insert into products_fk
values (1,'chocolate',2),
       (2,'banana',1),
       (3,'milk',3);

delete from categories
where category_id = 1; -- ERROR: UPDATE or DELETE in the "categories" table violates the restriction of the "products_fk_category_id_fkey" foreign key of the "products_fk" table

insert into orders
values (1,'2025-01-01'),
       (2,'2025-02-02'),
       (3,'2025-03-03'),
       (4,'2025-04-04');

insert into order_items
values (1,2,3,3),
       (2,1,2,10);

select * from order_items;

select * from orders;

delete from orders
where order_id = 1


-- Part 6: Practical Application

-- Task 6.1: E-commerce Database Design
create table customers(
    customer_id integer primary key ,
    name text not null ,
    email text unique not null ,
    phone text null ,
    registration_date date not null
);

create table products(
    product_id integer primary key ,
    name text not null ,
    description text,
    price integer not null ,
    stock_quantity integer not null ,
    check ( price > 0 and stock_quantity > 0 )
);

create table orders(
    order_id integer primary key ,
    customer_id integer references customers on delete restrict ,
    order_date date not null ,
    total_amount integer not null ,
    status text check (  status ='pending'
                or status ='processing'
                or status ='shipped'
                or status = 'delivered'
                or status = 'cancelled' )
);

create table order_details(
    order_detail_id integer primary key ,
    order_id integer references orders on delete cascade ,
    product_id integer references products on delete restrict ,
    quantity integer check ( quantity > 0 ) not null ,
    unit_price integer not null
);

insert into customers (customer_id, name, email, phone, registration_date)
values  (1, 'Alice Johnson', 'alice.johnson@email.com', '+77011234567', '2024-01-15'),
        (2, 'Bob Smith', 'bob.smith@email.com', '+77017654321', '2024-01-16'),
        (3, 'Carol Davis', 'carol.davis@email.com', NULL, '2024-01-17'),
        (4, 'David Wilson', 'david.wilson@email.com', '+77019876543', '2024-01-18'),
        (5, 'Eva Brown', 'eva.brown@email.com', '+77015556677', '2024-01-19');

insert into products (product_id, name, description, price, stock_quantity)
values  (1, 'ASUS Laptop', 'Gaming laptop 16GB RAM', 1000, 10),
        (2, 'Logitech Mouse', 'Wireless optical mouse', 25, 50),
        (3, 'Razer Keyboard', 'Mechanical keyboard', 80, 30),
        (4, 'Samsung Monitor', '27-inch 4K monitor', 400, 15),
        (5, 'Sony Headphones', 'Noise-cancelling headphones', 150, 25),
        (6, 'Xiaomi Smartphone', 'Smartphone 128GB', 300, 20);

insert into orders (order_id, customer_id, order_date, total_amount, status)
values  (1, 1, '2024-01-20', 1025, 'pending'),
        (2, 2, '2024-01-21', 105, 'processing'),
        (3, 3, '2024-01-22', 480, 'shipped'),
        (4, 1, '2024-01-23', 150, 'delivered'),
        (5, 4, '2024-01-24', 80, 'cancelled');

insert into order_details (order_detail_id, order_id, product_id, quantity, unit_price)
values  (1, 1, 1, 1, 1000),
        (2, 1, 2, 1, 25),
        (3, 2, 2, 1, 25),
        (4, 2, 3, 1, 80),
        (5, 3, 4, 1, 400),
        (6, 3, 2, 2, 25),
        (7, 4, 5, 1, 150),
        (8, 5, 3, 1, 80);
