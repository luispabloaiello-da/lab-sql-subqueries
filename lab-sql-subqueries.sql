-- ==================================================
-- SETTING UP THE DATABASE
-- ==================================================

-- Setting the working database
USE sakila;

-- Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
select I.film_id, count(*) as 'count' from sakila.inventory as I
group by I.film_id
having I.film_id = (select F.film_id from sakila.film as F where F.title in('Hunchback Impossible'));

-- List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT F.title, F.length
FROM sakila.film AS F
WHERE F.length > (SELECT AVG(length) FROM sakila.film)
ORDER BY F.length DESC;


-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT CONCAT(A.first_name, ' ' , A.last_name) as actor_full_name
FROM sakila.actor as A
WHERE A.actor_id IN (
	SELECT FC.actor_id from sakila.film_actor as FC
	JOIN sakila.film as F
	ON FC.film_id = F.film_id
	WHERE F.title in ("Alone Trip")
);

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
select * from sakila.category;
select * from sakila.film_category;
select * from sakila.film;

SELECT F.title
FROM sakila.film as F
WHERE F.film_id IN (
	SELECT FC.film_id from sakila.film_category as FC
    JOIN sakila.category as C
    ON FC.category_id = C.category_id
    WHERE C.name in ('Family')
);

-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.

SELECT C.first_name, C.email 
	FROM sakila.customer as C
    JOIN sakila.address AS A 
    ON C.address_id = A.address_id
	WHERE A.city_id IN (
		SELECT City.city_id FROM sakila.city as City
		JOIN sakila.country as Ctry
		ON City.country_id = Ctry.country_id
		WHERE Ctry.country  IN ('Canada')
		);
        
SELECT C.first_name, C.email 
	FROM sakila.customer as C
    WHERE C.address_id IN (
		SELECT A.address_id 
		FROM sakila.address AS A 
		WHERE A.city_id IN (
			SELECT City.city_id FROM sakila.city as City
			JOIN sakila.country as Ctry
			ON City.country_id = Ctry.country_id
			WHERE Ctry.country IN ('Canada')
			)
		);

/*
SELECT C.first_name, C.email 
FROM sakila.customer as C
JOIN sakila.address AS A ON C.address_id = A.address_id
	JOIN sakila.city as City ON A.city_id = City.city_id
		JOIN sakila.country as Ctry ON City.country_id = Ctry.country
			WHERE Ctry.country IN ('Canada');
*/

-- Determine which films were starred by the most prolific actor in the Sakila database. 
-- A prolific actor is defined as the actor who has acted in the most number of films. 
-- First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
    
SELECT f.title FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
					SELECT actor_id 
					FROM sakila.film_actor 
					GROUP BY actor_id 
					ORDER BY COUNT(film_id) DESC limit 1
                    );

-- Most prolific actor last name in the Sakila database.
SELECT A.last_name, A.actor_id,  COUNT(FA.film_id) AS films_actor
FROM sakila.film_actor AS FA
JOIN sakila.actor AS A
ON FA.actor_id = A.actor_id
GROUP BY FA.actor_id 
ORDER BY films_actor DESC limit 1;

-- -- Most prolific actor counting the number of movies
SELECT COUNT(film_id) AS films_actor, actor_id 
FROM sakila.film_actor 
GROUP BY actor_id 
ORDER BY films_actor DESC limit 1;
    
-- Find the films rented by the most profitable customer in the Sakila database. 
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.

SELECT F.title
FROM sakila.film AS F
JOIN sakila.inventory AS I ON F.film_id = I.film_id
JOIN sakila.rental AS R ON I.inventory_id = R.inventory_id
JOIN sakila.payment AS P ON R.rental_id = P.rental_id
WHERE R.customer_id = (
	SELECT P.customer_id 
	FROM sakila.payment AS P
	GROUP BY P.customer_id
	ORDER BY sum(P.amount) DESC 
    LIMIT 1
    );

-- To find the most profitable customer from sakila.payments
SELECT sum(P.amount) AS total, P.customer_id 
FROM sakila.payment AS P
GROUP BY P.customer_id
ORDER BY total DESC limit 1;

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. 
-- You can use subqueries to accomplish this.

SELECT customer_id, SUM(amount) AS total_spent 
FROM payment 
GROUP BY customer_id 
HAVING total_spent > (
	SELECT AVG(total_customer) 
	FROM (
		SELECT SUM(amount) AS total_customer 
		FROM payment 
		GROUP BY customer_id) AS totals);

-- Separate each SELECT to verify the output
SELECT SUM(amount) AS total_customer 
		FROM payment 
		GROUP BY customer_id;

SELECT AVG(total_customer) 
	FROM (
		SELECT SUM(amount) AS total_customer 
		FROM payment 
		GROUP BY customer_id) AS totals;
        
-- My original query
        
SELECT customer_id, sum(amount), ROUND(AVG(amount),2) AS 'Average' FROM sakila.payment
GROUP BY customer_id
HAVING Average > (SELECT ROUND(AVG(amount)) AS 'Average1' FROM sakila.payment)
ORDER BY Average DESC;
