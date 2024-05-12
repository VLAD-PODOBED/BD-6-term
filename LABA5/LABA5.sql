DELETE FROM "ORDER";


-- Отключение проверки внешних ключей
ALTER TABLE "ORDER" NOCHECK CONSTRAINT ALL;

-- Выполнение операции TRUNCATE TABLE
TRUNCATE TABLE "ORDER";

-- Включение проверки внешних ключей
ALTER TABLE "ORDER" CHECK CONSTRAINT ALL;

select * from [ORDER];

INSERT INTO [ORDER] (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, DESTINATION, ARRIVAL)
VALUES
   (1, 3, 'Business meeting with client from Moscow', '2022-08-17 10:30:00', 250.00, 'Frankfurt, Germany', 'Saint Petersburg'),
   (2, 1, 'Airport pickup', '2023-06-18 12:30:00', 100.00, 'Frankfurt Airport, Germany', 'Hotel Grand Hotel Europe'),
   (3, 2, 'Home delivery of groceries', '2023-01-19 14:30:00', 30.00, 'Tauentzienstraße 17, 10789 Berlin', 'Tauentzienstraße 17, 10789 Berlin'),
   (1, 2, 'City tour', '2023-03-20 16:00:00', 500.00, 'Berlin City Hall (Rathaus Berlin)', 'Berlin City Hall (Rathaus Berlin)'),
   (3, 3, 'Night out with friends', '2023-11-21 20:00:00', 150.00, 'Potsdamer Platz, 10785 Berlin', 'Potsdamer Platz, 10785 Berlin'),
    (4, 3, 'Night out with friends', '2023-11-21 20:00:00', 150.00, 'Potsdamer Platz, 10785 Berlin', 'Potsdamer Platz, 10785 Berlin');

-- 3 Вычисление итогов предоставленных услуг помесячно, за квартал, за полгода, за год.

WITH CTE AS (
    SELECT 
        DATEPART(YEAR, DATETIME) AS [Year],
        DATEPART(QUARTER, DATETIME) AS [Quarter],
        DATEPART(MONTH, DATETIME) AS [Month],
        CASE 
            WHEN DATEPART(MONTH, DATETIME) <= 6 THEN 1
            ELSE 2
        END AS [HalfYear],
        COST
    FROM [ORDER]
)
SELECT 
    [Year],
    [Quarter],
    [Month],
    [HalfYear],
    SUM(COST) OVER (PARTITION BY [Year], [Quarter]) AS QuarterTotal,
    SUM(COST) OVER (PARTITION BY [Year], [HalfYear]) AS HalfYearTotal,
	SUM(COST) OVER (PARTITION BY [Year], [Month]) AS MonthYearTotal,
    SUM(COST) OVER (PARTITION BY [Year]) AS YearTotal
FROM CTE;



-- 4 Вычисление итогов предоставленных услуг за определенный период:
--объем услуг;
--сравнение их с общим объемом услуг (в %);
--сравнение с максимальным объемом услуг (в %).
WITH ServiceTotals AS (
    SELECT 
        YEAR(DATETIME) AS year,
        MONTH(DATETIME) AS month,
        SUM(COST) AS total_cost
    FROM [ORDER]
    GROUP BY YEAR(DATETIME), MONTH(DATETIME)
), 
TotalService AS (
    SELECT 
        SUM(COST) AS total_cost
    FROM [ORDER]
),
MaxService AS (
    SELECT 
        MAX(total_cost) AS max_cost
    FROM (
        SELECT 
            YEAR(DATETIME) AS year,
            SUM(COST) AS total_cost
        FROM [ORDER]
        GROUP BY YEAR(DATETIME)
    ) AS YearlyTotals
)
SELECT 
    ST.year,
    ST.month,
    ST.total_cost AS service_total,
    ST.total_cost / TS.total_cost * 100 AS service_percentage,
    ST.total_cost / 500 * 100 AS service_percentage_max
FROM ServiceTotals ST
CROSS JOIN TotalService TS
CROSS JOIN MaxService MS
ORDER BY ST.year, ST.month;

------------------------------------------------------------
--5.	Премонстрируйте применение функции ранжирования ROW_NUMBER() од
--для разбиения результатов запроса на страницы (по 20 строк на каждую страницу).
--------
WITH OrderedOrders AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY DATETIME) AS RowNum
    FROM [ORDER]
)
SELECT * 
FROM OrderedOrders
WHERE RowNum BETWEEN 1 AND 6; 

--6.	Продемонстрируйте применение функции ранжирования ROW_NUMBER() для удаления дубликатов.

WITH OrderedOrders AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, DESTINATION, ARRIVAL ORDER BY (SELECT NULL)) AS RowNum
    FROM [ORDER]
)
DELETE FROM OrderedOrders
WHERE RowNum > 1;

select * from [ORDER]

--7 Вернуть для каждого клиента направления последних 6 заказов.
WITH RankedOrders AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER(PARTITION BY CLIENT_ID ORDER BY DATETIME DESC) AS rn
    FROM [ORDER]
)
SELECT 
    CLIENT_ID, 
    DRIVER_ID, 
    INFO, 
    DATETIME, 
    COST, 
    DESTINATION, 
    ARRIVAL
FROM RankedOrders
WHERE rn <= 3;

--8 Какой маршрут пользовался наибольшей популярностью для определенного типа автомобилей? Вернуть для всех типов.

WITH PopularRoutes AS (
    SELECT 
        CLIENT_ID, 
        DRIVER_ID, 
        INFO, 
        DESTINATION, 
        COUNT(*) AS popularity
    FROM [ORDER]
    GROUP BY CLIENT_ID, DRIVER_ID, INFO, DESTINATION
), RankedRoutes AS (
    SELECT 
        *, 
        ROW_NUMBER() OVER(PARTITION BY DRIVER_ID ORDER BY popularity DESC) AS rn
    FROM PopularRoutes
)
SELECT 
    DRIVER_ID, 
    INFO AS ROUTE, 
    DESTINATION, 
    popularity AS POPULARITY
FROM RankedRoutes
WHERE rn = 1;
