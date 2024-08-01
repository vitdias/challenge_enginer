-- 1) List users with today's birthday whose sales in January 2020 are greater than 1,500. 

SELECT
    a.buyer_id,
    SUM(a.order_gross_value) AS sum_order_gross_value
FROM
    order_mart AS a
LEFT JOIN
    user_mart AS b
    ON a.buyer_id=b.user_id
WHERE
    a.order_create_date >= date('2020-01-01') AND a.order_create_date < date('2020-02-01')
    AND MONTH(b.birthday_date) = MONTH(CURRENT_DATE()) AND DAY(b.birthday_date) = DAY(CURRENT_DATE())
GROUP BY 1
HAVING SUM(a.order_gross_value) > 1500;


-- 2) For each month of 2020, the top 5 users who sold the most ($) in the Cell Phones category are requested . 
-- The month and year of analysis, name and surname of the seller, number of sales made, number of products sold and the total amount transacted are required.

WITH prepare_sellers AS (
    SELECT
        a.seller_id,
        DATE_FORMAT(a.order_create_date, '%Y%m') AS yearmont_order,
        COUNT(a.order_id) as qt_orders,
        count(item_id) AS qt_items
        SUM(a.order_gross_value) AS sum_order_gross_value,
        RANK() OVER (PARTITION BY DATE_FORMAT(a.order_create_date, '%Y%m') ORDER BY SUM(a.order_gross_value) DESC) as rank
    FROM
        order_mart AS a
    LEFT JOIN
        item_mart AS b
        ON Na.order_id=b.order_id
    WHERE
        b.category_l2 = 'Cell Phones and Telephones' AND YEAR(a.order_create_date) = 2020
    )

    SELECT
        a.yearmont_order,
        b.first_name || ', ' || b.last_name AS seller_name,
        a.qt_orders,
        a.qt_items,
        a.sum_order_gross_valuesum_order_gross_value
    FROM
        prepare_sellers AS a
    LEFT JOIN
        user_mart AS b
        ON a.seller_id=b.user_id
    WHERE
        rank <= 5;

-- 3) A new table is requested to be populated with the price and status of the Items at the end of the day. Keep in mind that it must be reprocessable . 
-- It is worth noting that in the Item table, we will only have the last status reported by the defined PK. (It can be resolved through StoredProcedure) 

CREATE TABLE daily_item_status (
    item_id INT,
    daily_price DECIMAL(10,2),
    daily_status VARCHAR(255),
    record_date DATE,
    PRIMARY KEY (item_id, record_date),
    FOREIGN KEY (item_id) REFERENCES item_mart(item_id)
);


DELIMITER $$

CREATE PROCEDURE PopulateDailyItemStatus()
BEGIN
    DELETE FROM daily_item_status WHERE record_date = CURDATE();

    INSERT INTO daily_item_status (item_id, daily_price, daily_status, record_date)
    SELECT 
        lm.item_id,
        lm.item_price,
        lm.listings_status,
        CURDATE()
    FROM 
        listings_mart lm
    WHERE
        lm.listings_status <> 'inactive'; 
END$$

DELIMITER ;


CREATE EVENT IF NOT EXISTS ev_populate_daily_status
ON SCHEDULE EVERY 1 DAY STARTS CONCAT(CURDATE(), ' 23:59:00')
DO
    CALL PopulateDailyItemStatus();
