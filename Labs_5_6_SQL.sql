/*
Lab | SQL Queries 5
Instructions

1. Drop column picture from staff.
2. A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the database accordingly.
3. Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1 today.
4. Delete non-active users, but first, create a backup table deleted_users to store customer_id, email, and the date the user was deleted.
*/
use sakila;

#1. Drop column picture from staff.
alter table staff
drop column picture;

#2. A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the database accordingly.
select * from customer where first_name = 'tammy' and last_name = 'sanders';
insert into staff 
values (3, 'Tammy', 'Sanders', 79, null, 2, 1, 'Tammy', null, 20201014);

insert into staff 
values (4, (select first_name from customer where customer_id = 75),
 'Sanders', 79, null, 2, 1, 'Tammy', null, 20201014);

insert into staff 
values (5, (select first_name from customer where customer_id = 75),
(select last_name from customer where customer_id = 75),
(select address_id from customer where customer_id = 75),
(select email from customer where customer_id = 75),
2, 1, 'Tammy', null, 20201014);

show fields from staff;

#returns the column names, not the list though
SELECT column_name FROM information_schema.columns WHERE table_schema = 'sakila' AND table_name = 'staff';

#attempt to not writing the columns manually (doesn't work yet)
insert into staff((SELECT column_name FROM information_schema.columns WHERE table_schema = 'sakila' AND table_name = 'staff'))
values (
(select first_name from customer where customer_id = 75),
(select last_name from customer where customer_id = 75),
(select address_id from customer where customer_id = 75),
(select email from customer where customer_id = 75),
2, 1, 'Tammy', null);

#we leave out the automatic values (id and current date) in the list below;
insert into staff(first_name, last_name,address_id,email,store_id,active,username,password)
values (
(select first_name from customer where customer_id = 75),
(select last_name from customer where customer_id = 75),
(select address_id from customer where customer_id = 75),
(select email from customer where customer_id = 75),
2, 1, 'Tammy', null); 

#3. Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1 today.
show fields from rental;
insert into rental 
values(16050, 
	curdate(),
	1,
	(select customer_id from customer where first_name = 'Charlotte' and last_name = 'Hunter'),
	null,
	(select staff_id from staff where first_name = 'Mike'), current_date);
	
#Subquery returns more than 1 row when tried this for inventory_id
#(select inventory_id from inventory where film_id = 1 and store_id = 2)

/*
#4. Delete non-active users, but first, create a backup table deleted_users to store customerid, email, and the date the user was deleted.
True = 1
False = 0
*/;

#creating a new table
create table deleted_users (
	 `customer_id` int(10) unique not null,
	 `email` varchar(30) not null,
	 `date_deleted` timestamp not null default current_timestamp
	 );

#assigning primaty key
alter table deleted_users
add primary key (customer_id);

#ensuring email type is exactly as email in customer table so that we can grab data from there 
alter table deleted_users
modify email varchar(50);

#grabbing data from customer into deleted_users under condition (all at once magic)
insert into deleted_users(customer_id, email)
select customer_id, email
	from customer
	where active = 0;
	
	 
show fields from customer;
show fields from deleted_users;

#deleting inactive users from customers under condition active = 0 

SET FOREIGN_KEY_CHECKS=0; -- to disable them
SET FOREIGN_KEY_CHECKS=1; -- to re-enable them
use sakila;
delete from customer where active = 0;



/*
Lab | SQL Queries 6

We are going to do some database maintenance. We have received the film catalog for 2020. We have just one item for each film, and all will be placed in store 2. All other movies will be moved to store 1. The rental duration will be 3 days, with an offer price of 2.99€ and a replacement cost of 8.99€. The catalog is in a CSV file named films_2020.csv that can be found at files_for_lab folder.

Instructions

1. Add the new films to the database.
2. Update inventory.
*/

#1. Add the new films to the database.
show variables like 'local_infile';
set global local_infile = 1;

load data local infile '/Users/annakharchenkova/Desktop/Data Sc/Day 6/films_2020.csv'
into table film 
fields terminated by ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(title, description, release_year, language_id, original_language_id,length, rating, special_features);

show fields from film;

#2. Update inventory.

#2.1. all 2020 films to be placed in store 2. All other movies will be moved to store 1

show fields from inventory;

#add new records to inventory id 

show fields from rental;
show fields from inventory;

-- SET FOREIGN_KEY_CHECKS=0; -- to disable them
-- SET FOREIGN_KEY_CHECKS=1; -- to re-enable them

#would have been easier to change all the store_id in the inventory to 1 before loading new data. 
#this is how:

update inventory set store_id = 1;

#adding data to inventory, setting store_id to 2 in all this new data
insert into inventory(film_id, store_id) -- only id first
select film_id , 2
	from film
	where release_year = 2020;

#changing store_id after we added the data: 
update inventory set store_id = 1 where film_id < 1000; 


#2.2. The rental duration will be 3 days, with an offer price of 2.99€ and a replacement cost of 8.99€.
update film set rental_duration = 3, rental_rate = 2.99, replacement_cost = 8.99 where release_year = 2020; 



