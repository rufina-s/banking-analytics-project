-- customers.csv

-- 1. Структура и тип данных
-- определить структуру таблицы и типы данных.

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'customers.csv'
ORDER BY ORDINAL_POSITION;


-- 2. Объем данных
-- определить количество записей и посмотреть примеры данных.

SELECT TOP 5
    *,
    COUNT(*) OVER() AS row_count
FROM dbo.[customers.csv];


-- 3. Дубликаты
-- проверить уникальность идентификатора клиента.

SELECT
    CustomerID,
    COUNT(*) AS duplicate_count
FROM dbo.[customers.csv]
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, CustomerID;



-- 4. Пропуски и пустые значения
-- выявить отсутствующие значения в основных полях.

SELECT
    SUM(CASE WHEN FirstName IS NULL OR FirstName = '' THEN 1 ELSE 0 END) AS empty_first_name,
    SUM(CASE WHEN LastName IS NULL OR LastName = '' THEN 1 ELSE 0 END) AS empty_last_name
FROM dbo.[customers.csv];

SELECT
    COUNT(*) AS total_rows,
    COUNT(CustomerID) AS customer_id_filled,
    COUNT(FirstName) AS first_name_filled,
    COUNT(LastName) AS last_name_filled,
    COUNT(DateOfBirth) AS date_of_birth_filled,
    COUNT(AddressID) AS address_id_filled,
    COUNT(CustomerTypeID) AS customer_type_id_filled
FROM dbo.[customers.csv];


-- 5. Проверка дат
-- ищем некорректные даты рождения

SELECT
    CustomerID,
    DateOfBirth
FROM dbo.[customers.csv]
WHERE TRY_CONVERT(DATE, DateOfBirth) IS NULL
  AND DateOfBirth IS NOT NULL
ORDER BY CustomerID;


-- 6. Связи с другими таблицами
-- Цель: проверка внешних ключей


SELECT DISTINCT -- Проверка CustomerTypeID
    c.CustomerTypeID
FROM dbo.[customers.csv] AS c
LEFT JOIN dbo.[customer_types.csv] AS ct
    ON c.CustomerTypeID = ct.CustomerTypeID
WHERE ct.CustomerTypeID IS NULL;


SELECT DISTINCT -- Проверка AddressID
    c.AddressID
FROM dbo.[customers.csv] AS c
LEFT JOIN dbo.[addresses.csv] AS a
    ON c.AddressID = a.AddressID
WHERE a.AddressID IS NULL;



-- Результаты:
-- 1. Структура: в DateOfBirth хранится NVARCHAR, нужно преобразовать в DATE
-- 2. Объем состоит из 1111 записей
-- 3. Дубликаты: обнаружно 11 CustomerID, каждый встречается дважды
-- 4. Пропуски: NULL в основных полях не обнаружены, были обнаружены пустые/некорректные текстовые значения
-- 5. Даты: Обнаружены некорректные значения в DateOfBirth
-- 6. Связи: лишних или пустых связей нет 


  
  
  
