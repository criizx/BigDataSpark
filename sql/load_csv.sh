#!/bin/sh
echo ">>> ждем постгрю"
until pg_isready -h "$PGHOST" -U "$PGUSER"; do sleep 2; done

echo ">>> загружаем csv"
COLS="id,customer_first_name,customer_last_name,customer_age,customer_email,customer_country,customer_postal_code,customer_pet_type,customer_pet_name,customer_pet_breed,seller_first_name,seller_last_name,seller_email,seller_country,seller_postal_code,product_name,product_category,product_price,product_quantity,sale_date,sale_customer_id,sale_seller_id,sale_product_id,sale_quantity,sale_total_price,store_name,store_location,store_city,store_state,store_country,store_phone,store_email,pet_category,product_weight,product_color,product_size,product_brand,product_material,product_description,product_rating,product_reviews,product_release_date,product_expiry_date,supplier_name,supplier_contact,supplier_email,supplier_phone,supplier_address,supplier_city,supplier_country"

for FILE in /mock_data/MOCK_DATA.csv "/mock_data/MOCK_DATA (1).csv" "/mock_data/MOCK_DATA (2).csv" "/mock_data/MOCK_DATA (3).csv" "/mock_data/MOCK_DATA (4).csv" "/mock_data/MOCK_DATA (5).csv" "/mock_data/MOCK_DATA (6).csv" "/mock_data/MOCK_DATA (7).csv" "/mock_data/MOCK_DATA (8).csv" "/mock_data/MOCK_DATA (9).csv"; do
  if [ -f "$FILE" ]; then
    psql -c "\COPY mock_data($COLS) FROM '$FILE' CSV HEADER"
    echo "    $FILE готов"
  else
    echo "    файл $FILE нет"
  fi
done

COUNT=$(psql -t -c "SELECT COUNT(*) FROM mock_data;")
echo ">>> строк в mock_data:$COUNT"
