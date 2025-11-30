--changing name
update Products
set p_name = 'product1'
where p_name = 'p1';

--deleting p2 from order = 1
delete from Order_Items
where order_id = 1 and product_id = (select p_id from Products where p_name = 'p2');

--deleting order = 2
delete from Order_Items
where order_id = 2;

delete from Orders
where o_id = 2;

-- Changing price
update Products
set price = 5
where p_name = 'product1';

update Order_Items oi
set price = p.price,
    total = amount * p.price
from Products p
where oi.product_id = p.p_id;

--adding order = 3
insert into Orders (order_date)
values (current_date);

insert into Order_Items (order_id, product_id, amount, price, total)
	values(
		currval('orders_o_id_seq'), 
    	(select p_id from Products where p_name = 'product1'),
    	3,
    	(select price from Products where p_name = 'product1'),
    	3 * (select price from Products where p_name = 'product1')
	);
select * from Products;
select * from Order_Items;
