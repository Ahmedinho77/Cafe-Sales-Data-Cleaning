SELECT * FROM cafe_sales.clean_table;

INSERT clean_table
SELECT* FROM dirty_cafe_sales;

-- CHECK FOR DUPLICATES
SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY`Transaction ID`,Item)AS Row_num
FROM clean_table;
-- THERE WERE 20000 ROWS , DUE TO IMPORTING ERRORS
WITH CTEs AS(
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY`Transaction ID`,Item)AS Row_num
FROM clean_table
)
SELECT* 
FROM CTEs ;

CREATE TABLE `clean_table2` (
  `Transaction ID` text,
  `Item` text,
  `Quantity` text,
  `Price Per Unit` text,
  `Total Spent` text,
  `Payment Method` text,
  `Location` text,
  `Transaction Date` text,
  `Row_num` INT 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO clean_table2
SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY`Transaction ID`,Item)AS Row_num
FROM clean_table;

DELETE FROM clean_table2
WHERE Row_num>1;

SELECT*
FROM clean_table2
WHERE Row_num>1;

ALTER TABLE clean_table2
DROP Row_num;

-- STANDARDIZING THE DATA

SELECT *
FROM clean_table2;

-- ITEM COLUMN

SELECT DISTINCT Item
FROM clean_table2;

UPDATE clean_table2
SET Item="Not Provided"
WHERE Item = "" ;

UPDATE clean_table2
SET Item="Unknown"
WHERE Item = "UNKNOWN" ;

UPDATE clean_table2
SET Item="Error"
WHERE Item = "ERROR" ;

-- THE BLANKS BECAME "NOT PROVIDED"

-- QUANTITY COLUMN 

SELECT DISTINCT Quantity
FROM clean_table2;

SELECT DISTINCT Quantity,CASE 
        WHEN Quantity REGEXP '^[0-9]+$' THEN Quantity
        ELSE NULL
    END AS Num,CASE 
        WHEN Quantity = 'ERROR' THEN 'Error'
        WHEN Quantity = 'UNKNOWN' THEN 'Unknown'
        WHEN Quantity = '' THEN 'Not Provided'
        ELSE 'Provided'
    END AS Quantity_Note
FROM clean_table2;

ALTER TABLE clean_table2
ADD COLUMN Quantity_Note VARCHAR(50) AFTER Quantity;

UPDATE clean_table2 
SET Quantity_Note = CASE 
        WHEN Quantity = 'ERROR' THEN 'Error'
        WHEN Quantity = 'UNKNOWN' THEN 'Unknown'
        WHEN Quantity = '' THEN 'Not Provided'
        ELSE 'Provided'
    END;

UPDATE clean_table2
SET Quantity= CASE 
        WHEN Quantity REGEXP '^[0-9]+$' THEN Quantity
        ELSE NULL
        END;

SELECT DISTINCT Quantity,Quantity_Note
FROM clean_table2;

-- LETS CLEAN PRICE PER UNIT COLUMN


SELECT DISTINCT `Price Per Unit`,CASE 
        WHEN `Price Per Unit` REGEXP '^[0-9]+\.?[0-9]*$' THEN `Price Per Unit`
        ELSE NULL
    END AS Num,CASE 
        WHEN `Price Per Unit` = 'ERROR' THEN 'Error'
        WHEN `Price Per Unit` = 'UNKNOWN' THEN 'Unknown'
        WHEN `Price Per Unit` = '' THEN 'Not Provided'
        ELSE 'Provided'
    END AS Price_Per_Unit_Note
FROM clean_table2;

ALTER TABLE clean_table2
ADD COLUMN Price_per_unit_Note VARCHAR(50) AFTER `Price Per Unit`;

UPDATE clean_table2
SET Price_per_unit_Note = CASE 
        WHEN `Price Per Unit` = 'ERROR' THEN 'Error'
        WHEN `Price Per Unit` = 'UNKNOWN' THEN 'Unknown'
        WHEN `Price Per Unit` = '' THEN 'Not Provided'
        ELSE 'Provided'
    END;

UPDATE clean_table2
SET `Price Per Unit`=CASE 
        WHEN `Price Per Unit` REGEXP '^[0-9]+\.?[0-9]*$' THEN `Price Per Unit`
        ELSE NULL
    END ;

