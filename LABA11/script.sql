CREATE OR REPLACE TYPE RentalRecord AS OBJECT (
    carId NUMBER,
    userId NUMBER,
    dateStart TIMESTAMP,
    dateEnd TIMESTAMP,
    cost NUMBER(10, 2),
    success varchar(3)
);

CREATE OR REPLACE TYPE RentalTableType AS TABLE OF RentalRecord;

CREATE OR REPLACE FUNCTION GetRentalsByDateRange
(
    StartDate IN DATE,
    EndDate IN DATE
)
RETURN RentalTableType PIPELINED
AS
BEGIN
    FOR rental IN (
        SELECT carId, userId, dateStart, dateEnd, cost, success
        FROM Rental
        WHERE dateStart >= StartDate AND dateEnd <= EndDate
    ) LOOP
        PIPE ROW (RentalRecord(rental.carId, rental.userId, rental.dateStart, rental.dateEnd, rental.cost, rental.success));
    END LOOP;
    
    RETURN;
END;
/

INSERT INTO Rental (carId, userId, dateStart, dateEnd, cost, success)
VALUES
    (1, 1, TO_DATE('2024-02-17', 'YYYY-MM-DD'), TO_DATE('20/02/2024', 'DD/MM/YYYY'), 155.56, 'yes');

select * from Rental;    

--sqlldr system/Qwerty12345 CONTROL='C:\Users\oracledatabase\Desktop\MyLab\lab11\control.ctl'
SELECT * FROM TABLE(CAST(GetRentalsByDateRange(TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-04-10', 'YYYY-MM-DD')) AS RentalTableType));
