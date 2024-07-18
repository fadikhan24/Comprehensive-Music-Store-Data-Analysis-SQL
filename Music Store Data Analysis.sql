-- PROBLEM SET 1:
-- Find out who is the most senior employee based on job title?

SELECT * FROM employee
ORDER BY levels
LIMIT 1

-- Which countries have the most invoices?
SELECT COUNT(total) AS total_no_invoice, billing_country FROM invoice
GROUP BY billing_country
ORDER BY total_no_invoice DESC
LIMIT 10

-- What are the top 3 values of total Invoices?
SELECT total, *
	FROM invoice
ORDER BY total DESC 
	LIMIT 3

-- Which city has best customers? Write a query that returns highest sum of total invoices. 
-- Return both city name and and sum of all total invoices
SELECT SUM(total) AS sum_total_invoices, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY sum_total_invoices DESC
LIMIT 10


-- Find out who is the best customer based on amount spent.
SELECT customer.customer_id, customer.first_name, customer.last_name,
	SUM(invoice.total) AS total_amt_spent
	FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_amt_spent
LIMIT 1

-- PROBLEM SET 2:
-- Write a query to return first name, last name, email and Genre of all ROCK music listeners.
-- Return your list alphabetically by email starting with a.
SELECT DISTINCT email, first_name, last_name  
	FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id from track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email

-- Write a query that returns the artist name and total track count of the top10 rock bands.
SELECT artist.name, artist.artist_id, COUNT(artist.artist_id) as no_of_songs
	FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock' 
GROUP BY artist.artist_id
ORDER BY no_of_songs DESC
LIMIT 10

-- Return all tracks that have song length longer than avg song length.
-- Return the name miliseconds of eachtrack
SELECT name, milliseconds 
	from track
	WHERE milliseconds >(
	SELECT AVG(milliseconds) as avg_length
	FROM track)
ORDER BY milliseconds DESC

-- PROBLEM SET 3:
-- Find out how much amount spent by each customer on artist?
-- Write a query to return artist name, customer name and amount spent? (total sales & customer)
WITH best_selling_artist AS(
	SELECT artist.artist_id AS artist_id,artist.name AS artist_name,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
	)
SELECT c.customer_id,c.first_name, last_name, bsa.artist_name,
	SUM(il.unit_price * il.quantity) as amnt_spent
	FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1,2,3,4
ORDER BY 5

-- Find out the most popular genre for each country.
-- Most popular genre as the highest amount of purchases.
WITH popular_genre AS(
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id,
	ROW_NUMBER()
	OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS Row_no
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
) 
	SELECT * FROM popular_genre WHERE Row_no = 1