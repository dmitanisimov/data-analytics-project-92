
-- МОДУЛЬ 4
-- Считаем количество клиентов в таблице customers. 

SELECT 
COUNT(customer_id) as customers_count
FROM customers;



-- МОДУЛЬ 5
/*
Первый отчет о десятке лучших продавцов. Таблица состоит из трех колонок - данных о продавце, 
 суммарной выручке с проданных товаров и количестве проведенных сделок, и отсортирована по убыванию выручки:
*/


select
concat(empl.first_name, ' ',empl.last_name) as seller,
COUNT(sal.sales_person_id)  as operations,
FLOOR(SUM(sal.quantity * pro.price)) as income
from sales as sal left join products as pro on sal.product_id = pro.product_id 
left join employees as empl on sal.sales_person_id = empl.employee_id  
group by sal.sales_person_id, seller order by income desc limit 10;




/*
 Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
  Таблица отсортирована по выручке по возрастанию.
*/


with tab AS(
select
concat(empl.first_name, ' ',empl.last_name) as seller,
sal.sales_person_id as employees,
COUNT(sal.sales_person_id)  as operations,
SUM(sal.quantity * pro.price) as income,
SUM(sal.quantity * pro.price) / COUNT(*) AS avg_per_sale
from sales as sal left join products as pro on sal.product_id = pro.product_id 
left join employees as empl on sal.sales_person_id = empl.employee_id  
group by sal.sales_person_id, empl.first_name, empl.last_name  
)

select
seller,
FLOOR(avg_per_sale) as average_income
from tab
where avg_per_sale <=(
select
SUM (sal.quantity * pro.price) / COUNT(*) AS total_avg_sales
from sales as sal
left join products as pro ON sal.product_id = pro.product_id
) order by income asc;





/*
 Третий отчет содержит информацию о выручке по дням недели.
  Каждая запись содержит имя и фамилию продавца, день недели и суммарную выручку.
   Отсортируйте данные по порядковому номеру дня недели и seller
*/




with tab AS(
select
concat(empl.first_name, ' ',empl.last_name) as seller,
FLOOR(SUM(sal.quantity * pro.price)) as income,
EXTRACT(DOW FROM sal.sale_date) AS weekday_number,
TRIM(TO_CHAR(sal.sale_date, 'Day')) as day_of_week
from sales as sal left join products as pro on sal.product_id = pro.product_id
left join employees as empl on sal.sales_person_id = empl.employee_id  
group by  seller, weekday_number, day_of_week
)

select 
seller,
day_of_week,
income
from tab  order by   weekday_number, seller asc;







-- МОДУЛЬ 6


/*
Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
Итоговая таблица должна быть отсортирована по возрастным группам и содержать следующие поля:
age_category - возрастная группа
age_count - количество человек в группе
*/


select
 case
	 when age between 16 and 25 then '16-25'
     when age between 26 and 40 then '26-40'
     when age > 40 then '40+'
     else 'other'
     end as age_category,
 COUNT(customer_id) AS age_count
from customers group by age_category order by age_category;





/*
Во втором отчете предоставьте данные по количеству уникальных покупателей и выручке, которую они принесли. 
Сгруппируйте данные по дате, которая представлена в числовом виде ГОД-МЕСЯЦ.
 Итоговая таблица должна быть отсортирована по дате по возрастанию и содержать следующие поля:
*/



with tab AS(
select
cust.customer_id as customers_id,
TO_CHAR(sal.sale_date, 'YYYY-MM') as selling_month,
(sal.quantity * pro.price) as income
from customers as cust left join sales as sal on cust.customer_id = sal.customer_id
left join products as pro on sal.product_id = pro.product_id where sal.sale_date is not null
)

select
selling_month,
COUNT(distinct customers_id) AS total_customers,
ROUND(SUM(income),0) as income
from tab group by selling_month order by selling_month;



/*
Третий отчет следует составить о покупателях, первая покупка
которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
 Итоговая таблица должна быть отсортирована по id покупателя. Таблица состоит из следующих полей:
*/

with tab AS(
select
cust.customer_id as customers_id,
concat(cust.first_name, ' ',cust.last_name) as customers_name,
concat(empl.first_name, ' ',empl.last_name) as seller_name,
TO_CHAR(sal.sale_date, 'YYYY-MM-DD') as sale_date,
(sal.quantity * pro.price) as income
from customers as cust left join sales as sal on cust.customer_id = sal.customer_id
left join products as pro on sal.product_id = pro.product_id 
left join employees as empl on sal.sales_person_id = empl.employee_id
where sal.sale_date is not null
),

tab2 AS(
select 
customers_id,
ROW_NUMBER() over (partition by customers_id) as custommers_number,
customers_name,
seller_name,
sale_date,
income
from tab
)

select 
customers_name as customer,
sale_date,
seller_name as seller
from tab2 where custommers_number = 1 and income = 0 order by customers_id;



