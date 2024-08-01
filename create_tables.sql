CREATE TABLE user_mart (
    user_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    account_status VARCHAR(255),
    birthday_date DATE
);

CREATE TABLE order_mart (
    order_id INT PRIMARY KEY,
    checkout_id INT,
    buyer_id INT,
    seller_id INT,
    order_create_date DATE,
    order_gross_value DECIMAL(10,2),
    FOREIGN KEY (buyer_id) REFERENCES user_mart(user_id),
    FOREIGN KEY (seller_id) REFERENCES user_mart(user_id)
);

CREATE TABLE item_mart (
    item_id INT PRIMARY KEY,
    order_id INT,
    item_cogs DECIMAL(10,2),
    category_l1 VARCHAR(255),
    category_l2 VARCHAR(255),
    category_l3 VARCHAR(255),
    FOREIGN KEY (order_id) REFERENCES order_mart(order_id)
);

CREATE TABLE listings_mart (
    listing_id INT,
    item_id INT,
    item_price DECIMAL(10,2),
    category_l1 VARCHAR(255),
    category_l2 VARCHAR(255),
    category_l3 VARCHAR(255),
    seller_id INT,
    listings_status VARCHAR(255),
    PRIMARY KEY (listing_id, item_id),
    FOREIGN KEY (item_id) REFERENCES item_mart(item_id),
    FOREIGN KEY (seller_id) REFERENCES user_mart(user_id)
);
