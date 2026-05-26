#!/bin/bash

mkdir -p ./spark_jobs/jars

curl -L -o ./spark_jobs/jars/postgresql-42.7.3.jar \
  https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.3/postgresql-42.7.3.jar

curl -L -o ./spark_jobs/jars/clickhouse-jdbc-0.6.3-all.jar \
  https://repo1.maven.org/maven2/com/clickhouse/clickhouse-jdbc/0.6.3/clickhouse-jdbc-0.6.3-all.jar

echo "67"
ls -lh ./spark_jobs/jars/
