--Количество уникальных пользователей, арендовавших велосипеды за последние 3 месяца:

SELECT 
    COUNT(DISTINCT r.user_id) AS unique_renters
FROM rentals r
WHERE r.start_time >= CURRENT_DATE - INTERVAL '3 months';
