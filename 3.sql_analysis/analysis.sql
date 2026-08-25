
-- Цель:
-- анализ клиентской базы, банковских счетов, кредитов и транзакционной активности.

-- Рабочие таблицы:
-- customers_clean
-- accounts_clean
-- loans_clean
-- transactions_clean


-- 1.Общая информация о клиентской базе

SELECT
    COUNT(*) AS total_customers,   -- сколько клиентов
    COUNT(DISTINCT customer_type_id) AS customer_types,  -- сколько разных типов клиентов
    COUNT(DISTINCT address_id) AS unique_addresses  -- сколько уникальных адресов
FROM dbo.customers_clean;

--- У нас 1 100 клиентов, которые относятся к 3 типам клиентов и имеют 720 уникальных адресов.


-- сколько клиентов приходится на каждый тип.
SELECT customer_type_id,
    COUNT(*) AS customer_count
FROM dbo.customers_clean
GROUP BY customer_type_id
ORDER BY customer_type_id DESC

-- Клиентская база состоит из трёх типов клиентов. Наиболее многочисленным является 3 (397 клиентов), наименее многочисленным — 1 (351 клиента) 


-- адреса, по которым зарегистрировано больше одного клиента
SELECT address_id,
    COUNT(*) AS customer_count
FROM dbo.customers_clean
GROUP BY address_id
HAVING COUNT(*) > 1
ORDER BY customer_count DESC


-- сколько адресов имеют больше одного клиента?
SELECT COUNT(*)
FROM (SELECT address_id,
    COUNT(*) AS customer_count
FROM dbo.customers_clean
GROUP BY address_id
HAVING COUNT(*) > 1
) AS address_count

--Из 720 уникальных адресов 276 (38,3%) используются несколькими клиентами, а 444 (61,7%) относятся только к одному клиенту.

--------------------------------------------------------------------------------------------------------------------------------

-- сколько счетов приходится на каждого клиента?
SELECT
    c.customer_id,
    COUNT(a.account_id) AS account_count
FROM dbo.customers_clean AS c
JOIN dbo.accounts_clean AS a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id
ORDER BY account_count DESC;

-- общий баланс всех счетов каждого клиента
SELECT
    c.customer_id,
    SUM (a.balance) AS sum_balance
FROM dbo.customers_clean AS c
JOIN dbo.accounts_clean AS a
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id
ORDER BY sum_balance DESC;

-- какие счета имеют кредиты и на какую сумму?
SELECT
    a.account_id,
    COUNT(l.loan_id) AS loan_count,
    SUM(l.principal_amount) AS total_loan_amount
FROM dbo.accounts_clean AS a
JOIN dbo.loans_clean AS l
    ON a.account_id = l.account_id
GROUP BY a.account_id
ORDER BY total_loan_amount DESC;

-- доля счетов с кредитом и без кредита
SELECT
    loan_flag,
    account_count,
    total_accounts,
    ROUND(account_count * 100.0 / total_accounts, 2) AS account_share
FROM (SELECT loan_flag, -- добавляем общее кол-во счетов 
    account_count,
    SUM(account_count) OVER () AS total_accounts
FROM(SELECT loan_flag,    -- счиатем счета по наличию кредита
    COUNT(*) AS account_count
FROM (
    SELECT     -- определяем есть ли счета или нет 
    a.account_id,
    CASE
        WHEN COUNT(l.loan_id) > 0 THEN 'Есть кредит'
        ELSE 'Нет кредита'
    END AS loan_flag
FROM dbo.accounts_clean AS a
LEFT JOIN dbo.loans_clean AS l
    ON a.account_id = l.account_id
GROUP BY a.account_id
) AS account_status
GROUP BY loan_flag
) AS account_count ) AS account_totals

-- 298 из 1 651 счета имеют кредит — 18,05%. Остальные 1 353 счета (81,95%) не связаны с кредитами.

-- ранжирование счетов по общей сумме кредитов
WITH account_loans AS (
    SELECT -- по каждому счёту количество кредитов и общая сумма
        a.account_id,
        COUNT(l.loan_id) AS loan_count,
        ROUND(SUM(l.principal_amount), 2) AS total_loan_amount
    FROM dbo.accounts_clean AS a
    JOIN dbo.loans_clean AS l
    
-- счета ранжированы по общей сумме выданных кредитов — от максимальной к минимальной.    
        ON a.account_id = l.account_id
    GROUP BY a.account_id
)
SELECT  -- ранжирование счетов по общей сумме кредитов
    account_id,
    loan_count,
    total_loan_amount,
    DENSE_RANK() OVER (ORDER BY total_loan_amount DESC) AS loan_amount_rank
