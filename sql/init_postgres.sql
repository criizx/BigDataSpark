CREATE TABLE IF NOT EXISTS mock_data (
    id                   INT,
    customer_first_name  VARCHAR(100),
    customer_last_name   VARCHAR(100),
    customer_age         INT,
    customer_email       VARCHAR(200),
    customer_country     VARCHAR(100),
    customer_postal_code VARCHAR(50),
    customer_pet_type    VARCHAR(50),
    customer_pet_name    VARCHAR(100),
    customer_pet_breed   VARCHAR(100),
    seller_first_name    VARCHAR(100),
    seller_last_name     VARCHAR(100),
    seller_email         VARCHAR(200),
    seller_country       VARCHAR(100),
    seller_postal_code   VARCHAR(50),
    product_name         VARCHAR(200),
    product_category     VARCHAR(100),
    product_price        NUMERIC(12,2),
    product_quantity     INT,
    sale_date            DATE,
    sale_customer_id     INT,
    sale_seller_id       INT,
    sale_product_id      INT,
    sale_quantity        INT,
    sale_total_price     NUMERIC(12,2),
    store_name           VARCHAR(200),
    store_location       VARCHAR(200),
    store_city           VARCHAR(100),
    store_state          VARCHAR(100),
    store_country        VARCHAR(100),
    store_phone          VARCHAR(50),
    store_email          VARCHAR(200),
    pet_category         VARCHAR(100),
    product_weight       NUMERIC(8,2),
    product_color        VARCHAR(50),
    product_size         VARCHAR(50),
    product_brand        VARCHAR(100),
    product_material     VARCHAR(100),
    product_description  TEXT,
    product_rating       NUMERIC(3,1),
    product_reviews      INT,
    product_release_date DATE,
    product_expiry_date  DATE,
    supplier_name        VARCHAR(200),
    supplier_contact     VARCHAR(200),
    supplier_email       VARCHAR(200),
    supplier_phone       VARCHAR(50),
    supplier_address     VARCHAR(200),
    supplier_city        VARCHAR(100),
    supplier_country     VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(200),
    category     VARCHAR(100),
    brand        VARCHAR(100),
    color        VARCHAR(50),
    size         VARCHAR(50),
    material     VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    email       VARCHAR(200),
    country     VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id  SERIAL PRIMARY KEY,
    sale_date DATE NOT NULL,
    day      INT,
    month    INT,
    year     INT,
    quarter  INT
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_id   SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    city       VARCHAR(100),
    country    VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_id   SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    country       VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id      SERIAL PRIMARY KEY,
    product_id   INT REFERENCES dim_product(product_id),
    customer_id  INT REFERENCES dim_customer(customer_id),
    date_id      INT REFERENCES dim_date(date_id),
    store_id     INT REFERENCES dim_store(store_id),
    supplier_id  INT REFERENCES dim_supplier(supplier_id),
    quantity     INT,
    unit_price   NUMERIC(12,2),
    total_amount NUMERIC(12,2),
    rating       NUMERIC(3,1),
    review_count INT
);
