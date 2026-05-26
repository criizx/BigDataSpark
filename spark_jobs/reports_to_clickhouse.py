from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window

spark = SparkSession.builder \
    .appName("Reports ClickHouse") \
    .master("local[*]") \
    .getOrCreate()

pg_url = "jdbc:postgresql://postgres:5432/bigdata"
pg_props = {
    "user": "spark",
    "password": "spark123",
    "driver": "org.postgresql.Driver"
}

ch_url = "jdbc:clickhouse://clickhouse:8123/reports"
ch_props = {
    "user": "spark",
    "password": "spark123",
    "driver": "com.clickhouse.jdbc.ClickHouseDriver"
}

ch_tables = [
    "sales_by_product", "sales_by_customer", "sales_by_time",
    "sales_by_store", "sales_by_supplier", "product_quality"
]
ch_conn = spark._jvm.java.sql.DriverManager.getConnection(ch_url, "spark", "spark123")
ch_stmt = ch_conn.createStatement()
for tbl in ch_tables:
    ch_stmt.execute(f"TRUNCATE TABLE reports.{tbl}")
ch_stmt.close()
ch_conn.close()
print("таблицы ClickHouse очищены")

fact = spark.read.jdbc(url=pg_url, table="fact_sales", properties=pg_props)
products = spark.read.jdbc(url=pg_url, table="dim_product", properties=pg_props)
customers = spark.read.jdbc(url=pg_url, table="dim_customer", properties=pg_props)
dates = spark.read.jdbc(url=pg_url, table="dim_date", properties=pg_props)
stores = spark.read.jdbc(url=pg_url, table="dim_store", properties=pg_props)
suppliers = spark.read.jdbc(url=pg_url, table="dim_supplier", properties=pg_props)

def save(df, table):
    df.write.jdbc(url=ch_url, table="reports." + table, mode="append", properties=ch_props)
    print(table + ": " + str(df.count()) + " строк")

fp = fact.join(products, "product_id")
fc = fact.join(customers, "customer_id")
fd = fact.join(dates, "date_id")
fs = fact.join(stores, "store_id")
fsup = fact.join(suppliers, "supplier_id")

sales_by_product = fp.groupBy("product_id", "product_name", "category", "brand").agg(
    F.round(F.sum("total_amount"), 2).alias("total_revenue"),
    F.sum("quantity").alias("total_quantity"),
    F.round(F.avg("rating"), 2).alias("avg_rating"),
    F.sum("review_count").alias("total_reviews")
).withColumn("revenue_rank", F.rank().over(Window.orderBy(F.desc("total_revenue"))).cast("int"))
save(sales_by_product, "sales_by_product")

sales_by_customer = fc.groupBy("customer_id", "first_name", "last_name", "email", "country").agg(
    F.round(F.sum("total_amount"), 2).alias("total_spent"),
    F.count("*").alias("order_count"),
    F.round(F.avg("total_amount"), 2).alias("avg_check")
).withColumn("full_name", F.concat_ws(" ", "first_name", "last_name")) \
 .withColumn("spending_rank", F.rank().over(Window.orderBy(F.desc("total_spent"))).cast("int")) \
 .select("customer_id", "full_name", "email", "country", "total_spent", "order_count", "avg_check", "spending_rank")
save(sales_by_customer, "sales_by_customer")

sales_by_time = fd.groupBy("year", "month").agg(
    F.round(F.sum("total_amount"), 2).alias("total_revenue"),
    F.count("*").alias("total_orders"),
    F.round(F.avg("total_amount"), 2).alias("avg_order_size")
).withColumn("period", F.concat_ws("-", F.col("year").cast("string"), F.lpad(F.col("month").cast("string"), 2, "0"))) \
 .select("year", "month", "period", "total_revenue", "total_orders", "avg_order_size") \
 .orderBy("year", "month")
save(sales_by_time, "sales_by_time")

sales_by_store = fs.groupBy("store_id", "store_name", "city", "country").agg(
    F.round(F.sum("total_amount"), 2).alias("total_revenue"),
    F.count("*").alias("total_orders"),
    F.round(F.avg("total_amount"), 2).alias("avg_check")
).withColumn("revenue_rank", F.rank().over(Window.orderBy(F.desc("total_revenue"))).cast("int"))
save(sales_by_store, "sales_by_store")

sales_by_supplier = fsup.groupBy("supplier_id", "supplier_name", "country").agg(
    F.round(F.sum("total_amount"), 2).alias("total_revenue"),
    F.round(F.avg("unit_price"), 2).alias("avg_price"),
    F.count("*").alias("total_orders")
).withColumn("revenue_rank", F.rank().over(Window.orderBy(F.desc("total_revenue"))).cast("int"))
save(sales_by_supplier, "sales_by_supplier")

product_quality = fp.groupBy("product_id", "product_name", "category", "brand").agg(
    F.round(F.avg("rating"), 2).alias("avg_rating"),
    F.sum("review_count").alias("total_reviews"),
    F.sum("quantity").alias("total_sales"),
    F.round(F.sum("total_amount"), 2).alias("total_revenue")
).withColumn("quality_rank", F.rank().over(Window.orderBy(F.desc("avg_rating"))).cast("int"))
save(product_quality, "product_quality")

print("готово")
spark.stop()