SELECT DISTINCT `Price Per Unit`,Price_per_unit_Note
FROM clean_table2;

-- LETS CLEAN TOTAL SPENT COLUMN

SELECT DISTINCT `Total Spent`,CASE 
        WHEN `Total Spent` REGEXP '^[0-9]+\.?[0-9]*$' THEN `Total Spent`
        ELSE NULL
    END AS Num,CASE 
        WHEN `Total Spent` = 'ERROR' THEN 'Error'
        WHEN `Total Spent` = 'UNKNOWN' THEN 'Unknown'
        WHEN `Total Spent` = '' THEN 'Not Provided'
        ELSE 'Provided'
    END AS Total_Spent_Note
FROM clean_table2;

ALTER TABLE clean_table2
ADD COLUMN Total_spent_Note VARCHAR(50) AFTER `Total Spent`;

UPDATE clean_table2
SET Total_Spent_Note = CASE 
        WHEN `Total Spent` = 'ERROR' THEN 'Error'
        WHEN `Total Spent` = 'UNKNOWN' THEN 'Unknown'
        WHEN `Total Spent` = '' THEN 'Not Provided'
        ELSE 'Provided'
    END;

UPDATE clean_table2
SET `Total Spent`=CASE 
        WHEN `Total Spent` REGEXP '^[0-9]+\.?[0-9]*$' THEN `Total Spent`
        ELSE NULL
    END ;
SELECT DISTINCT `Total Spent`,Total_spent_Note
FROM clean_table2;

-- Now We Can Calculate Because We moved the unknown blanks and Errors to New column that will keep them 


SELECT Quantity,`Price Per Unit`,`Total Spent`
FROM clean_table2;

-- Check if the formulas hold true for existing data
SELECT 
    Quantity,
    `Price Per Unit`,
    `Total Spent`,
    Quantity * `Price Per Unit` AS calculated_total,
    `Total Spent` / Quantity AS calculated_price,
    CASE 
        WHEN `Total Spent` IS NOT NULL AND Quantity IS NOT NULL 
             AND `Total Spent` != Quantity * `Price Per Unit` 
        THEN 'INCONSISTENT'
        ELSE 'OK'
    END AS data_quality
FROM clean_table2
WHERE Quantity IS NOT NULL 
  AND `Price Per Unit` IS NOT NULL 
  AND `Total Spent` IS NOT NULL;
  
  
-- See patterns of missing data
SELECT 
    CASE 
        WHEN Quantity IS NULL AND `Price Per Unit` IS NULL AND `Total Spent` IS NULL THEN 'All NULL'
        WHEN Quantity IS NULL AND `Price Per Unit` IS NULL THEN 'Missing Quantity & Price'
        WHEN Quantity IS NULL AND `Total Spent` IS NULL THEN 'Missing Quantity & Total'
        WHEN `Price Per Unit` IS NULL AND `Total Spent` IS NULL THEN 'Missing Price & Total'
        WHEN Quantity IS NULL THEN 'Only Quantity Missing'
        WHEN `Price Per Unit` IS NULL THEN 'Only Price Missing'
        WHEN `Total Spent` IS NULL THEN 'Only Total Missing'
        ELSE 'All Present'
    END AS missing_pattern,
    COUNT(*) AS count
FROM clean_table2
GROUP BY missing_pattern
ORDER BY count DESC;

-- Show current and calculated values
SELECT 
    Quantity,
    `Price Per Unit`,
    `Total Spent`,
    -- Calculate missing Quantity
    CASE 
        WHEN Quantity IS NULL AND `Total Spent` IS NOT NULL AND `Price Per Unit` IS NOT NULL 
             AND `Price Per Unit` != 0
        THEN `Total Spent` / `Price Per Unit`
        ELSE Quantity
    END AS calculated_quantity,
    
    -- Calculate missing Price Per Unit
    CASE 
        WHEN `Price Per Unit` IS NULL AND `Total Spent` IS NOT NULL AND Quantity IS NOT NULL 
             AND Quantity != 0
        THEN `Total Spent` / Quantity
        ELSE `Price Per Unit`
    END AS calculated_price,
    
    -- Calculate missing Total Spent
    CASE 
        WHEN `Total Spent` IS NULL AND Quantity IS NOT NULL AND `Price Per Unit` IS NOT NULL 
        THEN Quantity * `Price Per Unit`
        ELSE `Total Spent`
    END AS calculated_total,
    
    -- Flag rows that can be fixed
    CASE 
        WHEN (Quantity IS NULL AND `Total Spent` IS NOT NULL AND `Price Per Unit` IS NOT NULL AND `Price Per Unit` != 0)
          OR (`Price Per Unit` IS NULL AND `Total Spent` IS NOT NULL AND Quantity IS NOT NULL AND Quantity != 0)
          OR (`Total Spent` IS NULL AND Quantity IS NOT NULL AND `Price Per Unit` IS NOT NULL)
        THEN 'CAN BE CALCULATED'
        ELSE 'INSUFFICIENT DATA'
    END AS fixable_status
    
