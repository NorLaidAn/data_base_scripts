select * from actor;
select * from address;
select * from category;
select * from city;
select * from country;
select * from customer;
select * from film;
select * from film_actor;
select * from film_category;
select * from inventory;
select * from language;
select * from payment;
select * from rental;
select * from staff;
select * from store;



/* 1. Write a query that will return for each year the most popular rental film among films released in
one year. */
select release_year, title, rents --some titles of same year have same rent amount
from (
    select title, release_year, count(r.rental_id) rents
    from 
		film f
    inner join
		inventory i using(film_id)
    inner join 
		rental r on i.inventory_id = r.inventory_id
    group by 
		title, release_year
) t1
where rents = (
    select max(inner_c)
    from (
        select count(r2.rental_id) inner_c
        from 
			film f2
        inner join 
			inventory i2 using(film_id)
        inner join 
			rental r2 on i2.inventory_id = r2.inventory_id
        where f2.release_year = t1.release_year
        group by f2.film_id
    ) 
)
order by release_year



/* 2. Write a query that will return the Top-5 actors who have appeared in Comedies more than anyone
else. */
select first_name, last_name, count(title) c
from
	actor a
inner join
	film_actor fa using(actor_id)
inner join
	film f using(film_id)
inner join
	film_category fc using(film_id)
inner join
	category c on c.category_id  = fc.category_id and c.name = 'Comedy'
group by first_name, last_name
order by c desc
limit(5)



/* 3. Write a query that will return the names of actors who have not starred in “Action” films. */
select first_name, last_name
from
	actor a
inner join
	film_actor fa using(actor_id)
inner join
	film f using(film_id)
inner join
	film_category fc using(film_id)
inner join
	category c on c.category_id  = fc.category_id and c.name != 'Actor'
group by first_name, last_name
order by first_name, last_name



/* 4. Write a query that will return the three most popular rental films by each genre. */
/*select f.title, c.name, count(r.rental_id) rental_count
from
	film f
inner join
	inventory i using(film_id)
inner join
	rental r using(inventory_id)
left join
	film_category fc using(film_id)
left join
	category c using(category_id)
where f.film_id in (
        select f2.film_id
		from
			film f2
		inner join
			inventory i2 using(film_id)
		inner join
			rental r2 using(inventory_id)
		left join
			film_category fc2 using(film_id)
		left join
			category c2 using(category_id)
        group by f2.film_id
        order by count(r2.rental_id) desc
        limit 3
)
group by f.title, c.name
order by c.name, rental_count desc;*/



/*  5. Calculate the number of films released each year and cumulative total by the number of films.  */
select
    f1.release_year,
    count(film_id) films_per_year,
    (
        select count(film_id)
        from film f2
        where f2.release_year <= f1.release_year
    ) cumulative_total
from film f1
group by f1.release_year
order by f1.release_year;



/* 6. Calculate a monthly statistic based on “rental_date” field from “Rental” table that for each month
will show the percentage of “Animation” films from the total number of rentals.  */
select t1, t2, t1.c2 total, t2.c2 ainm, (t2.c2::decimal / t1.c2) * 100 percentage
from
	(select
		extract(year from rental_date)  y,
	    extract(month from rental_date) m,
		count(film_id) c2
	from
		film f
	inner join
		inventory i using(film_id)
	inner join
		rental r using(inventory_id)
	inner join
		film_category fc using(film_id)
	inner join
		category c using(category_id)
	
	group by y, m
	order by y, m) t1
left join
	(select 
		extract(year from r.rental_date)  y,
	    extract(month from r.rental_date) m,
		count(film_id) c2
	from
		film f
	inner join
		inventory i using(film_id)
	inner join
		rental r using(inventory_id)
	inner join
		film_category fc using(film_id)
	inner join
		category c on c.category_id  = fc.category_id and c.name = 'Animation'
	group by y, m) t2
	on t1.y = t2.y and t1.m = t2.m
order by t1.y, t1.m;



/* 7. Write a query that will return the names of actors who have starred in “Action” films more than in
“Drama” film. */
select t1.first_name, t1.last_name
from
	(select first_name, last_name, count(film_id) c2 -- action
	from
		actor a
	inner join
		film_actor fa using(actor_id)
	inner join
		film f using(film_id)
	inner join
		film_category fc using(film_id)
	inner join
		category c on c.category_id  = fc.category_id and c.name = 'Action'
	group by first_name, last_name
	order by first_name, last_name) t1
inner join 
	(select first_name, last_name, count(film_id) c2 -- drama
	from
		actor a
	inner join
		film_actor fa using(actor_id)
	inner join
		film f using(film_id)
	inner join
		film_category fc using(film_id)
	inner join
		category c on c.category_id  = fc.category_id and c.name = 'Drama'
	group by first_name, last_name
	order by first_name, last_name)t2 on t1.first_name = t2.first_name and t1.last_name = t2.last_name
where t1.c2 > t2.c2



/* 8. Write a query that will return the top-5 customers who spent the most money watching Comedies. */
select first_name, last_name, sum(amount) s
from
	customer cus
inner join
	payment p using(customer_id)
inner join
	rental r using(rental_id)
inner join
	inventory i using(inventory_id)
inner join
	film f using(film_id)
inner join
	film_category fc using(film_id)
inner join
	category cat on cat.category_id  = fc.category_id and cat.name = 'Comedy'
group by cus.first_name, cus.last_name
order by s desc
limit(5)



/* 9. In the “Address” table, in the “address” field, the last word indicates the "type" of a street: Street,
Lane, Way, etc. Write a query that will return all "types" of streets and the number of addresses
related to this "type" */
select split_part(address, ' ', 3) typ,  count(address)
from address
group by typ


	
/* 10. Write a query that will return a list of movie ratings, indicate for each rating the total number of
films with this rating, the top-3 categories by the number of films in this category and the number of
films in this category with this rating. */
/*select f.rating, count(film_id), cat1.name, cat2.name, cat3.name
from film f
left join (
	select c.name, count(category_id), f2.rating
	from 
		film f2
	inner join
		film_category using(film_id)
	inner join
		category c using(category_id)
	group by c.name, f2.rating
	limit 1) cat1 on f.rating = cat1.rating
left join
	(select c.name, count(category_id), f3.rating
	from 
		film f3
	inner join
		film_category using(film_id)
	inner join
		category c using(category_id)
	group by c.name, f3.rating
	offset 1
	limit 1) cat2 on f.rating = cat2.rating
left join
	(select c.name, count(category_id), f4.rating
	from 
		film f4
	inner join
		film_category using(film_id)
	inner join
		category c using(category_id)
	group by c.name, f4.rating
	offset 2
	limit 1) cat3 on f.rating = cat3.rating
group by f.rating, cat1.name, cat2.name, cat3.name*/


