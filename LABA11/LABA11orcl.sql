select * from DRIVER;
select * from ORDERING;
select * from IMPORTING;
truncate table IMPORTING;
drop TABLE IMPORTING;
drop TABLE ORDERING;


-- �������� ������� ORDERING
CREATE TABLE ORDERING(
    ID NUMBER NOT NULL,
    CLIENT_ID NUMBER,
    DRIVER_ID NUMBER,
    INFO NVARCHAR2(300),
    DATETIME DATE,
    COST NUMBER NOT NULL
);

-- �������� ������� IMPORT
CREATE TABLE IMPORTING(
    ID NUMBER NOT NULL,
    CLIENT_ID NUMBER,
    DRIVER_ID NUMBER,
    INFO NVARCHAR2(300),
    DATETIME DATE,
    COST NUMBER NOT NULL
);

-- ������� ������ � ������� ORDERING
INSERT INTO ORDERING (ID, CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST)
VALUES (1, 1001, 2001, 'ORDEr �1', TO_TIMESTAMP('2024-05-09', 'YYYY-MM-DD HH24:MI:SS'), 50);

INSERT INTO ORDERING (ID, CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST)
VALUES (2, 1002, 2002, 'ORDER �2', TO_TIMESTAMP('2024-05-10', 'YYYY-MM-DD HH24:MI:SS'), 70);

INSERT INTO ORDERING (ID, CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST)
VALUES (3, 1003, 2003, 'ORDER �3', TO_TIMESTAMP('2024-05-11', 'YYYY-MM-DD HH24:MI:SS'), 85);

INSERT INTO ORDERING (ID, CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST)
VALUES (4, 1004, 2004, 'ORDER �4', TO_TIMESTAMP('2024-05-12', 'YYYY-MM-DD HH24:MI:SS'), 65);

INSERT INTO ORDERING (ID, CLIENT_ID, DRIVER_ID, INFO, DATETIME, COST)
VALUES (5, 1005, 2005, 'ORDER �5', TO_TIMESTAMP('2024-05-13', 'YYYY-MM-DD HH24:MI:SS'), 90);


sqlldr system/123 control='D:/BD/podobed.ctl' log='D:/BD/podobe.log' direct=true