--reforming db
-- adding new columns and filling it with values
alter table Products 
	add column p_id serial;
--filling
update Products
	set p_id = nextval('products_p_id_seq');

alter table Order_Items
	add column product_id int;
--filling
update Order_Items oi
	set product_id = p.p_id
	from Products p
	where oi.product_name = p.p_name;

alter table Order_Items
	add column price money;
--filling
update Order_Items oi
	set price = p.price
	from Products p
	where oi.product_name = p.p_name;

alter table Order_Items
	add column total money;
--filling
update Order_Items oi
	set total = amount * price;

--making not null
alter table Order_Items alter column product_id set not null;
alter table Order_Items alter column price set not null;
alter table Order_Items alter column total set not null;
alter table Products alter column p_name set not null;



--changing references
--deleting all unused references
alter table Order_Items
	drop constraint fk_productname_pname;
alter table Order_Items
	drop constraint order_items_pkey;
alter table Products
	drop constraint products_pkey;
-- deliting unused column
alter table Order_Items
	drop column product_name;
	
--adding new pks
alter table Products
	add constraint products_pkey primary key (p_id);
alter table Order_Items
	add constraint order_items_pkey primary key (order_id, product_id);

--adding new fk
alter table Order_Items
	add constraint fk_productid_pid
	foreign key (product_id) references Products(p_id);

--making p_name unique
alter table Products
    add constraint products_p_name_unique unique (p_name);

--check for total
alter table Order_Items
	add constraint chk_total_correct check (total = amount * price)

select * from Order_Items