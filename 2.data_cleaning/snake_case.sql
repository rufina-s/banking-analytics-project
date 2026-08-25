-- Приводим названия колонок к единому стилю

-- Финальные рабочие таблицы:
-- customers_clean
-- accounts_clean
-- loans_clean
-- transactions_clean
--
-- На этом этапе изменяем только названия колонок.

-- 1.customers
EXEC sp_rename 'dbo.customers_clean.CustomerID', 'customer_id', 'COLUMN';
EXEC sp_rename 'dbo.customers_clean.FirstName', 'first_name', 'COLUMN';
EXEC sp_rename 'dbo.customers_clean.LastName', 'last_name', 'COLUMN';
EXEC sp_rename 'dbo.customers_clean.DateOfBirth', 'date_of_birth', 'COLUMN';
EXEC sp_rename 'dbo.customers_clean.AddressID', 'address_id', 'COLUMN';
EXEC sp_rename 'dbo.customers_clean.CustomerTypeID', 'customer_type_id', 'COLUMN';


-- 2. accounts
EXEC sp_rename 'dbo.accounts_clean.AccountID', 'account_id', 'COLUMN';
EXEC sp_rename 'dbo.accounts_clean.CustomerID', 'customer_id', 'COLUMN';
EXEC sp_rename 'dbo.accounts_clean.AccountTypeID', 'account_type_id', 'COLUMN';
EXEC sp_rename 'dbo.accounts_clean.AccountStatusID', 'account_status_id', 'COLUMN';
EXEC sp_rename 'dbo.accounts_clean.Balance', 'balance', 'COLUMN';
EXEC sp_rename 'dbo.accounts_clean.OpeningDate', 'opening_date', 'COLUMN';


-- 3. loans
EXEC sp_rename 'dbo.loans_clean.LoanID', 'loan_id', 'COLUMN';
EXEC sp_rename 'dbo.loans_clean.AccountID', 'account_id', 'COLUMN';
EXEC sp_rename 'dbo.loans_clean.LoanStatusID', 'loan_status_id', 'COLUMN';
EXEC sp_rename 'dbo.loans_clean.PrincipalAmount', 'principal_amount', 'COLUMN';
EXEC sp_rename 'dbo.loans_clean.InterestRate', 'interest_rate', 'COLUMN';
EXEC sp_rename 'dbo.loans_clean.StartDate', 'start_date', 'COLUMN';
EXEC sp_rename 'dbo.loans_clean.EstimatedEndDate', 'estimated_end_date', 'COLUMN';


-- 4. transactions
EXEC sp_rename 'dbo.transactions_clean.TransactionID', 'transaction_id', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.AccountOriginID', 'account_origin_id', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.AccountDestinationID', 'account_destination_id', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.TransactionTypeID', 'transaction_type_id', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.Amount', 'amount', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.TransactionDate', 'transaction_date', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.BranchID', 'branch_id', 'COLUMN';
EXEC sp_rename 'dbo.transactions_clean.Description', 'description', 'COLUMN';


-- 5. Проверка результатов
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME IN (
      'customers_clean',
      'accounts_clean',
      'loans_clean',
      'transactions_clean')
ORDER BY
    TABLE_NAME,
    ORDINAL_POSITION;


