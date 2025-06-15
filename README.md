
# 🚲 Bike Online Rental App

Аналитическая система для онлайн-проката велосипедов.  
Курсовой проект по базам данных. Реализована полная цепочка: от OLTP до Power BI.

---

## 📁 Структура проекта

```
Bike-Online-Rental-App/
├── 01_oltp_model/           # OLTP-схема и ER-диаграмма
├── 02_data/                 # CSV-файлы с начальными данными
├── 03_python_generator/     # Python-скрипт генерации CSV
├── 04_olap_model/           # OLAP-схема и ETL-скрипт
├── 05_power_bi/             # Power BI отчёт + скриншоты
├── 06_queries/              # SQL-запросы для анализа
├── 07_docs/                 # Документация проекта (Word)
└── README.md                # Этот файл
```

---

## 🧰 Используемые технологии

- PostgreSQL (две базы: `bike_oltp`, `bike_olap`)
- Python 3.12 (генерация данных)
- Power BI (визуализация)
- pgAdmin + dblink (для ETL)
- Git + GitHub (хранение проекта)

---

## 🔍 Этапы реализации

### 📌 1. OLTP (операционная база)
- ER-модель нормализована
- Таблицы: `users`, `bikes`, `rentals`, `payments`, `locations`
- SQL-файл: `01_create_oltp_schema.sql`

### 📌 2. Генерация данных
- Python-скрипт: `main.py`
- Генерация `users.csv`, `rentals.csv`, `payments.csv` и др.
- Загрузка в PostgreSQL через `COPY`

### 📌 3. OLAP (аналитическая база)
- Снежинка-схема: `dim_*`, `fact_*`, `bridge_*`
- Используются surrogate keys и нормализация
- SQL-файл: `04_olap_schema.sql`

### 📌 4. ETL
- `dblink` между OLTP и OLAP
- Скрипт `05_etl_process.sql` — перенос измерений и фактов

### 📌 5. Power BI
- Визуализации:
  - 📈 Аренды по месяцам
  - 🥧 Категории велосипедов
  - 💳 Методы оплаты
- Отчёт: `bike_rental_olap_dashboard.pbix`

---

## 🧪 Примеры SQL-запросов

### OLTP
```sql
SELECT b.model, COUNT(*) AS rental_count
FROM rentals r
JOIN bikes b ON r.bike_id = b.bike_id
WHERE r.start_time >= CURRENT_DATE - INTERVAL '3 month'
GROUP BY b.model
ORDER BY rental_count DESC
LIMIT 5;
```

### OLAP
```sql
SELECT d.year, d.month, dbc.name AS category_name, SUM(fr.total_amount) AS revenue
FROM fact_rentals fr
JOIN dim_date d ON fr.date_key = d.date_key
JOIN dim_bike db ON fr.bike_sk = db.bike_sk
JOIN dim_bike_category dbc ON db.category_sk = dbc.category_sk
WHERE d.date_key >= (CURRENT_DATE - INTERVAL '1 year')
GROUP BY d.year, d.month, dbc.name
ORDER BY d.year, d.month, dbc.name;
```

---

## 📄 Документация

Полный отчёт проекта:  
📄 `Course_work_db.docx` (в папке `07_docs/`)

---
