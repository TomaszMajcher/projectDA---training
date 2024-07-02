CREATE SCHEMA reporting;


CREATE OR REPLACE VIEW reporting.flight as
SELECT *,
    CASE 
        WHEN dep_delay_new > 0 THEN 1
        ELSE 0
    END AS is_delayed
FROM flight
WHERE cancelled != 0
;

CREATE OR REPLACE VIEW reporting.top_reliability_roads AS
SELECT 
    f.origin_airport_id, 
    a.name AS origin_airport_name,
    f.dest_airport_id,
    b.name AS dest_airport_name, 
    f.year,
    COUNT(f.id) AS cnt,
    ROUND(AVG(CASE WHEN f.dep_delay_new > 0 THEN 1 ELSE 0 END), 2) AS reliability,
    DENSE_RANK() OVER (ORDER BY ROUND(AVG(CASE WHEN f.dep_delay_new > 0 THEN 1 ELSE 0 END), 2)) AS nb
    
FROM flight AS f
LEFT JOIN airport_list AS a ON f.origin_airport_id = a.origin_airport_id
LEFT JOIN airport_list AS b ON f.dest_airport_id = b.origin_airport_id

GROUP BY 1, 2, 3, 4, 5
HAVING COUNT(f.id) > 10000

;

CREATE OR REPLACE VIEW reporting.year_to_year_comparision AS
SELECT 
    f.year,
    f.month,
    COUNT(f.id) AS flights_amount,
    ROUND(AVG(CASE WHEN f.dep_delay_new > 0 THEN 1 ELSE 0 END), 2) AS reliability
FROM flight AS f
GROUP BY f.year, f.month
;

CREATE OR REPLACE VIEW reporting.day_to_day_comparision AS
SELECT 
    f.year,
    f.day_of_week,
    COUNT(f.id) AS flights_amount
FROM flight AS f
GROUP BY f.year, f.day_of_week
;

CREATE OR REPLACE VIEW reporting.day_by_day_reliability AS
SELECT 
    TO_DATE(f.year || '-' || f.month || '-' || f.day_of_month, 'YYYY-MM-DD') AS date,
    ROUND(AVG(CASE WHEN f.dep_delay_new > 0 THEN 1 ELSE 0 END), 2) AS reliability
FROM flight AS f
GROUP BY f.year, f.month, f.day_of_month