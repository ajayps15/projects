CREATE TABLE IF NOT EXISTS artist(
artist_id int,
full_name varchar,
first_name varchar,
middle_name varchar,
last_name varchar,
nationality varchar,
	style varchar,
	birth int,
	death int,
	PRIMARY KEY (artist_id)
);

CREATE TABLE IF NOT EXISTS canva_size(
size_id int, 
	width int, 
	height int, 
	label varchar,
primary key (size_id));

CREATE TABLE IF NOT EXISTS image_link(
work_id int, url varchar, thumbnail_small_url varchar, thumbnail_large_url varchar);

create table museum(
museum_id int, name varchar, address varchar, city varchar, state varchar, postal varchar, country varchar, phone varchar, url varchar
);

create table museum_hour(
museum_id int, day varchar, open varchar, close varchar
);

create table product_size(
work_id int, size_id int, sale_price int, regular_price int
);

create table subject(
work_id int, subject varchar
);


drop table if exists work;
create table work(
	work_id int, name varchar, artist_id int, style varchar, museum_id int
);

--changing column type 
alter table product_size
alter size_id type varchar;


-- cleaning data 
delete from product_size
where work_id in (
	select work_id
	from product_size
	where size_id = '#VALUE!')

-- changing column type
alter table product_size
alter work_id type int


-- Fetch all the pain
tings which are not displayed on any museums?
select *
from work
where museum_id is null

--Are there museuems without any paintings?
select *
from museum
where museum_id not in (select museum_id from work)

--How many paintings have an asking price of more than their regular price? 
select count(*) as "No of painting"
from product_size
where sale_price > regular_price

--Identify the paintings whose asking price is less than 50% of its regular price
select name
from work 
where work_id in 
(select work_id
from product_size
where sale_price < (regular_price * 0.5))

--Which canva size costs the most?

select 	label
from canva_size where size_id = (
	select size_id::decimal
from product_size
	order by sale_price desc
	limit 1)
	
--Delete duplicate records from work, product_size, subject and image_link tables
delete from work 
where ctid in(
select max(ctid) 
from work
group by work_id having count(*) >=2);

delete from product_size 
where ctid in(select max(ctid)
from product_size 
group by work_id , size_id , sale_price , regular_price having count(*) >1)

delete from subject
where ctid in(select max(ctid)
from subject
group by work_id , subject having count(*) >2)

delete from image_link
where ctid in (select max(ctid)
from image_link
group by work_id having count(*) > 1)


--Identify the museums with invalid city information in the given dataset
select *
from museum
where city !~ '^[a-zA-Z]'

--Museum_Hours table has 1 invalid entry. Identify it and remove it.
	delete from museum_hour
	where ctid not in (select min(ctid)
						from museum_hour
						group by museum_id, day );


--Fetch the top 10 most famous painting subject
Select s.subject 
from subject as s
inner join work as w on w.work_id = s.work_id
group by s.subject
order by rank() over(order by count(1) desc) limit 10

--Identify the museums which are open on both Sunday and Monday. Display museum name, city.
select name , city
from museum
where museum_id in(
select museum_id 
from museum_hour
where day in ('Sunday','Monday')
group by museum_id having  count(distinct day) =2)




--How many museums are open every single day?
select count(*) as days from (select museum_id
from museum_hour
group by museum_id having count(distinct day ) =7) as museum


--Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
select m.museum_id, max(m.name) as name
from museum as m
inner join work as w on w.museum_id = m.museum_id
group by m.museum_id 
order by count(*)  desc
limit 5



--Who are the top 5 most popular artist? (Popularity is defined based on most no of paintings done by an artist)
select full_name
from artist
where artist_id in (
select artist_id 
from work
group by artist_id
order by count(*) desc
Limit 5)

--Display the 3 least popular canva sizes
select c.size_id
from product_size as p
inner join canva_size as c on c.size_id::decimal = p.size_id::decimal
group by c.size_id
order by count(*) asc
limit 3


--Which museum is open for the longest during a day. Dispay museum name, state and hours open and which day?
select museum_id , replace(close,' ','')::time - open::time as total_open_time
from museum_hour
order by 2 desc
limit 1



--Which museum has the most no of most popular painting style?
with cte as (
select style , rank()over(order by count(*) desc) as rnk
from work
group by style
)
select m.name ,w.style, count(*) as "no of painting"
from museum as m 
inner join work as w on w.museum_id = m.museum_id
inner join cte as c on c.style = w.style and rnk = 1
group by m.name ,w.style
order by 3 desc
limit 1

--Identify the artists whose paintings are displayed in multiple countries
select w.artist_id, count(distinct m.country) as no_of_coutry
from work as w
inner join museum as m on m.museum_id = w.museum_id
group by w.artist_id having count(distinct m.country) >1
order by 2 desc

---Display the country and the city with most no of museums. Output 2 seperate columns to mention the city and country. If there are multiple value, seperate them with comma.

with country as (
	select country , count(*) , rank() over (order by count(*) desc)
from museum
group by country),

city as (select city , count(*) , rank() over (order by count(*) desc)
from museum
group by city)

select string_agg(distinct con.country,' ,') as coutry , string_agg(distinct c.city,' ,') as city
from city as c
inner join country as con on con.rank =c.rank
where c.rank =1



--Identify the artist and the museum where the most expensive and least expensive painting is placed. Display the artist name, sale_price, painting name, museum name, museum city and canvas label

with Highest as(
		select work_id ,sale_price
		from product_size
		order by sale_price desc
		limit 1),
		
	lowest as(
		select work_id ,sale_price
		from product_size
		order by sale_price 
		limit 1),
		
	Highest_lowest as(
		select * from highest 
		union all
		select * from lowest)
		
select a.full_name as artist_name ,h.sale_price, m.name as museum_price,c.label
from Highest_lowest as h
inner join work as w on w.work_id = h.work_id
inner join artist as a on a.artist_id = w.artist_id
inner join museum as m on w.museum_id = m.museum_id
INNER join product_size as p on p.work_id = w.work_id and p.sale_price = h.sale_price
inner join canva_size as c on c.size_id::decimal = p.size_id::decimal








