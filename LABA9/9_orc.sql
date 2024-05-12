DECLARE
    TYPE t1_type IS TABLE OF ORDER_OBJ_TABLE%ROWTYPE;
    TYPE t2_type IS TABLE OF DRIVER_OBJ_TABLE%ROWTYPE;
    TYPE K1_type IS TABLE OF t1_type;
    TYPE K2_type IS TABLE OF t2_type;

    K11 K1_type;
    K22 K2_type;
    
    K1 t1_type;
    K2 t2_type;
BEGIN

    SELECT * BULK COLLECT INTO K1 FROM ORDER_OBJ_TABLE;
    SELECT * BULK COLLECT INTO K2 FROM DRIVER_OBJ_TABLE;

    -- Пример обращения к элементам коллекции K1 и K2
    IF K1.EXISTS(1) THEN
        DBMS_OUTPUT.PUT_LINE('Element exists in K1');
    END IF;

    IF K2.EXISTS(1) THEN
        DBMS_OUTPUT.PUT_LINE('Element exists in K2');
    END IF;
END;
--
DECLARE
    TYPE t1_type IS TABLE OF "ORDER"%ROWTYPE;
    K1 t1_type;
    element_exists BOOLEAN;
BEGIN
    -- Заполняем K1 коллекцией t1
    SELECT * BULK COLLECT INTO K1 FROM "ORDER";

    -- Проверяем, существует ли элемент с индексом 2 в коллекции K1
    element_exists := K1.EXISTS(200);

    IF element_exists THEN
        DBMS_OUTPUT.PUT_LINE('Element exists in K1');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Element does not exist in K1');
    END IF;
END;
--
DECLARE
    TYPE t1_type IS TABLE OF "ORDER"%ROWTYPE;
    K1 t1_type;
BEGIN
    -- Заполняем K1 коллекцией t1
    SELECT * BULK COLLECT INTO K1 FROM "ORDER";

    -- Проверяем, пуста ли коллекция K1
    IF K1.COUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('K1 collection is empty');
    ELSE
        DBMS_OUTPUT.PUT_LINE('K1 collection is not empty');
    END IF;
END;
--
DECLARE
    TYPE t1_type IS TABLE OF "ORDER"%ROWTYPE;
    TYPE t2_type IS TABLE OF "ORDER"%ROWTYPE;
    TYPE t3_type IS TABLE OF DRIVER%ROWTYPE;
    K1 t1_type;
    K2 t2_type;
    K3 t3_type;
BEGIN
    -- Заполняем K1 и K2 коллекциями t1
    SELECT * BULK COLLECT INTO K1 FROM "ORDER";
    SELECT * BULK COLLECT INTO K2 FROM "ORDER";
    SELECT * BULK COLLECT INTO K3 FROM DRIVER; 

    FOR i IN 1 .. K1.COUNT LOOP
        K2(i) := K1(i);
        DBMS_OUTPUT.PUT_LINE(
            'K1(' || i || '): ' || 
            'CLIENT_ID: ' || K1(i).CLIENT_ID || ', ' ||
            'DRIVER_ID: ' || K1(i).DRIVER_ID || ', ' ||
            'INFO: ' || K1(i).INFO || ', ' ||
            'COST: ' || K1(i).COST || ', ' ||
            'STATUS: ' || K1(i).STATUS || ', ' ||
            'DESTINATION: ' || K1(i).DESTINATION || ', ' ||
            'ARRIVAL: ' || K1(i).ARRIVAL
        );
    END LOOP;
    
   FOR j IN 1 .. K3.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(
            'K3(' || j || '): ' || 
            'NAME: ' || K3(j).NAME || ', ' ||
            'SURNAME: ' || K3(j).SURNAME || ', ' ||
            'LICENSE: ' || K3(j).LICENSE || ', ' ||
            'PHONE_NUMBER: ' || K3(j).PHONE_NUMBER || ', ' ||
            'EMAIL: ' || K3(j).EMAIL || ', ' ||
            'MANAGER_ID: ' || K3(j).MANAGER_ID
        ); 
    END LOOP;
END;

select * from "ORDER";
select * from DRIVER;