FROM clean_table2
WHERE Quantity IS NOT NULL 
   OR `Price Per Unit` IS NOT NULL 
   OR `Total Spent` IS NOT NULL;
   
-- Rows that can be fixed (have at least 2 values)
SELECT 
    Quantity,
    `Price Per Unit`,
    `Total Spent`,
    CASE 
        WHEN Quantity IS NULL AND `Total Spent` IS NOT NULL AND `Price Per Unit` IS NOT NULL 
        THEN `Total Spent` / `Price Per Unit`
        ELSE NULL
    END AS suggested_quantity,
    CASE 
        WHEN `Price Per Unit` IS NULL AND `Total Spent` IS NOT NULL AND Quantity IS NOT NULL 
        THEN `Total Spent` / Quantity
        ELSE NULL
    END AS suggested_price,
    CASE 
        WHEN `Total Spent` IS NULL AND Quantity IS NOT NULL AND `Price Per Unit` IS NOT NULL 
        THEN Quantity * `Price Per Unit`
        ELSE NULL
    END AS suggested_total
FROM clean_table2
WHERE (Quantity IS NULL AND `Total Spent` IS NOT NULL AND `Price Per Unit` IS NOT NULL AND `Price Per Unit` != 0)
   OR (`Price Per Unit` IS NULL AND `Total Spent` IS NOT NULL AND Quantity IS NOT NULL AND Quantity != 0)
   OR (`Total Spent` IS NULL AND Quantity IS NOT NULL AND `Price Per Unit` IS NOT NULL);
   
-- Lets start With Quantity , Where Quantity = Total Spent /Price Per Unit 
-- Quantity
UPDATE clean_table2
SET Quantity = `Total Spent` / `Price Per Unit`
WHERE Quantity IS NULL 
  AND `Total Spent` IS NOT NULL 
  AND `Price Per Unit` IS NOT NULL 
  AND `Price Per Unit` != 0;

UPDATE clean_table2
SET `Price Per Unit` = `Total Spent` / Quantity
WHERE `Price Per Unit` IS NULL 
  AND `Total Spent` IS NOT NULL 
  AND Quantity IS NOT NULL 
  AND Quantity != 0;

UPDATE clean_table2
SET `Total Spent` = Quantity * `Price Per Unit`
WHERE `Total Spent` IS NULL 
  AND Quantity IS NOT NULL 
  AND `Price Per Unit` IS NOT NULL;
  
-- Check how many were fixed
SELECT 
    'Quantity Fixed' AS fix_type,
    COUNT(*) AS rows_affected
FROM clean_table2
WHERE Quantity IS NOT NULL 
  AND `Total Spent` / `Price Per Unit` = Quantity;

-- Check remaining NULLs
SELECT 
    COUNT(CASE WHEN Quantity IS NULL THEN 1 END) AS quantity_nulls,
    COUNT(CASE WHEN `Price Per Unit` IS NULL THEN 1 END) AS price_nulls,
    COUNT(CASE WHEN `Total Spent` IS NULL THEN 1 END) AS total_nulls
FROM clean_table2;

-- Show rows that were fixed vs still NULL
SELECT 
    Quantity,
    `Price Per Unit`,
    `Total Spent`,
    CASE 
        WHEN Quantity IS NULL OR `Price Per Unit` IS NULL OR `Total Spent` IS NULL 
        THEN 'Still Missing Data'
        ELSE 'Complete'
    END AS status
FROM clean_table2
WHERE Quantity IS NULL 
   OR `Price Per Unit` IS NULL 
   OR `Total Spent` IS NULL
LIMIT 20;

