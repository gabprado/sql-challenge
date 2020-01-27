USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

/* 
3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
as the difference between it and VARCHAR are significant). 
*/
DROP PROCEDURE IF EXISTS add_col_2_tbl;
DELIMITER //
CREATE PROCEDURE add_col_2_tbl ()
BEGIN
SELECT count(*) 
INTO @col_exists FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'sakila' AND TABLE_NAME = 'actor' AND COLUMN_NAME = 'description';
IF @col_exists = 0 THEN
ALTER TABLE actor ADD description BLOB;
ELSE
ALTER TABLE actor DROP description;
ALTER TABLE actor ADD description BLOB;
END IF;
SHOW COLUMNS FROM actor WHERE field = 'description';
END//
DELIMITER ;
CALL add_col_2_tbl();

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
DROP PROCEDURE IF EXISTS rem_col_4rm_tbl;
DELIMITER //
CREATE PROCEDURE rem_col_4rm_tbl ()
BEGIN
SELECT count(*) 
INTO @col_exists FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = 'sakila' AND TABLE_NAME = 'actor' AND COLUMN_NAME = 'description';
IF @col_exists != 0 THEN
ALTER TABLE actor DROP description;
END IF;
SHOW COLUMNS FROM actor WHERE field = 'description';
END//
DELIMITER ;
CALL rem_col_4rm_tbl();

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(actor_id) AS Actors_Having_LName
FROM actor
GROUP BY last_name
ORDER BY Actors_Having_LName DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(actor_id) AS Actors_Having_LName
FROM actor
GROUP BY last_name
HAVING Actors_Having_LName >= 2
ORDER BY Actors_Having_LName DESC;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'Williams' and first_name = 'GROUCHO';
-- Validate Results
SELECT first_name, last_name
From actor
WHERE last_name = 'Williams' and first_name IN ('HARPO', 'GROUCHO');
/* 
4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

** This implies that we are also filtering on Williams for the last name. **
*/
UPDATE actor
SET first_name = 'GROUCHO'
WHERE last_name = 'Williams' and first_name = 'HARPO';
-- Validate Results
SELECT first_name, last_name
From actor
WHERE last_name = 'Williams' and first_name IN ('HARPO', 'GROUCHO');

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- Results from command above.
CREATE TABLE IF NOT EXISTS address (
  `address_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL /*!80003 SRID 0 */,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
-- Used INNER JOIN intentionally as I do not want to show employees that do not have an address.
Select s.first_name, s.last_name, a.address
from staff s
INNER JOIN address a ON a.address_id = s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
-- Used LEFT JOIN as if a staff memeber did not ring up anybody I wanted to show that by the null in the Total_Rung_Up column.
SELECT CONCAT(s.first_name, ' ',s.last_name) AS Staff_Name, sum(p.amount) AS Total_Rung_Up 
FROM payment p
LEFT JOIN staff s ON s.staff_id = p.staff_id
WHERE p.payment_date BETWEEN '2005-08-01' AND '2005-08-31'
GROUP BY Staff_Name;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
Select f.title, count(fa.actor_id) AS Actor_Count
FROM film f
INNER JOIN film_actor fa ON fa.film_id = f.film_id
GROUP BY fa.film_id
ORDER BY Actor_Count DESC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title , count(i.film_id) AS Inventory_Count
FROM film f
INNER JOIN inventory i ON i.film_id = f.film_id
GROUP BY f.title
HAVING f.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
-- Used LEFT JOIN as if a customer did not pay anything I wanted to show that by the null in the Total_Paid column.
SELECT CONCAT(c.first_name, ' ',c.last_name) AS Customer, sum(p.amount) AS Total_Paid 
FROM payment p
LEFT JOIN customer c ON c.customer_id = p.customer_id
GROUP BY Customer, c.last_name
ORDER BY c.last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
-- 
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- 
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
-- 
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
-- 
-- 7e. Display the most frequently rented movies in descending order.
-- 
-- 7f. Write a query to display how much business, in dollars, each store brought in.
-- 
-- 7g. Write a query to display for each store its store ID, city, and country.
-- 
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
-- 
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
-- 
-- 8b. How would you display the view that you created in 8a?
-- 
-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.