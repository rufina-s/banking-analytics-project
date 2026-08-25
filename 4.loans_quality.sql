
-- loans.csv


-- 1. Структура и тип данных
-- определить структуру таблицы и типы данных.

SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'loans.csv'
ORDER BY ORDINAL_POSITION;


-- 2. Объем данных
-- определить количество записей и посмотреть примеры данных.

SELECT TOP 5
    *,
    COUNT(*) OVER() AS row_count
FROM dbo.[loans.csv];


-- 3. Дубликаты

SELECT
    LoanID,
    COUNT(*) AS duplicate_count
FROM dbo.[loans.csv]
GROUP BY LoanID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, LoanID;



-- 4. Пропуски и пустые значения


SELECT
    COUNT(*) AS total_rows,
    COUNT(LoanID) AS loan_id_filled,
    COUNT(AccountID) AS account_id_filled,
    COUNT(LoanStatusID) AS loan_status_id_filled,
    COUNT(PrincipalAmount) AS principal_amount_filled,
    COUNT(InterestRate) AS interest_rate_filled,
    COUNT(StartDate) AS start_date_filled,
    COUNT(EstimatedEndDate) AS estimated_end_date_filled
FROM dbo.[loans.csv];


-- 5. Корректность данных


SELECT   -- некорректные StartDate
    LoanID,
    StartDate
FROM dbo.[loans.csv]
WHERE TRY_CONVERT(DATE, StartDate) IS NULL
  AND StartDate IS NOT NULL
ORDER BY LoanID;


SELECT    -- некорректные EstimatedEndDate
    LoanID,
    EstimatedEndDate
FROM dbo.[loans.csv]
WHERE TRY_CONVERT(DATE, EstimatedEndDate) IS NULL
  AND EstimatedEndDate IS NOT NULL
ORDER BY LoanID;


SELECT   -- не закрывается ли кредит раньше, чем начался
    LoanID,
    StartDate,
    EstimatedEndDate
FROM dbo.[loans.csv]
WHERE TRY_CONVERT(DATE, EstimatedEndDate)
    < TRY_CONVERT(DATE, StartDate)
ORDER BY LoanID;


SELECT    -- отрицательная сумма кредита 
    LoanID,
    PrincipalAmount
FROM dbo.[loans.csv]
WHERE PrincipalAmount < 0
ORDER BY PrincipalAmount;


SELECT    -- некорректная процентная ставка
    LoanID,
    InterestRate
FROM dbo.[loans.csv]
WHERE InterestRate < 0
   OR InterestRate > 100
ORDER BY InterestRate;


-- 6. Связи с другими таблицами
-- Цель: проверка внешних ключей


SELECT DISTINCT  -- Loan - Account
    l.AccountID
FROM dbo.[loans.csv] AS l
LEFT JOIN dbo.[accounts.csv] AS a
    ON l.AccountID = a.AccountID
WHERE a.AccountID IS NULL;


SELECT DISTINCT  -- Loan - Loan Status
    l.LoanStatusID
FROM dbo.[loans.csv] AS l
LEFT JOIN dbo.[loan_statuses.csv] AS ls
    ON l.LoanStatusID = ls.LoanStatusID
WHERE ls.LoanStatusID IS NULL;




-- Результаты:
-- 1. Структура: в PrincipalAmount хранится как REAL, StartDate и EstimatedEndDate хранятся как NVARCHAR(50) приведем к DATE, а денежные значения к DECIMAL.
-- 2. Обнаружено 3 дублирующихся LoanID
-- 3. Обнаружена запись, где EstimatedEndDate раньше StartDate, что является не логичным
-- 4. Обнаружена запись с датой начала кредита в будущем.
-- 5. Даты: Обнаружены записи с пустым EstimatedEndDate, это может быть из-за действующих кредитов
-- 6. Связи: лишних или пустых связей нет 



