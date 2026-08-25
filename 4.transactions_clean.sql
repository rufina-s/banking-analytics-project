-- 4_transactions_cleaning.sql

-- Исходная таблица: dbo.[transactions.csv]
-- Рабочая таблица:  dbo.transactions_clean
--
-- В ходе проверки качества данных были обнаружены:
-- 1. Полные дубликаты транзакций
-- 2. TransactionDate хранится как NVARCHAR
-- 3. Часть транзакций не имеет даты
-- 4. В данных присутствуют даты после 2023 года



-- 1. Создаем таблицы
SELECT DISTINCT

    TransactionID,
    AccountOriginID,
    AccountDestinationID,
    TransactionTypeID,
    Amount,
    -- Пустые значения преобразуем в NULL.
    -- Остальные значения преобразуем в DATETIME2.
    CASE
        WHEN LTRIM(RTRIM(TransactionDate)) = ''
            THEN NULL
        ELSE TRY_CONVERT(DATETIME2, TransactionDate)
    END AS TransactionDate,
    BranchID,
    Description
INTO dbo.transactions_clean
FROM dbo.[transactions.csv];


-- 2. Проверяем количество 
SELECT
    COUNT(*) AS total_rows
FROM dbo.transactions_clean;


-- 3. Проверяем дубликаты 
SELECT
    TransactionID,
    COUNT(*) AS duplicate_count
FROM dbo.transactions_clean
GROUP BY TransactionID
HAVING COUNT(*) > 1
ORDER BY TransactionID;


-- 4. Проверяем пропуски дат
SELECT
    COUNT(*) AS missing_transaction_date
FROM dbo.transactions_clean
WHERE TransactionDate IS NULL;


-- 5. Проверяем диапазон дат
SELECT
    MIN(TransactionDate) AS min_transaction_date,
    MAX(TransactionDate) AS max_transaction_date
FROM dbo.transactions_clean;


-- 6. ПРоверяем будущие даты
SELECT
    COUNT(*) AS future_transaction_dates
FROM dbo.transactions_clean
WHERE TransactionDate > '2023-12-31';

-- Результат:
-- Полные дубликаты транзакций удалены.
-- TransactionDate преобразован из NVARCHAR в DATETIME2.
-- Пустые значения TransactionDate преобразованы в NULL.
-- В исходных данных обнаружены даты после 2023 года с одинаковым техническим временем. Эти значения сохранены без изменения, они
-- присутствуют в исходном датасете.