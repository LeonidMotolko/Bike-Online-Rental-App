-- Общая выручка по каждому городу за последний квартал:

SELECT l.city, SUM(r.total_cost) AS total_revenue
FROM rentals r
JOIN locations l ON r.location_id = l.location_id
WHERE r.start_time >= CURRENT_DATE - INTERVAL '3 months'
GROUP BY l.city
ORDER BY total_revenue DESC;
