
-- Считаем количество клиентов в таблице customers

SELECT 
COUNT(customer_id) as customers_count
FROM customers;


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

