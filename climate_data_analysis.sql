-- Dialect: PostgreSQL

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

-- 2. Populate with Sample Data 
INSERT INTO weather_stations (station_id, city, country, elevation_meters) VALUES
(1, 'London', 'UK', 11.0),
(2, 'New York', 'USA', 10.0),
(3, 'Tokyo', 'Japan', 40.0),
(4, 'Nairobi', 'Kenya', 1795.0),
(5, 'Sydney', 'Australia', 3.0);

-- Adding bulk readings
INSERT INTO climate_readings (station_id, recorded_at, temperature_c, humidity_pct, carbon_emissions_metric_tons)
SELECT 
    (random() * 4 + 1)::int,
    CURRENT_DATE - (n || ' days')::interval,
    (random() * 35 - 5)::decimal(5,2),
    (random() * 100)::int,
    (random() * 50 + 10)::decimal(12,4)
FROM generate_series(1, 100) n;

-- 3. Intermediate Analytical Query
-- Aggregating climate profiles per city and filtering grouped data using HAVING
SELECT 
    ws.city,
    ws.country,
    MAX(cr.temperature_c) AS max_recorded_temp,
    MIN(cr.temperature_c) AS min_recorded_temp,
    ROUND(AVG(cr.humidity_pct), 1) AS avg_humidity
FROM weather_stations ws
JOIN climate_readings cr 
    ON ws.station_id = cr.station_id
GROUP BY 
    ws.city,
    ws.country
HAVING 
    AVG(cr.temperature_c) > 10 -- Filters the groups to only show cities with a warm average temp
ORDER BY 
    max_recorded_temp DESC;

-- 4. Emissions Impact Analysis
-- Looking for correlation between high temps and carbon output using Aggregation and CASE
SELECT 
    ws.country,
    COUNT(cr.reading_id) AS total_readings,
    ROUND(AVG(cr.temperature_c), 2) AS avg_temp,
    SUM(cr.carbon_emissions_metric_tons) AS total_emissions,
    CASE 
        WHEN SUM(cr.carbon_emissions_metric_tons) > 500 THEN 'High Impact'
        WHEN SUM(cr.carbon_emissions_metric_tons) BETWEEN 200 AND 500 THEN 'Moderate'
        ELSE 'Low Impact'
    END AS environmental_status
FROM weather_stations ws
LEFT JOIN climate_readings cr 
    ON ws.station_id = cr.station_id
GROUP BY 
    ws.country
HAVING 
    COUNT(cr.reading_id) > 0
ORDER BY 
    total_emissions DESC;
