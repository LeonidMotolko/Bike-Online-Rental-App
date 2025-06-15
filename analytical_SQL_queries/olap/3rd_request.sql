--Распределение способов оплаты (доля каждого метода) за последние 6 месяцев:

WITH payments_last_6m AS (
  SELECT fp.method_sk, fp.amount
  FROM fact_payments fp
  JOIN dim_date d ON fp.date_key = d.date_key
  WHERE d.date_key >= (CURRENT_DATE - INTERVAL '6 months')
)
SELECT 
  dpm.method_name,
  COUNT(*) AS payment_count,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percent_of_total
FROM payments_last_6m pl6m
JOIN dim_payment_method dpm ON pl6m.method_sk = dpm.method_sk
GROUP BY dpm.method_name
ORDER BY payment_count DESC;
