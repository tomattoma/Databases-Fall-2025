create database transaction_module_KazFinance;

create table customers(
    customer_id serial primary key,
    iin char(12) unique not null,
    full_name varchar(120) not null,
    phone char(11),
    email varchar(100) unique,
    status varchar(30) default 'active' check(status in('active','blocked','frozen')),
    created_at timestamp with time zone not null default current_timestamp,
    daily_limit_kzt numeric(20,2) not null default 0.00 check (daily_limit_kzt >= 0)
);

create table accounts(
    account_id serial primary key,
    customer_id int not null references customers(customer_id) on delete restrict ,
    account_number char(20) unique not null check ( account_number like 'KZ%' and length(account_number) = 20),
    currency char(3) not null check(currency in( 'KZT','USD','EUR','RUB')),
    balance numeric(20,2) not null default 0.00 check(balance >= 0),
    is_active boolean not null default true,
    opened_at timestamp with time zone not null default current_timestamp,
    closed_at timestamp with time zone
    constraint check_is_active check((is_active=true and closed_at is null)
    or (is_active=false and closed_at is not null))
);

create table transactions(
    transaction_id serial primary key,
    from_account_id int not null references accounts(account_id) on delete restrict,
    to_account_id int not null references accounts(account_id) on delete restrict ,
    amount numeric(20,2) not null default 0.00 check(amount > 0),
    currency char(3) not null check(currency in( 'KZT','USD','EUR','RUB')),
    exchange_rate numeric(20,2) not null default 1.00,
    amount_kzt numeric(20,2) not null,
    type varchar(15) not null check(type in ('transfer','deposit','withdrawal')),
    status varchar(15) not null check(status in ('pending','completed','failed','reversed')),
    created_at timestamp with time zone not null default current_timestamp,
    completed_at timestamp with time zone,
    description varchar(120)
    constraint check_account check(from_account_id <> to_account_id)
);

create table exchange_rates(
    rate_id serial primary key,
    from_currency char(3) not null check(from_currency in( 'KZT','USD','EUR','RUB')),
    to_currency char(3) not null check(to_currency in( 'KZT','USD','EUR','RUB')),
    rate numeric(12,6) not null check(rate > 0),
    valid_from timestamp with time zone not null default current_timestamp,
    valid_to timestamp with time zone,
    constraint check_currency check(from_currency <> to_currency),
    constraint check_valid_from_to check (valid_to is null or valid_from < valid_to )
);

create table audit_log(
    log_id serial primary key,
    table_name varchar(120) not null,
    record_id bigint not null ,
    action varchar(20) not null check(action in('INSERT','UPDATE','DELETE')),
    old_values jsonb,
    new_values jsonb,
    changed_by varchar(120) not null,
    changed_at timestamp with time zone not null default current_timestamp,
    ip_address inet

);

drop table customers cascade ;
drop table accounts cascade ;

insert into customers (iin, full_name, phone, email, status, daily_limit_kzt)
values
('870501300001','Yelena Popova','87070000001','yelena.p@mail.kz','active',500000),
('901115400002','Madi Toktarov','87070000002','madi.t@mail.kz','active',300000),
('950320450003','Mira Alimova','87070000003','mira@example.com','blocked',0),
('940404300008','Timur Nurtas','87070000004','timur@example.com','active',150000),
('991212400005','Aigerim Serik','87070000005','aigerim@example.com','frozen',0),
('910725300006','Nursultan Auezov','87070000006','nurs@example.com','active',700000),
('850910400007','Kamila Sadykova','87070000007','kamila@example.com','active',250000),
('960818300010','Sanzhar Kaliyev','87070000008','sanzhar@example.com','active',400000),
('800101300004','Dana Seilkhan','87070000009','dana@example.com','active',300000),
('890606400009','Eldar Utegenov','87070000010','eldar@example.com','active',100000);

insert into accounts (customer_id, account_number, currency, balance, is_active)
values
(1,'KZ86125KZT5004100100','KZT',150000,true),
(1,'KZ55125USD5004100200','USD',500,true),
(2,'KZ01125KZT5004100300','KZT',75000,true),
(3,'KZ02125EUR5004100400','EUR',1200,true),
(4,'KZ03125KZT5004100500','KZT',90000,true),
(5,'KZ04125KZT5004100600','KZT',86432,true),
(6,'KZ05125USD5004100700','USD',1000,true),
(7,'KZ06125KZT5004100800','KZT',270000,true),
(8,'KZ07125KZT5004100900','KZT',45000,true),
(9,'KZ08125EUR5004101000','EUR',300,true);

