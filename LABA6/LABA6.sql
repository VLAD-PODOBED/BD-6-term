select * from "ORDER";

drop table "ORDER";
DELETE FROM "ORDER";

INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
   (3, 2, 'Home delivery of groceries', TO_DATE('2023-01-19 14:30:00', 'YYYY-MM-DD HH24:MI:SS'), 30.00, 2, 'Tauentzienstra?e 17, 10789 Berlin', 'Tauentzienstra?e 17, 10789 Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
   (1, 3, 'Business meeting with client from Moscow', TO_DATE('2022-08-17 10:30:00', 'YYYY-MM-DD HH24:MI:SS'), 250.00, 1, 'Frankfurt, Germany', 'Saint Petersburg');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
   (3, 2, 'Home delivery of groceries', TO_DATE('2023-01-19 14:30:00', 'YYYY-MM-DD HH24:MI:SS'), 30.00, 2, 'Tauentzienstra?e 17, 10789 Berlin', 'Tauentzienstra?e 17, 10789 Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
   (1, 2, 'City tour', TO_DATE('2020-03-20 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 500.00, 1, 'Berlin City Hall (Rathaus Berlin)', 'Berlin City Hall (Rathaus Berlin)');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
    (3, 3, 'Night out with friends', TO_DATE('2023-11-21 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 150.00, 1, 'Potsdamer Platz, 10785 Berlin', 'Potsdamer Platz, 10785 Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
    (3, 2, 'Shopping trip', TO_DATE('2023-09-05 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 80.00, 1, 'Kurf?rstendamm, 10707 Berlin', 'Kurf?rstendamm, 10707 Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
     (2, 2, 'Sightseeing tour', TO_DATE('2022-12-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS'), 300.00, 1, 'Brandenburg Gate, 10117 Berlin', 'Brandenburg Gate, 10117 Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
   (3, 3, 'Dinner reservation', TO_DATE('2022-05-22 19:30:00', 'YYYY-MM-DD HH24:MI:SS'), 120.00, 1, 'Alexanderplatz, 10178 Berlin', 'Alexanderplatz, 10178 Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
    (1, 1, 'Medical appointment', TO_DATE('2023-07-10 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 50.00, 1, 'Charit? - Universit?tsmedizin Berlin', 'Charit? - Universit?tsmedizin Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
     (2, 3, 'Music concert', TO_DATE('2021-09-08 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 200.00, 1, 'Mercedes-Benz Arena, Berlin', 'Mercedes-Benz Arena, Berlin');
INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST, STATUS, DESTINATION, ARRIVAL)
VALUES
   (2, 2, 'Business lunch', TO_DATE('2023-04-12 13:00:00', 'YYYY-MM-DD HH24:MI:SS'), 70.00, 1, 'Potsdamer Platz, 10785 Berlin', 'Potsdamer Platz, 10785 Berlin');
--3 Вычисление итогов предоставленных услуг помесячно, за квартал, за полгода, за год.

WITH CTE AS (
    SELECT 
        EXTRACT(YEAR FROM DATETIME) AS "Year",
        TO_NUMBER(TO_CHAR(DATETIME, 'Q')) AS "Quarter",
        EXTRACT(MONTH FROM DATETIME) AS "Month",
        CASE 
            WHEN EXTRACT(MONTH FROM DATETIME) <= 6 THEN 1
            ELSE 2
        END AS "HalfYear",
        COST
    FROM "ORDER"
)
SELECT 
    "Year",
    "Quarter",
    "Month",
    "HalfYear",
    SUM(COST) OVER (PARTITION BY "Year", "Quarter") AS QuarterTotal,
    SUM(COST) OVER (PARTITION BY "Year", "HalfYear") AS HalfYearTotal,
    SUM(COST) OVER (PARTITION BY "Year", "Month") AS MonthYearTotal,
    SUM(COST) OVER (PARTITION BY "Year") AS YearTotal
FROM CTE;

--4 Вычисление итогов предоставленных услуг за определенный период:
--•	объем услуг;
--•	сравнение их с общим объемом услуг (в %);
--•	сравнение с максимальным объемом услуг (в %).

WITH ServiceTotals AS (
    SELECT 
        EXTRACT(YEAR FROM DATETIME) AS year,
        EXTRACT(MONTH FROM DATETIME) AS month,
        SUM(COST) AS total_cost
    FROM "ORDER"
    GROUP BY EXTRACT(YEAR FROM DATETIME), EXTRACT(MONTH FROM DATETIME)
), 
TotalService AS (
    SELECT 
        SUM(COST) AS total_cost
    FROM "ORDER"
),
MaxService AS (
    SELECT 
        MAX(total_cost) AS max_cost
    FROM (
        SELECT 
            EXTRACT(YEAR FROM DATETIME) AS year,
            SUM(COST) AS total_cost
        FROM "ORDER"
        GROUP BY EXTRACT(YEAR FROM DATETIME)
    ) YearlyTotals
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

--5.	Вернуть для каждого клиента направления последних 6 заказов.

WITH RankedOrders AS (
    SELECT 
        t.*, 
        ROW_NUMBER() OVER(PARTITION BY CLIENT_ID ORDER BY DATETIME DESC) AS rn
    FROM "ORDER" t
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


--6 Какой маршрут пользовался наибольшей популярностью для определенного типа автомобилей? Вернуть для всех типов.

WITH PopularRoutes AS (
    SELECT 
        CLIENT_ID, 
        DRIVER_ID, 
        INFO, 
        DESTINATION, 
        COUNT(*) AS popularity
    FROM "ORDER"
    GROUP BY CLIENT_ID, DRIVER_ID, INFO, DESTINATION
), RankedRoutes AS (
    SELECT 
        PR.*, 
        ROW_NUMBER() OVER(PARTITION BY PR.DRIVER_ID ORDER BY PR.popularity DESC) AS rn
    FROM PopularRoutes PR
)
SELECT 
    RR.DRIVER_ID, 
    RR.INFO AS ROUTE, 
    RR.DESTINATION, 
    RR.popularity AS POPULARITY
FROM RankedRoutes RR
WHERE rr.rn = 2;
