CREATE DATABASE IF NOT EXISTS reports;

CREATE TABLE IF NOT EXISTS reports.sales_by_product (
    product_id        Int32,
    product_name      String,
    category          String,
    brand             String,
    total_revenue     Float64,
    total_quantity    Int64,
    avg_rating        Float64,
    total_reviews     Int64,
    revenue_rank      Int32
) ENGINE = MergeTree()
ORDER BY (category, product_id);

CREATE TABLE IF NOT EXISTS reports.sales_by_customer (
    customer_id       Int32,
    full_name         String,
    email             String,
    country           String,
    total_spent       Float64,
    order_count       Int64,
    avg_check         Float64,
    spending_rank     Int32
) ENGINE = MergeTree()
ORDER BY (country, customer_id);

CREATE TABLE IF NOT EXISTS reports.sales_by_time (
    year              Int32,
    month             Int32,
    period            String,
    total_revenue     Float64,
    total_orders      Int64,
    avg_order_size    Float64
) ENGINE = MergeTree()
ORDER BY (year, month);

CREATE TABLE IF NOT EXISTS reports.sales_by_store (
    store_id          Int32,
    store_name        String,
    city              String,
    country           String,
    total_revenue     Float64,
    total_orders      Int64,
    avg_check         Float64,
    revenue_rank      Int32
) ENGINE = MergeTree()
ORDER BY (country, store_id);

CREATE TABLE IF NOT EXISTS reports.sales_by_supplier (
    supplier_id       Int32,
    supplier_name     String,
    country           String,
    total_revenue     Float64,
    avg_price         Float64,
    total_orders      Int64,
    revenue_rank      Int32
) ENGINE = MergeTree()
ORDER BY (country, supplier_id);

CREATE TABLE IF NOT EXISTS reports.product_quality (
    product_id        Int32,
    product_name      String,
    category          String,
    brand             String,
    avg_rating        Float64,
    total_reviews     Int64,
    total_sales       Int64,
    total_revenue     Float64,
    quality_rank      Int32
) ENGINE = MergeTree()
ORDER BY (category, product_id);
