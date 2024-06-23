SELECT * FROM employee;

Q1: Who is the senior most employee based on job title?
	
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

Q2: Which countries have the most invoices?

SELECT billing_country,COUNT(*) as invoice_count FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

Q3: WHat are top 3 values of total invoice?

SELECT total FROM invoice ORDER BY total DESC LIMIT 3;

Q4: Which city has the best customers? We would like to throw a promotional Music 
	Festival in the city we made the most money.Write a query that returns one city
    that has the highest num of invoice totals.Return both the city & sum of all 
	invoice totals?

SELECT billing_city,SUM(total) as total_sale 
FROM invoice 
GROUP BY billing_city 
ORDER BY total_sale DESC 
LIMIT 1;

Q5: Who is the best customer? The customer who has spent the most money will be declared
the best customer.Write a query that returns the person who has spent the most money.

WITH t1 as(
	SELECT customer_id,SUM(total) as total_spent
	FROM invoice 
	GROUP BY customer_id
	ORDER BY total_spent DESC 
	LIMIT 1
)SELECT * FROM customer 
 INNER JOIN t1 ON customer.customer_id=t1.customer_id;


Question Set 2

Q1: Write query to return the email,first name,last name & Genre
of all Rock Music listeners.Return your list ordered alphabetically
by email starting with A.


SELECT DISTINCT email,first_name,last_name FROM customer c1 
INNER JOIN invoice ON c1.customer_id=invoice.customer_id
INNER JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
WHERE track_id IN (
	SELECT track_id FROM track
    INNER JOIN genre
	ON track.genre_id=genre.genre_id
	AND genre.name='Rock'
) ORDER BY first_name;


Q2: Let's invite the artist who has written the most Rock music in our dataset.Write a query that
	returns the Artist name and total track count of the top 10 rock bands.

SELECT name,artist.artist_id,COUNT(*) AS track_count FROM artist 
INNER JOIN album on artist.artist_id=album.artist_id
INNER JOIN(
	SELECT album_id FROM track
	INNER JOIN genre on track.genre_id=genre.genre_id
	WHERE genre.name='Rock'
) as rock_track
ON album.album_id=rock_track.album_id
GROUP BY artist.artist_id 
ORDER BY track_count DESC
LIMIT 10;

Q4: Return all the track names that have a song length longer than the 
	average song length.Return the Name and Milliseconds for each track.Order
	the song length with the longest songs listed first.

	SELECT name as Name,milliseconds as Milliseconds
	FROM track 
    WHERE milliseconds > (SELECT AVG(milliseconds) FROM track) 
	ORDER BY milliseconds DESC;


	SET 3 - Advance

	Q1: Find how much amount spent by each customer on artists ? Write a query
	    to return customer name,artist name and total spent

	    -- SELECT CONCAT(first_name,last_name) AS full_name,artist.name AS artist_name,
	    -- SUM(total) AS total_spent
	    -- FROM invoice INNER JOIN invoice_line
	    -- ON invoice.invoice_id=invoice_line.invoice_id
	    -- INNER JOIN track ON invoice_line.track_id=track.track_id
	    -- INNER JOIN album ON track.album_id=album.album_id
	    -- INNER JOIN artist ON album.artist_id=artist.artist_id
	    -- INNER JOIN customer ON invoice.customer_id=customer.customer_id
	    -- GROUP BY (CONCAT(first_name,last_name),artist.name) ORDER BY money_spent DESC;

	    SELECT customer.customer_id,CONCAT(first_name,last_name) AS full_name,
	    artist.name AS artist_name,SUM(invoice_line.unit_price*quantity) AS total_spent
	    FROM invoice INNER JOIN customer ON invoice.customer_id=customer.customer_id
	    INNER JOIN invoice_line on invoice.invoice_id=invoice_line.invoice_id
	    INNER JOIN track on invoice_line.track_id=track.track_id
	    INNER JOIN album ON track.album_id=album.album_id
	    INNER JOIN artist ON album.artist_id=artist.artist_id
	    GROUP BY (customer.customer_id,artist.artist_id)
	    ORDER BY total_spent DESC;

	Q2: We want to find out the most popular music Genre for each country.We determine
	    the most popular genre as the genre with the highest amount of purchases. Write
	    a query that returns each country along with the top Genre. For countries where
	    the maximum number of purchases is shared return all Genres.

	    


	    WITH t1 AS(
	    SELECT COUNT(quantity) as purchases,customer.country as country,genre.name as genre,
	    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(quantity) DESC)
	    FROM invoice_line INNER JOIN invoice ON invoice_line.invoice_id=invoice.invoice_id
	    INNER JOIN customer ON invoice.customer_id=customer.customer_id
	    INNER JOIN track ON invoice_line.track_id=track.track_id
	    INNER JOIN genre ON track.genre_id=genre.genre_id
	    GROUP BY 2,3
	    ) SELECT * FROM t1 WHERE row_number<=1;


	   Q3: Write a query that determines the customer that has spent the most on music for each country
	       Write a query that returns the country along with the top customer and how much they
	       spent.For countries where the top amount spent is shared, provide all customers who spent this
	       amount.

	       WITH t1 AS(SELECT customer.customer_id,
	       CONCAT(customer.first_name,customer.last_name) as full_name,
	       SUM(total) AS total_spent,
	       billing_country AS country
	       FROM invoice
	       INNER JOIN customer ON invoice.customer_id=customer.customer_id
	       GROUP BY 4,1
	       ORDER BY 4,3 DESC),
	       t2 AS (SELECT MAX(total_spent) as spent,country
	       FROM t1
	       GROUP BY 2)
	       SELECT full_name,t1.country,total_spent FROM t2 INNER JOIN t1 ON t2.spent=t1.total_spent
	       ORDER BY t1.country;



	       

	   


