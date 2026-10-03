-- DROP TABLE IF EXISTS users, products, distribution_centers, orders, inventory_items, events, order_items CASCADE;


CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    age INT,
    gender TEXT,
    state TEXT,
    street_address TEXT,
    postal_code TEXT,
    city TEXT,
    country TEXT,
    latitude NUMERIC(9, 4),
    longitude NUMERIC(9, 4),
    traffic_source TEXT,
    created_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS distribution_centers (
    id INT PRIMARY KEY,
    name TEXT,
    latitude NUMERIC(9, 4),
    longitude NUMERIC(9, 4)
);

CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY,
    cost NUMERIC(9, 2),
    category TEXT,
    name TEXT,
    brand TEXT,
    retail_price NUMERIC(9, 2),
    department TEXT,
    sku TEXT,
    distribution_center_id INT,

    CONSTRAINT products_fk_distribution_center_id FOREIGN KEY (distribution_center_id) REFERENCES distribution_centers(id) 
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    status TEXT,
    gender TEXT,
    created_at TIMESTAMPTZ,
    returned_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    num_of_item INT,

    CONSTRAINT orders_fk_user_id FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS inventory_items (
    id INT PRIMARY KEY,
    product_id INT,
    created_at TIMESTAMPTZ,
    sold_at TIMESTAMPTZ,
    cost NUMERIC(9, 2),
    product_category TEXT,
    product_name TEXT,
    product_brand TEXT,
    product_retail_price NUMERIC(9, 2),
    product_department TEXT,
    product_sku TEXT,
    product_distribution_center_id INT,


    CONSTRAINT inventory_items_fk_product_id FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT inventory_items_fk_product_distribution_center_id FOREIGN KEY (product_distribution_center_id) REFERENCES distribution_centers(id)
);

CREATE TABLE IF NOT EXISTS events (
    id INT PRIMARY KEY,
    user_id INT,
    sequence_number INT,
    session_id TEXT,
    created_at TIMESTAMPTZ,
    ip_address TEXT,
    city TEXT,
    state TEXT,
    postal_code TEXT,
    browser TEXT,
    traffic_source TEXT,
    uri TEXT,
    event_type TEXT,

    CONSTRAINT events_fk_user_id FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id INT PRIMARY KEY,
    order_id INT,
    user_id INT,
    product_id INT,
    inventory_item_id INT,
    status TEXT,
    created_at TIMESTAMPTZ,
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    returned_at TIMESTAMPTZ,
    sale_price NUMERIC(9, 2),

    CONSTRAINT order_items_fk_order_id FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT order_items_fk_user_id FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT order_items_fk_product_id FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT order_items_fk_inventory_item_id FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id)
);
