-- accounts_cleaning.sql


-- Исходная таблица: dbo.[accounts.csv]
-- Рабочая таблица: dbo.accounts_clean

-- В ходе проверки качества данных были обнаружены:
-- 1. Полные дубликаты AccountID
-- 2. Отрицательные значения Balance
-- 3. OpeningDate хранится как NVARCHAR


-- 1. создаем таблицу accounts_clean
SELECT DISTINCT
    AccountID,
    CustomerID,
    AccountTypeID,
    AccountStatusID,
    Balance,
    TRY_CONVERT(DATE, OpeningDate) AS OpeningDate
INTO dbo.accounts_clean
FROM dbo.[accounts.csv];

SELECT COUNT(*) AS total_rows
FROM dbo.accounts_clean;

SELECT TOP 10 *
FROM dbo.accounts_clean;

SELECT
    AccountID,
    COUNT(*) AS duplicate_count
FROM dbo.accounts_clean
GROUP BY AccountID
HAVING COUNT(*) > 1
ORDER BY AccountID;


-- 2. Отриательный Balance
-- ранее по балансу получили отриательные значения
-- смотрим сколько их
SELECT
    COUNT(*) AS negative_balance_count
FROM dbo.accounts_clean
WHERE Balance < 0;

SELECT
    MIN(Balance) AS min_balance,
    MAX(Balance) AS max_balance
FROM dbo.accounts_clean;


-- 3. Проверка OpeningDate
SELECT
    AccountID,
    OpeningDate
FROM dbo.accounts_clean
WHERE OpeningDate IS NULL;


-- Результат:
-- 1. Обнаружено 10 счетов с отрицательным балансом.Значения не удаляем и не заменяем может быть задолженность клиента.
-- 2. Создана рабочая таблица accounts_clean.
-- 3. Полные дубликаты удалены.
-- 4. OpeningDate преобразован из NVARCHAR в DATE.
-- 5. Пропусков и некорректных дат не обнаружено.

