SELECT * FROM driver;

-- Запрос для отображения всех подчиненных узлов с указанием уровня иерархии
SELECT LEVEL, ID, NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL
FROM DRIVER
START WITH ID = 1
CONNECT BY PRIOR ID = MANAGER_ID;

-- Создать процедуру для отображения всех подчиненных узлов с указанием уровня иерархии
CREATE OR REPLACE PROCEDURE GetSubordinates
    (nodeValue IN NUMBER)
AS
BEGIN
    FOR rec IN (
      SELECT LEVEL, ID, NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL
      FROM DRIVER
      START WITH ID = nodeValue
      CONNECT BY PRIOR ID = MANAGER_ID
    ) LOOP
      DBMS_OUTPUT.PUT_LINE('LEVEL: ' || rec.LEVEL || ', ID: ' || rec.ID || ', NAME: ' || rec.NAME ||
                           ', SURNAME: ' || rec.SURNAME || ', LICENSE: ' || rec.LICENSE ||
                           ', PHONE_NUMBER: ' || rec.PHONE_NUMBER || ', EMAIL: ' || rec.EMAIL);
    END LOOP;
END;

SET SERVEROUTPUT ON;
EXECUTE GetSubordinates(1);

CREATE OR REPLACE PROCEDURE ADD_CHILD_NODE(
    p_parent_node_id  IN DRIVER.ID%TYPE,
    p_name            IN DRIVER.NAME%TYPE,
    p_surname         IN DRIVER.SURNAME%TYPE,
    p_license         IN DRIVER.LICENSE%TYPE,
    p_phone_number    IN DRIVER.PHONE_NUMBER%TYPE,
    p_email           IN DRIVER.EMAIL%TYPE
)
IS
BEGIN
    INSERT INTO DRIVER (
        NAME,
        SURNAME,
        LICENSE,
        PHONE_NUMBER,
        EMAIL,
        MANAGER_ID
    ) VALUES (
        p_name,
        p_surname,
        p_license,
        p_phone_number,
        p_email,
        p_parent_node_id
    );

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Child node added successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error adding child node: ' || SQLERRM);
        ROLLBACK;
END;

BEGIN
    ADD_CHILD_NODE(2`, 'Oleg', 'PODOBED', 123456, '555-1234', 'johndoe@example.com');
END;


CREATE OR REPLACE PROCEDURE MOVE_CHILD_NODES(
    p_old_parent_node_id IN DRIVER.ID%TYPE,
    p_new_parent_node_id IN DRIVER.ID%TYPE
)
IS
BEGIN
    UPDATE DRIVER SET
        MANAGER_ID = p_new_parent_node_id
    WHERE
        MANAGER_ID = p_old_parent_node_id;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Child nodes moved successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error moving child nodes: ' || SQLERRM);
        ROLLBACK;
END;

BEGIN
    MOVE_CHILD_NODES(2, 3);
END;

SELECT
    ID,
    NAME,
    SURNAME,
    MANAGER_ID
FROM
    DRIVER;


