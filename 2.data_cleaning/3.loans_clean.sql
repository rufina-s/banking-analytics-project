-- 3_loans_cleaning.sql

-- Исходная таблица: dbo.[loans.csv]
-- Рабочая таблица: dbo.loans_clean

-- В ходе проверки качества данных были обнаружены:
-- 1. Полные дубликаты LoanID
-- 2. Даты хранятся в формате NVARCHAR


-- 1. Создаем таблицу
SELECT DISTINCT
    LoanID,
    AccountID,
    LoanStatusID,
    PrincipalAmount,
    InterestRate,
    TRY_CONVERT(DATE, StartDate) AS StartDate,
    TRY_CONVERT(DATE, EstimatedEndDate) AS EstimatedEndDate
INTO dbo.loans_clean
FROM dbo.[loans.csv];


-- 2. Проверяем количество  
SELECT COUNT(*) AS total_rows
FROM dbo.loans_clean;


-- 3. Проверяем дубликаты 
SELECT
    LoanID,
    COUNT(*) AS duplicate_count
FROM dbo.loans_clean
GROUP BY LoanID
HAVING COUNT(*) > 1
ORDER BY LoanID;

-- 4. Проверяем только дубли LoanID.
SELECT
    LoanID,
    COUNT(*) AS duplicate_count
FROM dbo.loans_clean
GROUP BY LoanID
HAVING COUNT(*) > 1
ORDER BY LoanID;



-- 5. Проверяем даты
SELECT
    LoanID,
    StartDate,
    EstimatedEndDate
FROM dbo.loans_clean
WHERE StartDate IS NULL
   OR EstimatedEndDate IS NULL;


SELECT
    LoanID,
    StartDate,
    EstimatedEndDate
FROM dbo.loans_clean
WHERE StartDate IS NULL;

SELECT
    LoanID,
    StartDate,
    EstimatedEndDate
FROM dbo.loans_clean
WHERE EstimatedEndDate IS NULL;


-- Результат: 
-- 1. Создана рабочая таблица loans_clean.
-- 2. Полные дубликаты удалены.
-- 3. StartDate и EstimatedEndDate преобразованы из NVARCHAR в DATE.
-- Некорректных или отсутствующих дат не обнаружено.

