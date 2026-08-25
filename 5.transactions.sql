-- ============================================================
-- transactions.csv


-- 1. Структура и тип данных
-- определить структуру таблицы и типы данных.

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'transactions.csv'
ORDER BY ORDINAL_POSITION;


-- 2. Объем данных
-- определить количество записей и посмотреть примеры данных.

SELECT TOP 5
    *,
    COUNT(*) OVER() AS row_count
FROM dbo.[transactions.csv];


-- 3. Дубликаты

SELECT
    TransactionID,
    COUNT(*) AS duplicate_count
FROM dbo.[transactions.csv]
GROUP BY TransactionID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, TransactionID;

SELECT
    COUNT(*) AS duplicated_transaction_ids,
    SUM(duplicate_count) AS rows_with_duplicates
FROM (
    SELECT
        TransactionID,
        COUNT(*) AS duplicate_count
    FROM dbo.[transactions.csv]
    GROUP BY TransactionID
    HAVING COUNT(*) > 1
) AS d;


SELECT *
FROM dbo.[transactions.csv]
WHERE TransactionID = 3002422;


-- 4. Пропуски и пустые значения


SELECT
    COUNT(*) AS total_rows,
    COUNT(TransactionID) AS transaction_id_filled,
    COUNT(AccountOriginID) AS account_origin_id_filled,
    COUNT(AccountDestinationID) AS account_destination_id_filled,
    COUNT(TransactionTypeID) AS transaction_type_id_filled,
    COUNT(Amount) AS amount_filled,
    COUNT(TransactionDate) AS transaction_date_filled,
    COUNT(BranchID) AS branch_id_filled
FROM dbo.[transactions.csv];


-- 5. Корректность данных


SELECT   -- дата транзакции
    TransactionID,
    TransactionDate
FROM dbo.[transactions.csv]
WHERE TRY_CONVERT(DATE, TransactionDate) IS NULL
  AND TransactionDate IS NOT NULL
ORDER BY TransactionID;




-- 6. Связи с другими таблицами
-- Цель: проверка внешних ключей


SELECT DISTINCT  -- AccountOriginID - accounts
    t.AccountOriginID
FROM dbo.[transactions.csv] AS t
LEFT JOIN dbo.[accounts.csv] AS a
    ON t.AccountOriginID = a.AccountID
WHERE a.AccountID IS NULL;


SELECT DISTINCT -- AccountDestinationID - accounts
    t.AccountDestinationID
FROM dbo.[transactions.csv] AS t
LEFT JOIN dbo.[accounts.csv] AS a
    ON t.AccountDestinationID = a.AccountID
WHERE a.AccountID IS NULL;


SELECT DISTINCT -- TransactionTypeID - transaction_types
    t.TransactionTypeID
FROM dbo.[transactions.csv] AS t
LEFT JOIN dbo.[transaction_types.csv] AS tt
    ON t.TransactionTypeID = tt.TransactionTypeID
WHERE tt.TransactionTypeID IS NULL;


SELECT DISTINCT -- BranchID - branches
    t.BranchID
FROM dbo.[transactions.csv] AS t
LEFT JOIN dbo.[branches.csv] AS b
    ON t.BranchID = b.BranchID
WHERE b.BranchID IS NULL;



-- Результаты: 
-- 1. Дубликаты: обнаружено 500 дубликатов TransactionID, всего дублирующих строк 1000. Провели проверку отдельных записей и было обнаружено, что являются полными копиями строк 
-- 2. Связи: лишних или пустых связей нет 


