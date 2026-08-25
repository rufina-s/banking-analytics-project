
-- accounts.csv

-- 1. Структура и тип данных
-- определить структуру таблицы и типы данных.

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'accounts.csv'
ORDER BY ORDINAL_POSITION;


-- 2. Объем данных
-- определить количество записей и посмотреть примеры данных.

SELECT TOP 5
    *,
    COUNT(*) OVER() AS row_count
FROM dbo.[accounts.csv];


-- 3. Дубликаты

SELECT
    AccountID,
    COUNT(*) AS duplicate_count
FROM dbo.[accounts.csv]
GROUP BY AccountID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, AccountID;



-- 4. Пропуски и пустые значения
-- выявить отсутствующие значения в основных полях.

SELECT
    COUNT(*) AS total_rows,
    COUNT(AccountID) AS account_id_filled,
    COUNT(CustomerID) AS customer_id_filled,
    COUNT(AccountTypeID) AS account_type_id_filled,
    COUNT(AccountStatusID) AS account_status_id_filled,
    COUNT(Balance) AS balance_filled,
    COUNT(OpeningDate) AS opening_date_filled
FROM dbo.[accounts.csv];


-- 5. Корректность данных

SELECT -- отрицательные остатки
    AccountID,
    Balance
FROM dbo.[accounts.csv]
WHERE Balance < 0
ORDER BY Balance;


SELECT -- некорректные даты открытия
    AccountID,
    OpeningDate
FROM dbo.[accounts.csv]
WHERE TRY_CONVERT(DATE, OpeningDate) IS NULL
  AND OpeningDate IS NOT NULL
ORDER BY AccountID;


-- 6. Связи с другими таблицами

SELECT DISTINCT   -- account - customer
    a.CustomerID
FROM dbo.[accounts.csv] AS a
LEFT JOIN dbo.[customers.csv] AS c
    ON a.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;


SELECT DISTINCT  -- account - account type
    a.AccountTypeID
FROM dbo.[accounts.csv] AS a
LEFT JOIN dbo.[account_types.csv] AS at
    ON a.AccountTypeID = at.AccountTypeID
WHERE at.AccountTypeID IS NULL;


SELECT DISTINCT   -- account - account status
    a.AccountStatusID
FROM dbo.[accounts.csv] AS a
LEFT JOIN dbo.[account_statuses.csv] AS ast
    ON a.AccountStatusID = ast.AccountStatusID
WHERE ast.AccountStatusID IS NULL;



-- Результаты:
-- 1. Обнаружено 16 дубликатов AccountID.
-- 2. OpeningDate нужно преобразовать в DATE
-- 3. Balance: обнаружны отриательные значения, не ошибка т.к это может быть отрицательный баланс
-- 4. Пропуски: NULL-значения не обнаружены
-- 5. Связи: лишних или пустых связей нет 


