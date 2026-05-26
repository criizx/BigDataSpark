from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window

spark = SparkSession.builder \
    .appName("ETL") \
    .master("local[*]") \
    .getOrCreate()

pg_url = "jdbc:postgresql://postgres:5432/bigdata"
pg_props = {
    "user": "spark",
    "password": "spark123",
    "driver": "org.postgresql.Driver"
}

spark.read.format("jdbc") \
    .option("url", pg_url) \
    .option("query", "SELECT 1") \
    .option("user", "spark") \
    .option("password", "spark123") \
    .option("driver", "org.postgresql.Driver") \
    .option("sessionInitStatement", "TRUNCATE fact_sales, dim_product, dim_customer, dim_date, dim_store, dim_supplier RESTART IDENTITY CASCADE") \
    .load().collect()

raw = spark.read.jdbc(url=pg_url, table="mock_data", properties=pg_props)
print("всего строк: " + str(raw.count()))

dim_product = raw.select(
    F.col("sale_product_id").alias("product_id"),
    "product_name",
    "product_category",
    "product_brand",
    "product_color",
    "product_size",
    "product_material"
).dropDuplicates(["product_id"]) \
 .withColumnRenamed("product_category", "category") \
 .withColumnRenamed("product_brand", "brand") \
 .withColumnRenamed("product_color", "color") \
 .withColumnRenamed("product_size", "size") \
 .withColumnRenamed("product_material", "material")

dim_product.write.jdbc(url=pg_url, table="dim_product", mode="append", properties=pg_props)
print("dim_product записан : " + str(dim_product.count()))

dim_customer = raw.select(
    F.col("sale_customer_id").alias("customer_id"),
    F.col("customer_first_name").alias("first_name"),
    F.col("customer_last_name").alias("last_name"),
    F.col("customer_email").alias("email"),
    F.col("customer_country").alias("country")
).dropDuplicates(["customer_id"])

dim_customer.write.jdbc(url=pg_url, table="dim_customer", mode="append", properties=pg_props)
print("dim_customer записан : " + str(dim_customer.count()))

dim_date = raw.select(F.col("sale_date").cast("date")) \
    .dropDuplicates(["sale_date"]) \
    .withColumn("day", F.dayofmonth("sale_date")) \
    .withColumn("month", F.month("sale_date")) \
    .withColumn("year", F.year("sale_date")) \
    .withColumn("quarter", F.quarter("sale_date")) \
    .withColumn("date_id", F.row_number().over(Window.orderBy("sale_date")))

dim_date.write.jdbc(url=pg_url, table="dim_date", mode="append", properties=pg_props)
print("dim_date записан : " + str(dim_date.count()))

dim_store = raw.select("store_name", "store_city", "store_country") \
    .dropDuplicates(["store_name"]) \
    .withColumnRenamed("store_city", "city") \
    .withColumnRenamed("store_country", "country") \
    .withColumn("store_id", F.row_number().over(Window.orderBy("store_name")))

dim_store.write.jdbc(url=pg_url, table="dim_store", mode="append", properties=pg_props)
print("dim_store записан : " + str(dim_store.count()))

dim_supplier = raw.select("supplier_name", "supplier_country") \
    .dropDuplicates(["supplier_name"]) \
    .withColumnRenamed("supplier_country", "country") \
    .withColumn("supplier_id", F.row_number().over(Window.orderBy("supplier_name")))

dim_supplier.write.jdbc(url=pg_url, table="dim_supplier", mode="append", properties=pg_props)
print("dim_supplier записан : " + str(dim_supplier.count()))

fact_sales = raw \
    .join(dim_date, raw.sale_date.cast("date") == dim_date.sale_date, "left") \
    .join(dim_store, raw.store_name == dim_store.store_name, "left") \
    .join(dim_supplier, raw.supplier_name == dim_supplier.supplier_name, "left") \
    .select(
        raw.sale_product_id.alias("product_id"),
        raw.sale_customer_id.alias("customer_id"),
        dim_date.date_id,
        dim_store.store_id,
        dim_supplier.supplier_id,
        raw.sale_quantity.alias("quantity"),
        raw.product_price.alias("unit_price"),
        raw.sale_total_price.alias("total_amount"),
        raw.product_rating.alias("rating"),
        raw.product_reviews.alias("review_count")
    )

fact_sales.write.jdbc(url=pg_url, table="fact_sales", mode="append", properties=pg_props)
print("fact_sales записан : " + str(fact_sales.count()))

spark.stop()