FROM account_loans
ORDER BY loan_amount_rank;


--------------------------------------------------------------------------------------------------------------------------------


-- какой объём транзакций проходит по каждому типу операции?
SELECT transaction_type_id,
    COUNT(*) AS transaction_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM dbo.transactions_clean
GROUP BY transaction_type_id
ORDER BY total_amount DESC;

-- сколько исходящих транзакций и на какую сумму приходится на каждый счёт?
SELECT a.account_id,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_amount
FROM dbo.accounts_clean AS a
JOIN dbo.transactions_clean AS t
    ON a.account_id = t.account_origin_id
GROUP BY a.account_id
ORDER BY total_transaction_amount DESC;

-- какие счета получили больше всего денег?
SELECT
    a.account_id,
    COUNT(t.transaction_id) AS transaction_count,
    SUM(t.amount) AS total_transaction_amount
FROM dbo.accounts_clean AS a
JOIN dbo.transactions_clean AS t
    ON a.account_id = t.account_destination_id
GROUP BY a.account_id
ORDER BY total_transaction_amount DESC;


-- активность счетов: входящие и исходящие операции и общий оборот
WITH outgoing AS (
    SELECT
        account_origin_id AS account_id,
        COUNT(transaction_id) AS outgoing_count,
        ROUND(SUM(amount), 2) AS outgoing_amount
    FROM dbo.transactions_clean
    GROUP BY account_origin_id
),
incoming AS (
    SELECT
        account_destination_id AS account_id,
        COUNT(transaction_id) AS incoming_count,
        ROUND(SUM(amount), 2) AS incoming_amount
    FROM dbo.transactions_clean
    GROUP BY account_destination_id
)
SELECT
    COALESCE(o.account_id, i.account_id) AS account_id,
    COALESCE(o.outgoing_count, 0) AS outgoing_count,
    COALESCE(o.outgoing_amount, 0) AS outgoing_amount,
    COALESCE(i.incoming_count, 0) AS incoming_count,
    COALESCE(i.incoming_amount, 0) AS incoming_amount,
    COALESCE(o.outgoing_amount, 0) + COALESCE(i.incoming_amount, 0) AS total_turnover
FROM outgoing AS o
FULL OUTER JOIN incoming AS i
    ON o.account_id = i.account_id
ORDER BY total_turnover DESC;

-- total_turnover показывает общий объём входящих и исходящих операций по счёту за весь доступный период данных.



-- активность клиентов по транзакциям
SELECT
    c.customer_id,
    COUNT(t.transaction_id) AS outgoing_transaction_count,
    ROUND(SUM(t.amount), 2) AS outgoing_transaction_amount
FROM dbo.customers_clean AS c
JOIN dbo.accounts_clean AS a
    ON c.customer_id = a.customer_id
JOIN dbo.transactions_clean AS t
    ON a.account_id = t.account_origin_id
GROUP BY c.customer_id
ORDER BY outgoing_transaction_amount DESC;


-- ранжирование клиентов по объёму исходящих транзакций
WITH customer_activity AS (
    SELECT c.customer_id,
        COUNT(t.transaction_id) AS outgoing_transaction_count, -- количество исходящих транзакций клиента
        ROUND(SUM(t.amount), 2) AS outgoing_transaction_amount -- общая сумма исходящих транзакций клиента
    FROM dbo.customers_clean AS c
    JOIN dbo.accounts_clean AS a
        ON c.customer_id = a.customer_id
    JOIN dbo.transactions_clean AS t
        ON a.account_id = t.account_origin_id
    GROUP BY c.customer_id
)
SELECT customer_id,
    outgoing_transaction_count,
    outgoing_transaction_amount,
    DENSE_RANK() OVER (ORDER BY outgoing_transaction_amount DESC) AS transaction_amount_rank -- ранжирование клиентов
FROM customer_activity
ORDER BY transaction_amount_rank;

-- клиент 10458 занимает 1-е место по объёму исходящих транзакций — 755 595,12 при 300 исходящих операциях.