insert into transactions
(from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description)
values
(5,3,20000,'KZT',1,20000,'transfer','completed','Monthly payment'),
(3,1,10000,'KZT',1,10000,'transfer','completed','Refund'),
(7,2,100,'USD',470,47000,'transfer','completed','USD purchase'),
(4,7,30000,'KZT',1,30000,'transfer','pending','Pending approval'),
(7,8,15000,'KZT',1,15000,'transfer','completed','Gift'),
(6,8,5000,'KZT',1.00,5000,'transfer','completed','Service payment'),
(9,1,50,'EUR',500,25000,'transfer','completed','Euro transfer'), -- ✔ Исправлено: было (9,10)
(2,1,200,'USD',470,94000,'withdrawal','failed','Insufficient funds'),
(3,4,5000,'KZT',1,5000,'transfer','completed','Utility bill'),
(7,3,100,'USD',470,47000,'deposit','completed','Top-up');

insert into exchange_rates (from_currency, to_currency, rate)
values
('USD','KZT',470.25),
('EUR','KZT',505.10),
('RUB','KZT',5.20),
('KZT','USD',0.0021),
('KZT','EUR',0.00197),
('KZT','RUB',0.19),
('USD','EUR',0.92),
('EUR','USD',1.08),
('USD','RUB',90.00),
('RUB','USD',0.011);

insert into audit_log (table_name, record_id, action, old_values, new_values, changed_by, ip_address)
values
('customers',1,'UPDATE','{"status":"active"}','{"status":"blocked"}','admin','192.168.1.10'),
('accounts',3,'INSERT',NULL,'{"balance":75000}','system','192.168.1.11'),
('transactions',5,'INSERT',NULL,'{"amount":15000}','system','192.168.1.12'),
('customers',3,'UPDATE','{"status":"active"}','{"status":"blocked"}','auditor','192.168.1.13'),
('accounts',6,'UPDATE','{"is_active":true}','{"is_active":false}','admin','192.168.1.14'),
('transactions',2,'UPDATE','{"status":"pending"}','{"status":"completed"}','processor','192.168.1.15'),
('exchange_rates',1,'UPDATE','{"rate":470.00}','{"rate":470.25}','rate_updater','192.168.1.16'),
('customers',8,'INSERT',NULL,'{"full_name":"Sanzhar Kaliyev"}','system','192.168.1.17'),
('transactions',9,'INSERT',NULL,'{"amount":5000}','system','192.168.1.18'),
('accounts',10,'UPDATE','{"balance":300}','{"balance":500}','system','192.168.1.19');

--Tasks
--Task 1: Transaction Management

/*function - > process_transfer
Handles money transfer between two accounts. Performs checks for account existence, status, balance, daily limit, and exchange rate.
Logs transaction in audit_log.
*/
create or replace function process_transfer(
    p_from_account_number char(20),
    p_to_account_number char(20),
    p_amount numeric(20,2),
    p_currency char(3),
    p_description varchar(120)
)
returns text
language plpgsql
as $$
declare
    from_acc accounts%rowtype;
    to_acc accounts%rowtype;
    from_cust customers%rowtype;

    rate_to_kzt numeric(12, 6);
    rate_for_debit numeric(12, 6);
    amount_kzt numeric(20, 2);
    amount_debit numeric(20, 2);
    today_total numeric(20, 2);

    tx_id bigint;

    v_json_data text;
    v_error_code char(3) := '000';
    v_error_message text;
