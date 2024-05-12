
CREATE OR REPLACE TYPE OrderTy AS OBJECT (
   id NUMBER,
   client_id NUMBER,
   driver_id NUMBER,
   info NVARCHAR2(300),
   datetime DATE,
   cost FLOAT,
   status NUMBER,
   destination NVARCHAR2(100),
   arrival NVARCHAR2(100),
   CONSTRUCTOR FUNCTION OrderTy RETURN SELF AS RESULT,
   ORDER MEMBER FUNCTION compare(o IN OrderType) RETURN NUMBER,
   MEMBER FUNCTION getInfo RETURN NVARCHAR2 DETERMINISTIC
);


CREATE OR REPLACE TYPE BODY OrderTy AS
   CONSTRUCTOR FUNCTION OrderTy RETURN SELF AS RESULT IS
   BEGIN
       SELF.id := NULL;
       SELF.client_id := NULL;
       SELF.driver_id := NULL;
       SELF.info := NULL;
       SELF.datetime := NULL;
       SELF.cost := NULL;
       SELF.status := NULL;
       SELF.destination := NULL;
       SELF.arrival := NULL;
       RETURN;
   END;

   ORDER MEMBER FUNCTION compare(o IN OrderTy) RETURN NUMBER IS
   BEGIN
       IF SELF.id < o.id THEN
           RETURN -1;
       ELSIF SELF.id > o.id THEN
           RETURN 1;
       ELSE
           RETURN 0;
       END IF;
   END;

   MEMBER FUNCTION getInfo RETURN NVARCHAR2 DETERMINISTIC IS
   BEGIN
       RETURN 'Order ID: ' || TO_CHAR(SELF.id) || ', Client ID: ' || TO_CHAR(SELF.client_id) || ', Driver ID: ' || TO_CHAR(SELF.driver_id);
   END;
END;
/

CREATE OR REPLACE TYPE DriverTy AS OBJECT (
 id NUMBER,
 name NVARCHAR2(40),
 surname NVARCHAR2(40),
 license INT,
 phone_number VARCHAR2(20),
 email NVARCHAR2(50),
 CONSTRUCTOR FUNCTION DriverTy RETURN SELF AS RESULT,
 MAP MEMBER FUNCTION map RETURN NUMBER,
 MEMBER PROCEDURE getInfo,
 MEMBER FUNCTION getName RETURN NVARCHAR2 DETERMINISTIC
);
/



CREATE OR REPLACE TYPE BODY DriverTy AS
 CONSTRUCTOR FUNCTION DriverTy RETURN SELF AS RESULT IS
 BEGIN
    SELF.id := NULL;
    SELF.name := NULL;
    SELF.surname := NULL;
    SELF.license := NULL;
    SELF.phone_number := NULL;
    SELF.email := NULL;
    RETURN;
 END;

 MAP MEMBER FUNCTION map RETURN NUMBER IS
 BEGIN
    RETURN SELF.id;
 END;

 MEMBER PROCEDURE getInfo IS
 BEGIN
    DBMS_OUTPUT.PUT_LINE( 'Driver ID: ' || TO_CHAR(SELF.id) || ', Name: ' || SELF.name || ', License: ' || TO_CHAR(SELF.license));
 END;

 MEMBER FUNCTION getName
 RETURN NVARCHAR2 DETERMINISTIC IS
 BEGIN
     RETURN SELF.NAME;
 END;
END;
/

CREATE OR REPLACE VIEW order_view AS
SELECT ID,
       CLIENT_ID,
       DRIVER_ID,
       STATUS,
       COST,
       INFO,
       DATETIME,
       DESTINATION,
       ARRIVAL
FROM "ORDER";

SELECT * FROM order_view;

CREATE OR REPLACE VIEW driver_view AS
SELECT ID,
       NAME,
       LICENSE,
       EMAIL,
       SURNAME,
       PHONE_NUMBER
FROM DRIVER;

select * from driver_view;


CREATE TABLE ORDER_OBJ_TABLE (
    order_obj ORDERTYPE
);

DROP TABLE DRIVER_OBJ_TABLE;

CREATE TABLE DRIVER_OBJ_TABLE (
    driver_obj DRIVERTYPE
);

-- Исправленные запросы для создания представлений
CREATE OR REPLACE VIEW order_view AS
SELECT ORDERTYPE(
               id => "ID",
                client_id => "CLIENT_ID",
                driver_id => "DRIVER_ID",
                STATUS => "STATUS",
                cost => "COST",
                info => "INFO",
       DATETIME => "DATETIME",
       destination => "DESTINATION",
       arrival => "ARRIVAL"
           ) AS order_obj
FROM "ORDER";

CREATE OR REPLACE VIEW driver_view AS
SELECT DriverType(
               id => "ID",
       name => "NAME",
       license => "LICENSE",
       email => "EMAIL",
       surname => "SURNAME",
       PHONE_NUMBER => "PHONE_NUMBER"
           ) AS driver_obj
