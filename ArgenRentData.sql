
-- Create target table 'alquileres' to store rental data.

CREATE TABLE alquileres (
	name VARCHAR(255),
	price VARCHAR(255),
	days VARCHAR(255),
	rooms VARCHAR(255),
	bathrooms VARCHAR(255),
	capacity VARCHAR(255),
	date DATE,
	province VARCHAR(255)
    );
    
-- Load data into 'alquileres' from a CSV file using LOAD DATA INFILE method.

LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\alquileres_database_2024-02-18.csv'
INTO TABLE alquileres  
FIELDS TERMINATED BY ','  
LINES TERMINATED BY '\n'  
IGNORE 1 LINES;

-- Adding numeric columns and determining currency.

ALTER TABLE alquileres
ADD COLUMN days_num DECIMAL (2,0),
ADD COLUMN rooms_num DECIMAL (2,0),
ADD COLUMN bathrooms_num DECIMAL (2,0),
ADD COLUMN capacity_num DECIMAL (2,0),
ADD COLUMN currency VARCHAR(3);

-- Updating columns with numeric values and currency classification.

UPDATE alquileres SET price_num = CAST(price AS DECIMAL(65,0)) WHERE price <> '';
UPDATE alquileres SET days_num = CAST(days AS DECIMAL(2,0)) WHERE days <> '';
UPDATE alquileres SET rooms_num = CAST(rooms AS DECIMAL(2,0)) WHERE rooms <> '';
UPDATE alquileres SET bathrooms_num = CAST(bathrooms AS DECIMAL(2,0)) WHERE bathrooms <> '';
UPDATE alquileres SET capacity_num = CAST(capacity AS DECIMAL(3,0)) WHERE capacity <> '';
UPDATE alquileres SET currency = CASE
	WHEN price_num < 7000 THEN 'USD'
    ELSE 'ARS'
END;

-- Creating a view 'rentals_ars' for analysis in Tableau.

CREATE VIEW rentals_ars AS
SELECT
	date,
    name,
	province,
    capacity_num AS capacity,
	CAST(price_num AS DECIMAL(10,0)) AS price,
    days_num AS days,
    currency, 
    CAST(price_num / days_num AS DECIMAL(20,0)) AS price_day, 
	CAST(CASE WHEN currency = 'USD' THEN ((price_num / days_num) * 1000) ELSE price_num / days_num END AS DECIMAL(10,0)) AS price_day_ars
FROM alquileres
WHERE 
	days_num IS NOT NULL 
    AND price_num NOT REGEXP '(.)\\1{4,}' -- Avoiding prices with repeating digits more than 4 times
    AND (CASE WHEN currency = 'USD' THEN ((price_num / days_num) * 1000) ELSE price_num / days_num END) BETWEEN 10000 AND 100000
    AND date <> '2024-02-10'
ORDER BY price_day_ars DESC;