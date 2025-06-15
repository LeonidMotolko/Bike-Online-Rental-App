--Средняя длительность аренды по категориям велосипедов и городам:

SELECT 
  dbc.name AS category_name, 
  dl.city,
  AVG(fr.duration_minutes) AS avg_duration_minutes
FROM fact_rentals fr
JOIN dim_bike db ON fr.bike_sk = db.bike_sk
JOIN dim_bike_category dbc ON db.category_sk = dbc.category_sk
JOIN dim_location dl ON fr.location_sk = dl.location_sk
GROUP BY dbc.name, dl.city
ORDER BY dbc.name, dl.city;
