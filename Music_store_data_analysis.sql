/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;




/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name ,milliseconds  from track
where  milliseconds>(select avg(milliseconds) 
	                 from track)
order by milliseconds desc



/* Question Set 3 - Advance */

	
/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

/*Steps to solve:customer name is in the "customer" table,artist name is in the "artist" table
and I have calculated total_sales on each song from invoice table by multiplying unitprice and quantity.
with the help of common table query(CTE) the idea is to create a temporary table containing coumns of
artist_name and total_sales.Through this table it can be inferred how much amount is spent on each artist 
by all customer.
    Now to add customer name;customer table is joined with invoice table and then consecutively it is 
	joined with invoice_line,track,album,artist and best_selling_artist(bsa) table to get artist name  
	along with customer name */



with best_selling_artist as (
	select artist.name as artist_name ,sum(invoice_line.unit_price*invoice_line.quantity)as total_sales
	from invoice_line
	join track on track.track_id=invoice_line.track_id
	join album on album.album_id=track.album_id
	join artist on album.artist_id=artist.artist_id
	group by artist.name
	order by total_sales desc
)
select customer.first_name,customer.last_name,bsa.artist_name,
sum(invoice_line.unit_price*invoice_line.quantity)as total_spent
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on album.artist_id=artist.artist_id
join best_selling_artist bsa on bsa.artist_name=artist.name 
group by 1,2,3
order by 4 desc


/* Q2: We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that returns each 
country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/*Steps to solve:In the final table  music genre ,country and heighest purchases of top genre album
is needed.So customer.country,genre.name,genre.genre_id,count(invoice_line.quantity) as purchases 
has been slected.It is asked top genre in each country so windows function ROW_NUMBER()is used.And 
then storing all the columns in a temporary table named " Highest_amount_purchases " using CTE.

    From this table it can be seen all the different genre that has been purchased in different countries
    So to get the top genre I have applied the crieteria Row_no<=1 using where clause */


with Highest_amount_purchases as(
select customer.country,genre.name,genre.genre_id,count(invoice_line.quantity) as purchases,
 ROW_NUMBER() over(partition by customer.country order by count(invoice_line.quantity) DESC)as Row_no
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.track_id
join genre on track.genre_id=genre.genre_id
group by 1,2,3
order by 1 asc,4 desc
)
select * from Highest_amount_purchases
where Row_no<=1


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/*Steps to solve:In the final output I need country name,top customer and their spent amount.
for that I have selected customer_id,first_name,last_name from "customer" table and "Total" from Invoice
table.For accumlating the mentioned columns I have to join customer with invoice on customer_id.
   Now as the customer with top amount spent has asked I have used ROW_NO() and later on used Row_no<=1
   to get the top amount spent customer. */ 

with Top_amount_spent as(
select customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,
sum(invoice.total) as Total_spending,
ROW_NUMBER() over(partition by customer.country order by sum(invoice.total)DESC)as Row_no
from customer
join invoice on customer.customer_id=invoice.customer_id
group by 1,2,3,4
order by 4 asc,5 desc
)
select * from Top_amount_spent
where Row_no<=1



