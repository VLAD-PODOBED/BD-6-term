--������� ��� ������� ������
CREATE OR ALTER FUNCTION GetRentalsByDateRange
(
    @StartDate DATETIME,
    @EndDate DATETIME
)
RETURNS TABLE
AS
RETURN
(
    SELECT carId,userId,dateStart,dateEnd,cost
    FROM Rental
    WHERE dateStart >= @StartDate AND dateEnd <= @EndDate
)
--������ � ��������
SELECT *
FROM GetRentalsByDateRange('2024-01-01', '2024-04-10'); 

SELECT COUNT(*)
FROM GetRentalsByDateRange('2024-01-01', '2024-04-10'); 

delete from Rental;
--����: ����, �������������� ����� �� ������,decimal,������
select * from Rental;