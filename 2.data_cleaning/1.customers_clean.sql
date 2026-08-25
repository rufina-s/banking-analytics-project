-- customers_cleaning.sql


-- Исходная таблица: dbo.[customers.csv]
-- Рабочая таблица: dbo.customers_clean

-- В исходных данных было 1111 строк.
-- После удаления полных дубликатов осталось 1100 строк.

-- 1. Количесвто записей
SELECT COUNT(*) AS total_rows
FROM dbo.customers_clean;


-- 2. Проверка дубликатов
SELECT
    CustomerID,
    COUNT(*) AS duplicate_count
FROM dbo.customers_clean
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-- 3. Проверка пустых имен
SELECT
    CustomerID,
    FirstName,
    LastName
FROM dbo.customers_clean
WHERE FirstName IS NULL
   OR FirstName = ''
   OR LastName IS NULL
   OR LastName = '';

SELECT DISTINCT
    CustomerID,
    NULLIF(LTRIM(RTRIM(FirstName)), '') AS FirstName,
    NULLIF(LTRIM(RTRIM(LastName)), '') AS LastName,
    TRY_CONVERT(DATE, DateOfBirth) AS DateOfBirth,
    AddressID,
    CustomerTypeID
INTO dbo.customers_clean
FROM dbo.[customers.csv];

SELECT TOP 10 *
FROM dbo.customers_clean;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'customers_clean'
ORDER BY ORDINAL_POSITION;


-- 1. На этапе очистки данных были удалены полные дубликаты клиентов
-- 2. пустые значения в текстовых полях стандартизированы как NULL
-- 3. Дата рождения  преобразована из текстового типа в DATE