begin

    begin

        if p_amount <= 0 or p_from_account_number = p_to_account_number then
            v_error_code := '400';
            raise exception using message = 'Invalid amount or same source/target account.';
        end if;

        select * into from_acc
        from accounts
        where account_number = p_from_account_number
        for update;
        if not found then
            v_error_code := '401';
            raise exception using message = 'Source account not found.';
        end if;

        select * into to_acc
        from accounts
        where account_number = p_to_account_number
        for update;
        if not found then
            v_error_code := '402';
            raise exception using message = 'Target account not found.';
        end if;

        if from_acc.is_active = false or to_acc.is_active = false then
            v_error_code := '403';
            raise exception using message = 'One or both accounts are inactive.';
        end if;

        select * into from_cust
        from customers
        where customer_id = from_acc.customer_id;

        if from_cust.status <> 'active' then
            v_error_code := '404';
            raise exception using message = 'Customer status is ' || from_cust.status || '.';
        end if;

        select rate into rate_to_kzt
        from exchange_rates
        where from_currency = p_currency and to_currency = 'KZT'
        and valid_to is null
        order by valid_from desc limit 1;

        if not found then
            v_error_code := '405';
            raise exception using message = 'Exchange rate ' || p_currency || '/KZT not found.';
        end if;
        amount_kzt := p_amount * rate_to_kzt;

        if p_currency = from_acc.currency then
            rate_for_debit := 1.0;
        else
            select rate into rate_for_debit
            from exchange_rates
            where from_currency = p_currency and to_currency = from_acc.currency
            and valid_to is null
            order by valid_from desc limit 1;

            if not found then
                v_error_code := '406';
                raise exception using message = 'Exchange rate ' || p_currency || '/' || from_acc.currency || ' not found.';
            end if;
        end if;
        amount_debit := p_amount * rate_for_debit;

        select coalesce(sum(amount_kzt), 0) into today_total
        from transactions
        where from_account_id = from_acc.account_id
          and type in ('transfer', 'withdrawal')
          and status = 'completed'
          and created_at::date = current_date;

        if today_total + amount_kzt > from_cust.daily_limit_kzt then
            v_error_code := '407';
            raise exception using message = 'Daily limit ' || from_cust.daily_limit_kzt || ' KZT exceeded.';
        end if;

        if from_acc.balance < amount_debit then
            v_error_code := '408';
            raise exception using message = 'Insufficient balance: ' || from_acc.balance || ' < ' || amount_debit || ' ' || from_acc.currency;
        end if;

        update accounts set balance = balance - amount_debit
        where account_id = from_acc.account_id;

        update accounts set balance = balance + p_amount
        where account_id = to_acc.account_id;

        insert into transactions(
            from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description
        )
        values(
            from_acc.account_id,
            to_acc.account_id,
            p_amount,
            p_currency,
            rate_to_kzt,
            amount_kzt,
            'transfer',
            'completed',
            p_description
        )
        returning transaction_id into tx_id;

        v_json_data := '{"amount": ' || p_amount ||
                       ', "from_acc": "' || p_from_account_number ||
                       '", "to_acc": "' || p_to_account_number ||
                       '", "status": "completed"}';

        insert into audit_log(
            table_name, record_id, action, new_values, changed_by
        ) values (
            'transactions',
            tx_id,
            'INSERT',
            v_json_data::jsonb,
            'process_transfer_sp'
        );

        return '000';

    exception
        when others then
            v_error_message := sqlerrm;

            v_json_data := '{"from_acc": "' || p_from_account_number ||
                           '", "to_acc": "' || p_to_account_number ||
                           '", "amount": ' || p_amount ||
                           ', "currency": "' || p_currency ||
                           '", "error_code": "' || v_error_code ||
                           '", "reason": "' || v_error_message || '"}';

            insert into audit_log(
                table_name, record_id, action, new_values, changed_by, ip_address
            ) values (
                'transactions',
                0,
                'INSERT',
                v_json_data::jsonb,
                'process_transfer_sp',
                '127.0.0.1'
            );

            return v_error_code;
    end;
end;
$$;

--Task 2
--View 1
create or replace view customer_balance_summary as
with current_rates as (
    select from_currency, rate
    from exchange_rates
    where to_currency = 'kzt' and valid_to is null
),
customer_totals as (
    select
        c.customer_id,
        c.full_name,
        c.daily_limit_kzt,
        sum(a.balance * coalesce(r.rate, 1)) as total_balance_kzt,
        coalesce(
            (select sum(t.amount_kzt)
             from transactions t
             join accounts ta on ta.account_id = t.from_account_id
             where ta.customer_id = c.customer_id
               and t.type in ('transfer','withdrawal')
               and t.status = 'completed'
               and t.created_at::date = current_date),0) as today_spending_kzt
    from customers c
    join accounts a on a.customer_id = c.customer_id
    left join current_rates r on a.currency = r.from_currency
    group by c.customer_id, c.full_name, c.daily_limit_kzt
)
select
    ct.customer_id,
    ct.full_name,
    ct.daily_limit_kzt,
    ct.total_balance_kzt,
    case when ct.daily_limit_kzt > 0
         then round(ct.today_spending_kzt / ct.daily_limit_kzt * 100, 2)
         else 0
    end as utilization_percentage,
    rank() over (order by ct.total_balance_kzt desc) as wealth_rank
from customer_totals ct;

