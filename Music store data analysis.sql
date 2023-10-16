CREATE DATABASE music_data;

USE music_data;

SHOW TABLES;

SELECT * FROM album;
SELECT * FROM artist;
SELECT * FROM customer;
SELECT * FROM employee;
SELECT * FROM genre;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM media_type;
SELECT * FROM playlist;
SELECT * FROM playlist_track;
SELECT * FROM track;

/* Q1: Who is the senior most employee based on job title? */

select employee_id, first_name, last_name, title, levels
from employee
order by levels desc
limit 1;

/* Q2: Which countries have the most Invoices? */

select billing_country, count(total) as no_of_invoices
from invoice
group by billing_country
order by no_of_invoices desc;


/* Q3: What are top 3 values of total invoice? */

select distinct total as highest_invoices
from invoice
order by highest_invoices desc
limit 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc
limit 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name, c.last_name, sum(i.total) as total_spending
from customer c
inner join invoice i
on c.customer_id = i.customer_id
group by c.customer_id, c.first_name, c.last_name
order by total_spending desc
limit 1;

/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

-- Method 1
select distinct email, first_name, last_name 
from customer c
inner join invoice i on c.customer_id = i.customer_id
inner join invoice_line il on i.invoice_id = il.invoice_id
where track_id in ( select track_id from track t
					inner join genre g on t.genre_id = g.genre_id
                    where g.name like 'rock'
					)
order by email;

-- Method 2

select distinct email as Email,first_name as FirstName, last_name as LastName, g.name as Name
from customer c
inner join invoice i on c.customer_id = i.customer_id
inner join invoice_line il on i.invoice_id = il.invoice_id
inner join track t on il.track_id = t.track_id
inner join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
order by email;



/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select ar.artist_id, ar.name,count(ar.artist_id) as number_of_songs
from track t
inner join album al on t.album_id = al.album_id
inner join artist ar on al.artist_id = ar.artist_id
inner join genre g on g.genre_id = t.genre_id
where g.name like 'Rock'
group by ar.artist_id,ar.name
order by number_of_songs desc
limit 10;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_track_length
					  from track)
order by milliseconds desc;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

with best_selling_artist as (
	select artist.artist_id as artist_id, artist.name as artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
	from invoice_line
	inner join track on track.track_id = invoice_line.track_id
	inner join album on album.album_id = track.album_id
	inner join artist on artist.artist_id = album.artist_id
	group by 1,2
	order by 3 desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price*il.quantity) as amount_spent
from invoice i
inner join customer c on c.customer_id = i.customer_id
inner join invoice_line il on il.invoice_id = i.invoice_id
inner join track t on t.track_id = il.track_id
inner join album alb on alb.album_id = t.album_id
inner join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by amount_spent desc;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as 
(
    select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id, 
	row_number() over(partition by customer.country order by COUNT(invoice_line.quantity) desc) as RowNo 
    from invoice_line 
	inner join invoice on invoice.invoice_id = invoice_line.invoice_id
	inner join customer on customer.customer_id = invoice.customer_id
	inner join track on track.track_id = invoice_line.track_id
	inner join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1;


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */


with Customter_with_country as (
		select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
	    row_number() over(partition by billing_country order by sum(total) desc) as RowNo 
		from invoice
		inner join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from Customter_with_country where RowNo <= 1;







