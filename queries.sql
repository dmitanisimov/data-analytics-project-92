SELECT COUNT(customer_id) AS customers_count
FROM customers;

-- МОДУЛЬ 4
-- Первый отчет о десятке лучших продавцов.

SELECT
    CONCAT(empl.first_name, ' ', empl.last_name) AS seller,
    COUNT(sal.sales_person_id) AS operations,
    FLOOR(SUM(sal.quantity * pro.price)) AS income
FROM
    sales AS sal
LEFT JOIN products AS pro ON sal.product_id = pro.product_id
LEFT JOIN employees AS empl ON sal.sales_person_id = empl.employee_id
GROUP BY
    sal.sales_person_id,
    seller
ORDER BY
    income DESC
LIMIT
    10;

-- МОДУЛЬ 4
-- Второй отчет содержит информацию о продавцах, чья средняя выручка 
-- за сделку меньше средней выручки за сделку по всем продавцам.
-- Таблица отсортирована по выручке по возрастанию.

WITH tab AS (
    SELECT
        sal.sales_person_id AS employees,
        CONCAT(empl.first_name, ' ', empl.last_name) AS seller,
        COUNT(sal.sales_person_id) AS operations,
        SUM(sal.quantity * pro.price) AS income,
        SUM(sal.quantity * pro.price) / COUNT(*) AS avg_per_sale
    FROM
        sales AS sal
    LEFT JOIN products AS pro ON sal.product_id = pro.product_id
    LEFT JOIN employees AS empl ON sal.sales_person_id = empl.employee_id
    GROUP BY
        sal.sales_person_id,
        empl.first_name,
        empl.last_name
)

SELECT
    seller,
    FLOOR(avg_per_sale) AS average_income
FROM
    tab
WHERE
    avg_per_sale <= (
        SELECT
            SUM(sal.quantity * pro.price) / COUNT(*) AS total_avg_sales
        FROM
            sales AS sal
        LEFT JOIN products AS pro ON sal.product_id = pro.product_id
    )
ORDER BY
    average_income ASC;

-- МОДУЛЬ 4
-- Третий отчет содержит информацию о выручке по дням недели.
-- Каждая запись содержит имя и фамилию продавца,
-- день недели и суммарную выручку.
-- Отсортируйте данные по порядковому номеру дня недели и seller.

WITH tab AS (
    SELECT
        CONCAT(empl.first_name, ' ', empl.last_name) AS seller,
        FLOOR(SUM(sal.quantity * pro.price)) AS income,
        LOWER(TRIM(TO_CHAR(sal.sale_date, 'Day'))) AS day_of_week
    FROM
        sales AS sal
    LEFT JOIN products AS pro ON sal.product_id = pro.product_id
    LEFT JOIN employees AS empl ON sal.sales_person_id = empl.employee_id
    GROUP BY
        seller,
        day_of_week
)

SELECT
    seller,
    day_of_week,
    income
FROM
    tab
ORDER BY
    CASE day_of_week
        WHEN 'monday' THEN 1
        WHEN 'tuesday' THEN 2
        WHEN 'wednesday' THEN 3
        WHEN 'thursday' THEN 4
        WHEN 'friday' THEN 5
        WHEN 'saturday' THEN 6
        WHEN 'sunday' THEN 7
    END,
    seller;

-- МОДУЛЬ 6
-- Первый отчет — количество покупателей в разных возрастных
-- группах: 16-25, 26-40 и 40+.

SELECT
    CASE
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        WHEN age > 40 THEN '40+'
        ELSE 'other'
    END AS age_category,
    COUNT(customer_id) AS age_count
FROM
    customers
GROUP BY
    age_category
ORDER BY
    age_category;

-- МОДУЛЬ 6
-- Второй отчет — количество уникальных покупателей
-- и суммарная выручка по месяцам.

WITH tab AS (
    SELECT
        cust.customer_id AS customers_id,
        TO_CHAR(sal.sale_date, 'YYYY-MM') AS selling_month,
        (sal.quantity * pro.price) AS income
    FROM
        customers AS cust
    LEFT JOIN sales AS sal ON cust.customer_id = sal.customer_id
    LEFT JOIN products AS pro ON sal.product_id = pro.product_id
    WHERE
        sal.sale_date IS NOT NULL
)

SELECT
    selling_month,
    COUNT(DISTINCT customers_id) AS total_customers,
    FLOOR(SUM(income)) AS income
FROM
    tab
GROUP BY
    selling_month
ORDER BY
    selling_month;

-- МОДУЛЬ 6
-- Третий отчет — покупатели, чья первая покупка была акционной (income = 0).

WITH tab AS (
    SELECT
        cust.customer_id AS customers_id,
        CONCAT(cust.first_name, ' ', cust.last_name) AS customers_name,
        CONCAT(empl.first_name, ' ', empl.last_name) AS seller_name,
        TO_CHAR(sal.sale_date, 'YYYY-MM-DD') AS sale_date,
        (sal.quantity * pro.price) AS income
    FROM
        customers AS cust
    LEFT JOIN sales AS sal ON cust.customer_id = sal.customer_id
    LEFT JOIN products AS pro ON sal.product_id = pro.product_id
    LEFT JOIN employees AS empl ON sal.sales_person_id = empl.employee_id
    WHERE
        sal.sale_date IS NOT NULL
),

tab2 AS (
    SELECT
        customers_id,
        ROW_NUMBER() OVER (PARTITION BY customers_id ORDER BY sale_date) AS custommers_number,
        customers_name,
        seller_name,
        sale_date,
        income
    FROM
        tab
)

SELECT
    customers_name AS customer,
    sale_date,
    seller_name AS seller
FROM
    tab2
WHERE
    custommers_number = 1
    AND income = 0
ORDER BY
    customers_id;
