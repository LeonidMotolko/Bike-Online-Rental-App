--Динамика выручки по месяцам и категориям велосипедов за последний год:

SELECT 
  d.year, d.month, dbc.name AS category_name,
  SUM(fr.total_amount) AS revenue
FROM fact_rentals fr
JOIN dim_date d ON fr.date_key = d.date_key
JOIN dim_bike db ON fr.bike_sk = db.bike_sk
JOIN dim_bike_category dbc ON db.category_sk = dbc.category_sk
WHERE d.date_key >= (CURRENT_DATE - INTERVAL '1 year')
GROUP BY d.year, d.month, dbc.name
ORDER BY d.year, d.month, dbc.name;
