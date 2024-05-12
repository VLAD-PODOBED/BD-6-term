-- 1. Создаем отдельное табличное пространство для хранения LOB.
CREATE TABLESPACE lob_ts
DATAFILE 'lob_ts.dat'
SIZE 100M
AUTOEXTEND ON
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;

-- 2. Создаем отдельную папку для хранения внешних WORD (или PDF) документов.
CREATE DIRECTORY lob_directory AS 'D:/Проектирование бд/LABA10';
CREATE DIRECTORY photo_directory AS 'D:/Проектирование бд/LABA10/photos';

-- 3. Создаем пользователя lob_user с необходимыми привилегиями для вставки, обновления и удаления больших объектов.

ALTER SESSION SET "_oracle_script" = TRUE;
GRANT READ ON DIRECTORY lob_directory TO SYS;
GRANT READ ON DIRECTORY photo_directory TO SYS;

create user lob_user IDENTIFIED by 1234;
GRANT UNLIMITED TABLESPACE TO lob_user;

GRANT CREATE SESSION, CREATE TABLE TO lob_user;
GRANT RESOURCE TO lob_user;
GRANT CONNECT TO lob_user;
GRANT UPDATE ON "ORDER" TO lob_user;

-- 4. Добавляем квоту на данное табличное пространство пользователю lob_user.
ALTER USER lob_user QUOTA 50M ON lob_ts;

select * from "ORDER";

ALTER TABLE "ORDER" ADD (
    FOTO BLOB,
    DOC BFILE
);


INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, COST, STATUS, DESTINATION, ARRIVAL, FOTO, DOC)
VALUES (1, 1, 'Additional info for order 1', 150.0, 2, '789 Maple Ln', '123 Oak St', EMPTY_BLOB(), BFILENAME('LOB_DIRECTORY', 'document1.pdf'));

INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, COST, STATUS, DESTINATION, ARRIVAL, FOTO, DOC)
VALUES (2, 2, 'Additional info for order 2', 200.0, 1, '456 Elm St', '789 Pine Ave', EMPTY_BLOB(), BFILENAME('LOB_DIRECTORY', 'document2.pdf'));

INSERT INTO "ORDER" (CLIENT_ID, DRIVER_ID, INFO, COST, STATUS, DESTINATION, ARRIVAL, FOTO, DOC)
VALUES (3, 1, 'Some additional information', 100.0, 1, '123 Park Ave', '456 Elm St', EMPTY_BLOB(), BFILENAME('LOB_DIRECTORY', 'document3.pdf'));

COMMIT;

CREATE OR REPLACE PROCEDURE update_order(
    p_client_id IN NUMBER,
    p_driver_id IN NUMBER,
    p_info IN VARCHAR2,
    p_cost IN NUMBER,
    p_status IN NUMBER,
    p_destination IN VARCHAR2,
    p_arrival IN VARCHAR2,
    p_foto_blob IN BLOB,
    p_doc_bfile IN BFILE
)
IS
BEGIN
    UPDATE "ORDER"
    SET INFO = p_info,
        COST = p_cost,
        STATUS = p_status,
        DESTINATION = p_destination,
        ARRIVAL = p_arrival,
        FOTO = p_foto_blob,
        DOC = p_doc_bfile
    WHERE CLIENT_ID = p_client_id
    AND DRIVER_ID = p_driver_id;

    COMMIT;
END;

BEGIN
    update_order(
        p_client_id => 1,
        p_driver_id => 1,
        p_info => 'Updated info for order 1',
        p_cost => 200,
        p_status => 1,
        p_destination => 'Updated destination',
        p_arrival => 'Updated arrival',
        p_foto_blob => EMPTY_BLOB(),
        p_doc_bfile => BFILENAME('LOB_DIRECTORY', 'document2.pdf')
    );
END;

CREATE OR REPLACE PROCEDURE delete_or(
    p_client_id IN NUMBER
)
IS
BEGIN
    DELETE FROM "ORDER"
    WHERE CLIENT_ID = p_client_id;

    COMMIT;
END;

BEGIN
    delete_or(p_client_id => 1);
END;

ALTER TABLE "ORDER" DISABLE CONSTRAINT FK_ORDER_CLIENT_ID;
ALTER TABLE REVIEW DISABLE CONSTRAINT FK_REVIEW_ORDER_ID;

-- Включить обратно ограничение FK_ORDER_CLIENT_ID
ALTER TABLE "ORDER" ENABLE CONSTRAINT FK_ORDER_CLIENT_ID;
ALTER TABLE REVIEW ENABLE CONSTRAINT FK_REVIEW_ORDER_ID;

