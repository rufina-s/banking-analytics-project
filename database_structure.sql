--Выведим названия всех таблиц схемы dbo.
SELECT *
FROM information_schema.tables;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'dbo';

-- Все 11 таблиц датасета успешно загружены в базу bank_analitic,
-- схема dbo.

