create database lab10;

-- 3. Practical Tasks
-- 3.1 Setup: Create Test Database
 CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
 );
 CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
 );-- Insert test data
 INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);
 INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

-- 3.2 Task 1: Basic Transaction with COMMIT
begin;
update accounts set balance = balance - 50
where name = 'Alice';
update accounts set balance = balance + 50
where name = 'Bob';
commit;

-- 3.3 Task 2: Using ROLLBACK
begin;
update accounts set balance = balance - 30
where name = 'Bob';
select * from accounts where name = 'Bob';
rollback;

-- 3.4 Task 3: Working with SAVEPOINTs
begin;
update accounts set balance = balance - 50
where name = 'Alice';
savepoint my_savepoint;
update accounts set balance = balance + 50
where name = 'Bob';-- oops, should  transfer to Wally instead
rollback  to my_savepoint;
update  accounts set balance = balance + 50
where name = 'Wally';
commit;

-- 3.5 Task 4: Isolation Level Demonstration
--scenario A
-- terminal 1
begin transaction isolation level read committed;
select * from products where shop = 'joe''s shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
select * from products where shop = 'joe''s shop';
commit;
-- terminal 2
begin;
delete from products where shop = 'joe''s shop';
insert into products (shop, product, price)
values ('joe''s shop', 'fanta', 3.50);
commit;
--scenario B
-- terminal 1
begin transaction isolation level serializable;
select * from products where shop = 'joe''s shop';
-- Wait for Terminal 2 to make changes and COMMIT
-- Then re-run:
select * from products where shop = 'joe''s shop';
commit;
-- terminal 2
begin;
delete from products where shop = 'joe''s shop';
insert into products (shop, product, price)
values ('joe''s shop', 'fanta', 3.50);
commit;

-- 3.6 Task 5: Phantom Read Demonstration
-- terminal 1
begin transaction isolation level repeatable read;
select max(price), min(price) from products
where shop = 'joe''s shop';
-- Wait for Terminal 2
select max(price), min(price) from products
where shop = 'joe''s shop';
commit;
-- terminal 2
begin;
insert into products (shop, product, price)
values ('joe''s shop', 'sprite', 4.00);
commit;

-- 3.7 Task 6: Dirty Read Demonstration
begin transaction isolation level read uncommitted;
select * from products where shop = 'joe''s shop';
-- wait for terminal 2 to update but not commit
select * from products where shop = 'joe''s shop';
-- wait for terminal 2 to rollback
select * from products where shop = 'joe''s shop';
commit;

-- terminal 2
begin;
update products set price = 99.99
where product = 'fanta';
-- wait here (don't commit yet)
-- then:
rollback;