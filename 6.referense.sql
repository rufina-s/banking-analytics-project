
-- reference

-- Проверяем все таблицы на уникальность ключей, чтобы не было каких либо искажений 


-- 1. Структура

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'customer_types.csv',
      'account_types.csv',
      'account_statuses.csv',
      'loan_statuses.csv',
      'transaction_types.csv',
      'branches.csv'
  )
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- 2. Дубликаты

SELECT
    CustomerTypeID,
    COUNT(*) AS duplicate_count
FROM dbo.[customer_types.csv]
GROUP BY CustomerTypeID
HAVING COUNT(*) > 1;


SELECT
    AccountTypeID,
    COUNT(*) AS duplicate_count
FROM dbo.[account_types.csv]
GROUP BY AccountTypeID
HAVING COUNT(*) > 1;


SELECT
    AccountStatusID,
    COUNT(*) AS duplicate_count
FROM dbo.[account_statuses.csv]
GROUP BY AccountStatusID
HAVING COUNT(*) > 1;


SELECT
    LoanStatusID,
    COUNT(*) AS duplicate_count
FROM dbo.[loan_statuses.csv]
GROUP BY LoanStatusID
HAVING COUNT(*) > 1;



SELECT
    TransactionTypeID,
    COUNT(*) AS duplicate_count
FROM dbo.[transaction_types.csv]
GROUP BY TransactionTypeID
HAVING COUNT(*) > 1;



SELECT
    BranchID,
    COUNT(*) AS duplicate_count
FROM dbo.[branches.csv]
GROUP BY BranchID
HAVING COUNT(*) > 1;


-- 3. Просмотр справочников

SELECT *
FROM dbo.[customer_types.csv];

SELECT *
FROM dbo.[account_types.csv];

SELECT *
FROM dbo.[account_statuses.csv];

SELECT *
FROM dbo.[loan_statuses.csv];

SELECT *
FROM dbo.[transaction_types.csv];

SELECT *
FROM dbo.[branches.csv];



-- Результат:
-- 1.Справочные таблицы имеют корректную структуру.
-- 2.Дубликаты ключей не обнаружены.
-- 3.Справочники готовы к использованию в JOIN и аналитике.