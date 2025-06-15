-- Топ-5 самых популярных моделей велосипедов за последние 3 месяца (по количеству аренд):

SELECT b.model, COUNT(*) AS rental_count
FROM rentals r
JOIN bikes b ON r.bike_id = b.bike_id
WHERE r.start_time >= CURRENT_DATE - INTERVAL '3 month'
GROUP BY b.model
ORDER BY rental_count DESC
LIMIT 5;