--View 2
create or replace view daily_transaction_report as
with daily_aggregates as (
    select
        t.created_at::date as transaction_date,
        t.type,
        count(t.transaction_id) as transaction_count,
        sum(t.amount_kzt) as total_volume_kzt,
        avg(t.amount_kzt) as average_amount_kzt
    from transactions t
    where t.status = 'completed'
    group by t.created_at::date, t.type
)
select
    da.transaction_date,
    da.type,
    da.transaction_count,
    da.total_volume_kzt,
    da.average_amount_kzt,
    sum(da.total_volume_kzt) over (
        partition by da.type
        order by da.transaction_date
    ) as running_volume_total,
    round(
        (da.total_volume_kzt - coalesce(lag(da.total_volume_kzt) over (partition by da.type order by da.transaction_date),0))
        / nullif(coalesce(lag(da.total_volume_kzt) over (partition by da.type order by da.transaction_date),0),0) * 100,
        2
    ) as day_over_day_growth_pct
from daily_aggregates da
order by da.transaction_date desc, da.type;

--View 3
create or replace view suspicious_activity_view with (security_barrier) as
with transaction_kzt_value as (
    select
        t.transaction_id,
        t.from_account_id,
        t.created_at,
        t.amount_kzt,
        case when t.amount_kzt > 5000000 then true else false end as is_high_value,
        lag(t.created_at) over (partition by t.from_account_id order by t.created_at) as previous_tx_time
    from transactions t
    where t.type = 'transfer'
      and t.status = 'completed'
),
hourly_velocity as (
    select
        t.transaction_id,
        t.from_account_id,
        t.created_at,
        count(*) over (partition by t.from_account_id order by t.created_at range between interval '60 minutes' preceding and current row) as hourly_tx_count
    from transactions t
    where t.type = 'transfer'
      and t.status = 'completed'
)
select
    tkv.transaction_id,
    tkv.from_account_id,
    tkv.created_at,
    tkv.amount_kzt,
    tkv.is_high_value,
    case when hv.hourly_tx_count > 10 then true else false end as is_high_velocity,
    case when tkv.previous_tx_time is not null and tkv.created_at - tkv.previous_tx_time < interval '60 seconds' then true else false end as is_rapid_sequential
from transaction_kzt_value tkv
join hourly_velocity hv on tkv.transaction_id = hv.transaction_id
where tkv.is_high_value = true
   or hv.hourly_tx_count > 10
   or (tkv.previous_tx_time is not null and tkv.created_at - tkv.previous_tx_time < interval '60 seconds')
order by tkv.created_at desc;

--Task 3
select amount, currency, status, amount_kzt
from transactions
where from_account_id = 1
order by created_at desc
limit 10;

create index idx_covering_b_tree on transactions (
    from_account_id,
    created_at desc
) include (amount, currency, status, amount_kzt);

explain analyze
select *
from transactions
where from_account_id = 1
order by created_at desc
limit 10;
/*Index speeds up queries by avoiding a full table scan and using the covering index for faster access.*/

create index idx_accounts_active_lookup on accounts (account_number)
where is_active = true;
explain analyze
select balance, currency
from accounts
where account_number = 'KZ03125KZT5004100500'
and is_active = true;

create index idx_customers_email_lower on customers (lower(email));
explain analyze
select customer_id, full_name
from customers
where lower(email) = 'timur@example.com';

create index idx_audit_log_jsonb_gin on audit_log using gin (new_values);
explain analyze
select changed_at, changed_by, new_values
from audit_log
where table_name = 'accounts'
and new_values @> '{"balance": 0.00}'::jsonb;

create index idx_customers_iin_hash on customers using hash (iin);
explain analyze
select full_name, phone
from customers
where iin = '870501300001';

--Task4
create or replace function process_salary_batch(
    p_company_acc_num char(20),
    p_payments_array jsonb
)
returns jsonb
language plpgsql
as $$
declare
    v_company_acc accounts%rowtype;
    v_total_amount_required numeric(20, 2);

    v_payment jsonb;
    v_payment_count int := 0;

    v_successful_count int := 0;
    v_failed_count int := 0;

    v_failed_details jsonb[] := '{}';

    v_credit_list jsonb[] := '{}';

    v_employee_iin char(12);
    v_employee_amount numeric(20, 2);
    v_employee_acc_id int;

    v_error_code char(3);
    v_error_message text;
    v_lock_id bigint;
    v_temp_employee_currency char(3);