-- Checking all calculations are correct
SELECT 
    Quantity,
    `Price Per Unit`,
    `Total Spent`,
    ROUND(Quantity * `Price Per Unit`, 2) AS calculated_total,
    CASE 
        WHEN ABS(Quantity * `Price Per Unit` - `Total Spent`) < 0.01 
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS validation
FROM clean_table2
WHERE Quantity IS NOT NULL 
  AND `Price Per Unit` IS NOT NULL 
  AND `Total Spent` IS NOT NULL;

SELECT Quantity,`Price Per Unit`,`Total Spent`
FROM clean_table2;

ALTER TABLE clean_table2
MODIFY Quantity INT,
MODIFY `Price Per Unit` INT,
MODIFY `Total Spent` INT;
-- PAYMENT METHOD COLUMN

SELECT DISTINCT `Payment Method`
FROM clean_table2;

SELECT DISTINCT `Payment Method`,CASE
				WHEN `Payment Method` = '' THEN 'Not Provided'
                WHEN `Payment Method` ='UNKNOWN' THEN 'Unknown'
                WHEN `Payment Method`='ERROR' THEN 'Error'
                ELSE `Payment Method`
			END AS fix
FROM clean_table2;

UPDATE clean_table2
SET `Payment Method` =CASE
				WHEN `Payment Method` = '' THEN 'Not Provided'
                WHEN `Payment Method` ='UNKNOWN' THEN 'Unknown'
                WHEN `Payment Method`='ERROR' THEN 'Error'
                ELSE `Payment Method`
			END;
            
SELECT DISTINCT `Payment Method`
FROM clean_table2;

-- LOCATION COLUMN
SELECT DISTINCT Location
FROM clean_table2;

SELECT DISTINCT Location,CASE
				WHEN Location = '' THEN 'Not Provided'
                WHEN Location ='UNKNOWN' THEN 'Unknown'
                WHEN Location='ERROR' THEN 'Error'
                ELSE Location
			END AS fix_location
FROM clean_table2;

UPDATE clean_table2
SET Location = CASE
				WHEN Location = '' THEN 'Not Provided'
                WHEN Location ='UNKNOWN' THEN 'Unknown'
                WHEN Location='ERROR' THEN 'Error'
                ELSE Location
			END;
SELECT DISTINCT Location
FROM clean_table2;

-- TRANSACTION DATE COLUMN
SELECT DISTINCT `Transaction Date`
FROM clean_table2;

SELECT DISTINCT `Transaction Date`,CASE
				WHEN `Transaction Date` = '' THEN 'Not Provided'
                WHEN `Transaction Date` ='UNKNOWN' THEN 'Unknown'
                WHEN `Transaction Date`='ERROR' THEN 'Error'
                ELSE 'Valid Date'
			END AS fix_Transaction_Date
FROM clean_table2;

ALTER TABLE clean_table2
ADD COLUMN fix_Transaction_Date_flag VARCHAR(50) AFTER `Transaction Date`;

UPDATE clean_table2
SET fix_Transaction_Date_flag = CASE
				WHEN `Transaction Date` = '' THEN 'Not Provided'
                WHEN `Transaction Date` ='UNKNOWN' THEN 'Unknown'
                WHEN `Transaction Date`='ERROR' THEN 'Error'
                ELSE 'Valid Date'
			END;

SELECT DISTINCT `Transaction Date`,CASE
				WHEN `Transaction Date` = '' THEN NULL
                WHEN `Transaction Date` ='UNKNOWN' THEN NULL
                WHEN `Transaction Date`='ERROR' THEN NULL
                ELSE `Transaction Date`
			END AS fix_Transaction_Date
FROM clean_table2;

UPDATE clean_table2
SET `Transaction Date` = CASE
				WHEN `Transaction Date` = '' THEN NULL
                WHEN `Transaction Date` ='UNKNOWN' THEN NULL
                WHEN `Transaction Date`='ERROR' THEN NULL
                ELSE `Transaction Date`
			END;

SELECT DISTINCT `Transaction Date`,fix_Transaction_Date_flag
FROM clean_table2;

ALTER TABLE clean_table2
MODIFY `Transaction Date` DATE;

-- DROP ROW_NUM COLUMN
ALTER TABLE clean_table2
DROP Row_num;

SELECT*
FROM clean_table2;

