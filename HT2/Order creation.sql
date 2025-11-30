drop table if exists Order_Items cascade;
drop table if exists Orders cascade;
drop table if exists Products cascade;
-- To make it rerunable

-- Table creation
create table Orders (
    o_id serial primary key,
    order_date date not null
);

create table Products (
    p_name text primary key,
    price money not null
);

create table Order_Items (
    order_id int not null,
    product_name text not null,
    amount numeric(7,2) not null default 1 check (amount > 0),
    primary key(order_id, product_name)
);


--References creation between tables
Alter table Order_Items
	add constraint fk_orderid_oid
	foreign key (order_id) references Orders(o_id);
Alter table Order_Items
	add constraint fk_productname_pname
	foreign key (product_name) references Products(p_name);


-- Adding some data
insert into Orders (order_date)
values 
    ('2025-01-01'),
    ('2025-01-02');

insert into Products (p_name, price)
values
    ('p1', 10.00),
    ('p2', 20.00);

--default amount = 1
insert into Order_Items (order_id, product_name)
values
    (1, 'p1'),
    (1, 'p2');

insert into Order_Items (order_id, product_name, amount)
values
    (2, 'p1', 3),
    (2, 'p2', 5);

select * From Order_Items
