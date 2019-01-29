Use sakila;

-- 1a. Display the first and last names of all actors from the table actor.


Select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(UPPER(first_name), " " , UPPER(last_name)) as "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

Select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:

Select first_name, last_name from actor
WHERE last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:

Select last_name, first_name from actor
WHERE last_name LIKE '%LI%';

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
-- so create a column in the table actor named description and use the data type BLOB

ALTER TABLE actor
ADD COLUMN description BLOB;

Select * from actor;

-- 3b. Very quickly you realize that entering descriptions 
-- for each actor is too much effort. Delete the description column.

alter TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

Select last_name, count(last_name) as "Number" from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors

Select last_name, count(last_name) as "Number"
from actor
group by last_name
Having count(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS
-- Write a query to fix the record.

Select * from actor where first_name = "Groucho";

update actor
set first_name = "Harpo"
where first_name = "Groucho" and last_name = "Williams";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO

update actor
set first_name = "GROUCHO"
where first_name = "Harpo" and last_name = "Williams";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?


SHOW COLUMNS from sakila.address;
select * from address;
SHOW CREATE TABLE sakila.address;

CREATE TABLE `address_replacement` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
    KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=605 DEFAULT CHARSET=utf8
;

select * from address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:

select * from address;

SHOW COLUMNS from sakila.staff;

SELECT first_name, last_name, address from staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member
-- in August of 2005. Use tables staff and payment.

Select * from staff;

SELECT staff.staff_id, first_name, last_name, SUM(amount) as "Total Amount Rung Up"
FROM staff 
INNER JOIN payment  
ON staff.staff_id = payment.staff_id
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables film_actor and film. Use inner join.

select * from film_actor;
select * from film;


Select f.title, COUNT(fa.actor_id) as "Number of Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id = fa.film_id
GROUP BY f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select * from inventory;
select * from film;

Select f.title, count(f.title) as "Number of Copies"
FROM film f
inner join inventory i 
on f.film_id = i.film_id
group by title
having title = "Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by 
-- each customer. List the customers alphabetically by last name:

select * from payment;
select * from customer;


Select  c.first_name, c.last_name, SUM(p.amount) as "Total Payments"
from customer c 
inner join payment p 
on c.customer_id = p.customer_id
group by p.customer_id
order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared
-- in popularity. Use subqueries to display the titles of movies starting with the letters 
-- K and Q whose language is English.

select * from film;
select * from language;

-- Select f.title, l.name as "Lanuage"
-- FROM film f 
-- INNER JOIN language l 
-- ON f.language_id = l.language_id
-- HAVING (title LIKE "K%") OR (title like "Q%");

Select title from film
where language_id in
(select language_id from language
where name = "English")
AND (title LIKE "K%") OR (title like "Q%");

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select * from film_actor;
Select * from film;
select * from actor;

Select first_name, last_name from actor
where actor_id in 
	(Select actor_id from film_actor
		where film_id in
			(select film_id from film
				where title = "Alone Trip"))
;

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the
-- names and email addresses of all Canadian customers. Use joins to retrieve this information.

select * from country;
select * from customer;
select * from address;
select * from city;

Select c.first_name, c.last_name, c.email from customer c 
inner join address a 
on c.address_id =  a.address_id
inner join city ci 
on ci.city_id = a.city_id
inner join country co
on ci.country_id = co.country_id 
where country = "Canada";

-- 7d. Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as family films.

select * from category;
select * from film_category;
SELECT * from film;

SELECT title from film
where film_id in
	(SELECT film_id from film_category
	where category_id in
		(SELECT category_id from category
        where name = "Family"));

-- 7e. Display the most frequently rented movies in descending order.

SELECT f.title , COUNT(r.rental_id) AS "Number of Rentals" FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r 
ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY COUNT(r.rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in. 
select * from payment;
select * from staff;

Select st.store_id, SUM(p.amount) as "Total Revenue" from payment p
inner join staff st 
on st.staff_id = p.staff_id
group by st.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select * from store;
select * from city;
select * from country;
select * from address;

Select s.store_id, c.city, co.country from store s
inner join address a 
on s.address_id = a.address_id
inner join city c 
on a.city_id = c.city_id
inner join country co 
on c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, 
-- inventory, payment, and rental.)

select * from category;
select * from film_category;
select * from inventory;
select * from payment;
select * from rental;

Select c.name as "Genre", SUM(p.amount) as "Gross Revenue" from category c 
inner join film_category f 
on c.category_id = f.category_id
inner join inventory i 
on f.film_id = i.film_id 
inner join rental r 
on i.inventory_id = r.inventory_id 
inner join payment p 
on r.rental_id = p.rental_id
group by name
order by sum(p.amount) desc
limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view top_5_genres as
Select c.name as "Genre", SUM(p.amount) as "Gross Revenue" from category c 
inner join film_category f 
on c.category_id = f.category_id
inner join inventory i 
on f.film_id = i.film_id 
inner join rental r 
on i.inventory_id = r.inventory_id 
inner join payment p 
on r.rental_id = p.rental_id
group by c.name
order by sum(p.amount) desc
limit 5;

-- 8b. How would you display the view that you created in 8a?

Select * from top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW if exists top_5_genres;