FROM DRIVER;

-- Исправленные запросы для вставки данных в объектные таблицы
INSERT INTO ORDER_OBJ_TABLE (order_obj)
SELECT ORDERTYPE(
               id => ID,
                client_id => CLIENT_ID,
                driver_id => DRIVER_ID,
                STATUS => STATUS,
                cost => COST,
                info => INFO,
       DATETIME => DATETIME,
       destination => DESTINATION,
       arrival => ARRIVAL
           )
FROM "ORDER";

-- Insert data into DRIVER_OBJ_TABLE
INSERT INTO DRIVER_OBJ_TABLE (driver_obj)
SELECT DriverType(
    id => ID,
    name => NAME,
    license => LICENSE,
    email => EMAIL,
    surname => SURNAME,
    PHONE_NUMBER => PHONE_NUMBER
)
FROM DRIVER;

CREATE OR REPLACE TYPE Drive AS OBJECT (
    id NUMBER,
    name NVARCHAR2(50),
    surname NVARCHAR2(50),
    license NUMBER,
    email NVARCHAR2(100),
    phone_number NVARCHAR2(20)
);

Select * from "ORDER";
SELECT * FROM DRIVER;

DECLARE
    drr DriverType;
    str nvarchar2(256);
    BEGIN
    drr:=NEW DriverType(
  ID =>1,
 name =>'some',
 surname => 'sss',
 license =>121,
 phone_number =>121313,
 email =>'podobed@gmail.com');
    drr.GETINFO();
    select drr.getName() into str from dual;
    DBMS_OUTPUT.PUT_LINE(str);
END;


Select * from ORDER_OBJ_TABLE; 
SELECT * FROM DRIVER_OBJ_TABLE;

CREATE BITMAP INDEX order_id_idx ON ORDER_OBJ_TABLE (ORDER_OBJ.ID);

CREATE BITMAP INDEX order_getInfo_idx ON ORDER_OBJ_TABLE ((ORDER_OBJ.GETINFO()));
CREATE BITMAP INDEX order_getInfo_idx ON ORDER_OBJ_TABLE ((ORDER_OBJ.GETINFO()));

CREATE INDEX DRIVER_id_idx ON DRIVER_OBJ_TABLE (DRIVER_OBJ.ID); 
CREATE BITMAP INDEX DRIVER_getInfo_idx ON DRIVER_OBJ_TABLE ((DRIVER_OBJ.GETNAME()));


DROP INDEX order_id_idx;
DROP INDEX order_getInfo_idx;
DROP INDEX DRIVER_id_idx;
DROP INDEX DRIVER_getInfo_idx;

CREATE INDEX order_id_idx ON ORDER_OBJ_TABLE (ORDER_OBJ.ID);
CREATE BITMAP INDEX DRIVER_id_idx ON DRIVER_OBJ_TABLE (DRIVER_OBJ.ID);

CREATE BITMAP INDEX order_getInfo_idx ON ORDER_OBJ_TABLE(ORDER_OBJ.GETINFO());
CREATE BITMAP INDEX DRIVER_getInfo_idx ON DRIVER_OBJ_TABLE (DRIVER_OBJ.GETNAME());


-- Исправленные запросы для создания представлений
CREATE OR REPLACE VIEW order_view AS
SELECT ORDERTYPE(
               id => "ID",
                client_id => "CLIENT_ID",
                driver_id => "DRIVER_ID",
                STATUS => "STATUS",
                cost => "COST",
                info => "INFO",
       DATETIME => "DATETIME",
       destination => "DESTINATION",
       arrival => "ARRIVAL"
           ) AS order_obj
FROM "ORDER";

CREATE OR REPLACE VIEW driver_view AS
SELECT DriverType(
               id => "ID",
       name => "NAME",
       license => "LICENSE",
       email => "EMAIL",
       surname => "SURNAME",
       PHONE_NUMBER => "PHONE_NUMBER"
           ) AS driver_obj
FROM DRIVER;

select * from driver_view;

-- Исправленные запросы для вставки данных в объектные таблицы
INSERT INTO ORDER_OBJ_TABLE (order_obj)
SELECT ORDERTYPE(
               id => ID,
                client_id => CLIENT_ID,
                driver_id => DRIVER_ID,
                STATUS => STATUS,
                cost => COST,
                info => INFO,
       DATETIME => DATETIME,
       destination => DESTINATION,
       arrival => ARRIVAL
           )
FROM "ORDER";



INSERT INTO DRIVER_OBJ_TABLE (driver_obj)
SELECT DriverType(
               id => ID,
       name => NAME,
       license => LICENSE,
       email => EMAIL,
       surname => SURNAME,
       PHONE_NUMBER => PHONE_NUMBER
           )
FROM DRIVER;

