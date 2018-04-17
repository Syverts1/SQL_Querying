use sakila;

#1a. Display the first and last names of all actors from the table actor.
SELECT actor.first_name, actor.last_name FROM actor;

/*1b. Display the first and last name of each actor 
in a single column in upper case letters. Name the column Actor Name.*/
SELECT UPPER(actor.first_name) as `Actor Name` FROM actor
UNION ALL
select UPPER(actor.last_name) FROM actor;

/*2a. You need to find the ID number, first name, 
and last name of an actor, of whom you know only the first name, "Joe." 
What is one query would you use to obtain this information? */
SELECT * FROM actor
WHERE actor.first_name='JOE';

#2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE actor.last_name LIKE '%GEN%';

/*2c. Find all actors whose last names contain the letters LI.
This time, order the rows by last name and first name, in that order*/
SELECT * FROM actor
WHERE actor.last_name LIKE '%LI%'
ORDER BY actor.last_name, actor.first_name ASC;

/*2d. Using IN, display the country_id and country columns
of the following countries: Afghanistan, Bangladesh, and China*/
SELECT country.country_id, country.country from country
WHERE country.country IN ("Afghanistan","Bangladesh","China");

/*3a. Add a middle_name column to the table actor. 
Position it between first_name and last_name. 
Hint: you will need to specify the data type.*/
alter table actor
add middle_name varchar(45) after first_name;

select * from actor;

/*3b. You realize that some of these actors have tremendously long last names.
Change the data type of the middle_name column to blobs.*/
alter table actor
modify middle_name blob;

#3c. Now delete the middle_name column.
alter table actor
drop middle_name;

select * from actor;

#4a. List the last names of actors, as well as how many actors have that last name.
select actor.last_name, count(actor.last_name) from actor
group by actor.last_name;

/*4b. List last names of actors and the number of actors who have that last name,
 but only for names that are shared by at least two actors*/
select actor.last_name, count(actor.last_name) from actor
group by actor.last_name
having count(actor.last_name)>1;

/*4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table
as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. 
Write a query to fix the record.*/
#find actor_id for groucho williams
select * from actor
where actor.first_name="groucho" AND actor.last_name="williams";

#update actor first name to harpo for groucho williams
update actor
set actor.first_name="HARPO"
where actor_id=172;

#confirm that it was changed correctly
select * from actor
where actor_id=172;


/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! 
In a single query, if the first name of the actor is currently HARPO, 
change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, 
as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
(Hint: update the record using a unique identifier.)*/

update actor
set actor.first_name=
	CASE WHEN actor.first_name="HARPO"
    THEN "GROUCHO"
    ELSE "MUCHO GROUCHO"
    END
where actor.first_name="HARPO";

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

show create table address;

/*6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
Use the tables staff and address*/
select s.first_name, s.last_name, a.address from staff as s
left join address as a on s.address_id = a.address_id;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment.*/

select s.staff_id, s.first_name, s.last_name, sum(p.amount) as total_amount from staff as s
join payment as p on s.staff_id=p.staff_id
where month(p.payment_date)=8 AND year(p.payment_date)=2005
group by p.staff_id;

/*6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join.*/
select f.film_id,f.title, count(fa.film_id) as actor_count from film as f
join film_actor as fa on f.film_id=fa.film_id
group by f.film_id;

/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
select f.film_id,f.title, count(i.film_id) as count from film as f
join inventory as i on f.film_id=i.film_id
where f.title="Hunchback Impossible";

/*6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
 List the customers alphabetically by last name*/

select c.customer_id, c.first_name, c.last_name, sum(p.amount) as total_paid from customer as c
join payment as p on p.customer_id=c.customer_id
group by p.customer_id
order by c.last_name asc;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q have also 
soared in popularity. Use subqueries to display the titles of movies starting 
with the letters K and Q whose language is English.*/
select film.title from film 
where film.title like "K%" OR film.title like "Q%" AND film.language_id=
	(select language.language_id from language where language.name="English");


#7b. Use subqueries to display all actors who appear in the film Alone Trip.
select film_actor.film_id,actor.actor_id,actor.first_name,actor.last_name from film_actor
join actor on actor.actor_id=film_actor.actor_id
where film_actor.film_id =
    (select film.film_id from film where film.title= "Alone Trip");
    
/*7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all 
Canadian customers. Use joins to retrieve this information.*/
select c.customer_id,c.first_name, c.last_name,c.email, country.country_id from customer as c
left join address as a on c.address_id=a.address_id
left join city on city.city_id=a.city_id
left join country on country.country_id=city.country_id
where country.country="Canada";

/*7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films.*/

select f.*, cat.name as category from category as cat
left join film_category as fc on cat.category_id=fc.category_id
left join film as f on fc.film_id=f.film_id
where cat.name="Family";

#7e. Display the most frequently rented movies in descending order.
select i.film_id, f.title, count(r.rental_id) as num_rentals from rental as r
left join inventory as i on r.inventory_id=i.inventory_id
left join film as f on i.film_id=f.film_id
group by i.film_id
order by count(r.rental_id);

#7f. Write a query to display how much business, in dollars, each store brought in.
select * from sales_by_store;

#7g. Write a query to display for each store its store ID, city, and country.
select s.store_id,city.city,country.country from store as s
left join address as a on s.address_id=a.address_id
left join city on a.city_id=city.city_id
left join country on country.country_id=city.country_id;

/*7h. List the top five genres in gross revenue in descending order.
 (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
select * from sales_by_film_category as s
order by s.total_sales asc
limit 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
 Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/
create view top_5_genres as
select * from sales_by_film_category as s
order by s.total_sales asc
limit 5;

#8b. How would you display the view that you created in 8a?
select * from top_5_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_5_genres;