begin

    select * into v_company_acc
    from accounts
    where account_number = p_company_acc_num
    for update;

    if not found then
        return jsonb_build_object('status', 'ERROR', 'reason', 'Company account not found.', 'code', '401');
    end if;

    v_lock_id := v_company_acc.account_id;

    if not pg_try_advisory_lock(v_lock_id) then
        return jsonb_build_object('status', 'ERROR', 'reason', 'Concurrent batch processing is already running for this company.', 'code', '409');
    end if;

    v_total_amount_required := (
        select coalesce(sum((elem->>'amount')::numeric), 0)
        from jsonb_array_elements(p_payments_array) elem
    );

    if v_company_acc.balance < v_total_amount_required then
        perform pg_advisory_unlock(v_lock_id);
        return jsonb_build_object('status', 'ERROR', 'reason', 'Insufficient company balance for total batch amount.', 'code', '407');
    end if;


    for v_payment in select * from jsonb_array_elements(p_payments_array)
    loop
        v_payment_count := v_payment_count + 1;
        v_error_code := null;

        savepoint sp_payment_start;

        v_employee_iin := v_payment->>'iin';
        v_employee_amount := (v_payment->>'amount')::numeric;

        begin

            select a.account_id, a.currency
            into v_employee_acc_id, v_temp_employee_currency
            from accounts a
            join customers c on a.customer_id = c.customer_id
            where c.iin = v_employee_iin AND a.is_active = TRUE
            limit 1;

            if not found then
                v_error_code := '601';
                raise exception 'Employee IIN not found or account inactive.';
            end if;

            if v_company_acc.currency <> v_temp_employee_currency then
                 v_error_code := '602';
                 raise exception 'Currency mismatch (Company: % vs Employee: %)', v_company_acc.currency, v_temp_employee_currency;
            end if;

            if v_employee_amount <= 0 then
                v_error_code := '603';
                raise exception 'Invalid payment amount.';
            end if;

            v_credit_list := array_append(v_credit_list, jsonb_build_object(
                'account_id', v_employee_acc_id,
                'amount', v_employee_amount,
                'tx_description', v_payment->>'description'
            ));

            v_successful_count := v_successful_count + 1;

        exception
            when others then
                v_error_message := SQLERRM;
                v_failed_count := v_failed_count + 1;

                v_failed_details := array_append(v_failed_details, jsonb_build_object(
                    'iin', v_employee_iin,
                    'amount', v_employee_amount,
                    'error_code', coalesce(v_error_code, '999'),
                    'reason', v_error_message
                ));

                rollback to sp_payment_start;
        end;
    end loop;


    if v_successful_count > 0 then
        update accounts
        set balance = balance - v_total_amount_required
        where account_id = v_company_acc.account_id;

        for v_payment in select * from jsonb_array_elements(array_to_json(v_credit_list)::jsonb)
        loop
            v_employee_acc_id := (v_payment->>'account_id')::int;
            v_employee_amount := (v_payment->>'amount')::numeric;

            update accounts
            set balance = balance + v_employee_amount
            where account_id = v_employee_acc_id;

            insert into transactions (
                from_account_id, to_account_id, amount, currency, amount_kzt, type, status, description
            ) values (
                v_company_acc.account_id,
                v_employee_acc_id,
                v_employee_amount,
                v_company_acc.currency,
                v_employee_amount,
                'salary',
                'completed',
                v_payment->>'tx_description'
            );
        end loop;
    end if;


    perform pg_advisory_unlock(v_lock_id);

    return jsonb_build_object(
        'status', 'COMPLETED',
        'total_payments', v_payment_count,
        'successful_count', v_successful_count,
        'failed_count', v_failed_count,
        'failed_details', array_to_json(v_failed_details)::jsonb
    );

exception
    when others then
        perform pg_advisory_unlock(v_lock_id);
        return jsonb_build_object(
            'status', 'GLOBAL_ERROR',
            'reason', SQLERRM,
            'code', '999'
        );
end;
$$;

create materialized view salary_batch_report as
with tx_data as (
    select
        t.transaction_id,
        t.from_account_id as company_account_id,
        t.to_account_id as employee_account_id,
        t.amount,
        t.currency,
        t.status,
        t.description,
        c.full_name as employee_name,
        c.iin as employee_iin,
        t.created_at
    from transactions t
    join accounts a on a.account_id = t.to_account_id
    join customers c on c.customer_id = a.customer_id
    where t.type = 'salary'
)
select
    company_account_id,
    count(*) filter (where status = 'completed') as successful_count,
    count(*) filter (where status <> 'completed') as failed_count,
    sum(amount) filter (where status = 'completed') as total_paid,
    jsonb_agg(
        jsonb_build_object(
            'employee_iin', employee_iin,
            'employee_name', employee_name,
            'amount', amount,
            'status', status,
            'description', description,
            'created_at', created_at
        )
    ) as payments_details
from tx_data
group by company_account_id
order by company_account_id;

