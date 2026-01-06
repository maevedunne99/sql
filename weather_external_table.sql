-- Description: This script defines an external table mapping to a Google Sheet and performs weather analysis across different states.

DEFINE TABLE SampleWeatherData (
  format = 'trix',
  urls = 'https://docs.google.com/spreadsheets/d/1Xu1BRkX20AgfcCHF4lAYacDMLyBzSvjpVVIzwPyvnCk/edit?resourcekey=0--PHWL4bEEo1ZyreaxNorPA&gid=0#gid=0', 
  worksheet = 'WeatherData', 
  columns = [
    ('city', 'STRING', 'City'),
    ('state', 'STRING', 'State'),
    ('report_date', 'STRING', 'Date'),
    ('temp_f', 'INT64', 'Temp_F'),
    ('condition', 'STRING', 'Condition'),
    ('humidity', 'INT64', 'Humidity')
  ],
  header = TRUE,
  refer_columns_by_header = TRUE);

-- Query 1: Data Validation (Show all data)
SELECT * FROM SampleWeatherData;

-- Query 2: Aggregation (Average temperature by state)
SELECT
  state,
  AVG(temp_f) AS average_temp
FROM
  SampleWeatherData
GROUP BY
  state
ORDER BY
  average_temp DESC;
