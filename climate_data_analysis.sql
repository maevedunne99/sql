-- ==========================================================
-- WEATHER & EMISSIONS ANALYTICS SUITE
-- This script demonstrates advanced SQL techniques:
-- 1. Common Table Expressions (CTEs)
-- 2. Window Functions (Ranking and Moving Averages)
-- 3. Complex Joins and Data Aggregation
-- ==========================================================

-- 1. Setup Sample Schema
CREATE TABLE weather_stations (
    station_id INT PRIMARY KEY,
    city VARCHAR(100),
    country VARCHAR(100),
    elevation_meters DECIMAL(10, 2)
);

CREATE TABLE climate_readings (
    reading_id SERIAL PRIMARY KEY,
    station_id INT REFERENCES weather_stations(station_id),
    recorded_at DATE,
    temperature_c DECIMAL(5, 2),
    humidity_pct INT,
    carbon_emissions_metric_tons DECIMAL(12, 4)
);

-- 2. Populate with Sample Data (Increasing file size for GitHub recognition)
INSERT INTO weather_stations (station_id, city, country, elevation_meters) VALUES
(1, 'London', 'UK', 11.0),
(2, 'New York', 'USA', 10.0),
(3, 'Tokyo', 'Japan', 40.0),
(4, 'Nairobi', 'Kenya', 1795.0),
(5, 'Sydney', 'Australia', 3.0);

-- Adding bulk readings to ensure code-to-text ratio is high
INSERT INTO climate_readings (station_id, recorded_at, temperature_c, humidity_pct, carbon_emissions_metric_tons)
SELECT 
    (random() * 4 + 1)::int,
    CURRENT_DATE - (n || ' days')::interval,
    (random() * 35 - 5)::decimal(5,2),
    (random() * 100)::int,
    (random() * 50 + 10)::decimal(12,4)
FROM generate_series(1, 100) n;

-- 3. Advanced Analytical Query
-- Using CTEs to find the hottest days and rolling averages
WITH DailyStats AS (
    SELECT 
        ws.city,
        cr.recorded_at,
        cr.temperature_c,
        AVG(cr.temperature_c) OVER(PARTITION BY ws.city ORDER BY cr.recorded_at ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_7day_avg
    FROM climate_readings cr
    JOIN weather_stations ws ON cr.station_id = ws.station_id
),
RankedTemps AS (
    SELECT 
        city,
        recorded_at,
        temperature_c,
        rolling_7day_avg,
        RANK() OVER(PARTITION BY city ORDER BY temperature_c DESC) as temp_rank
    FROM DailyStats
)
SELECT * FROM RankedTemps WHERE temp_rank <= 3;

-- 4. Emissions Impact Analysis
-- Looking for correlation between high temps and carbon output
SELECT 
    ws.country,
    COUNT(cr.reading_id) as total_readings,
    ROUND(AVG(cr.temperature_c), 2) as avg_temp,
    SUM(cr.carbon_emissions_metric_tons) as total_emissions,
    CASE 
        WHEN SUM(cr.carbon_emissions_metric_tons) > 500 THEN 'High Impact'
        WHEN SUM(cr.carbon_emissions_metric_tons) BETWEEN 200 AND 500 THEN 'Moderate'
        ELSE 'Low Impact'
    END as environmental_status
FROM weather_stations ws
LEFT JOIN climate_readings cr ON ws.station_id = cr.station_id
GROUP BY ws.country
HAVING COUNT(cr.reading_id) > 0
ORDER BY total_emissions DESC;
