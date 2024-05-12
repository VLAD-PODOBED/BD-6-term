CREATE TABLE "USER" (
  Id INT GENERATED ALWAYS AS IDENTITY,
  Name NVARCHAR2(50) NOT NULL,
   ParentUser INT,
  CONSTRAINT PK_Users PRIMARY KEY (Id),
    CONSTRAINT FK_USER FOREIGN KEY (ParentUser)
                    REFERENCES "USER"(Id)
);

DROP TABLE "USER";


SELECT * FROM "USER";

INSERT INTO "USER"(Name,ParentUser)VALUES
('Sarah Brown',NULL);

INSERT INTO "USER"(Name,ParentUser)VALUES
('Brown HS',1);
INSERT INTO "USER"(Name,ParentUser)VALUES
('Sarah DEF',1);
INSERT INTO "USER"(Name,ParentUser)VALUES
('Gare dfe',2);



    CREATE TYPE User_type AS OBJECT (
    id NUMBER,
    Name NVARCHAR2(200),
ParentUser INT,
    node_level NUMBER
);

CREATE TYPE USER_TYPE_TABLE AS TABLE OF USER_TYPE;

    CREATE OR REPLACE FUNCTION display_stage_subnodes (p_previous_user IN NUMBER)
RETURN USER_TYPE_TABLE PIPELINED IS
BEGIN
    FOR rec IN (
SELECT Id ,LPAD(' ', 3*LEVEL)||Name as NAME, ParentUser, LEVEL AS node_level
FROM "USER"
    START WITH ParentUser =p_previous_user
CONNECT BY NOCYCLE
    PRIOR id =ParentUser
ORDER SIBLINGS BY "USER".Name
    ) LOOP
        PIPE ROW(User_type(rec.id, rec.Name,rec.ParentUser, rec.node_level));
    END LOOP;
    RETURN;
END;



SELECT * FROM TABLE(display_stage_subnodes(1));

SELECT LPAD(' ', 3*LEVEL)||Name as NAME, ParentUser
FROM "USER"
    START WITH ParentUser = 1
CONNECT BY NOCYCLE
    PRIOR id =ParentUser
ORDER SIBLINGS BY "USER".Name;

SELECT *
FROM "USER";


CREATE OR REPLACE PROCEDURE add_stage_subnode (
    p_name IN VARCHAR2,
    p_parentId IN INT

) IS
BEGIN
    INSERT INTO "USER" (name, parentuser)
    VALUES (p_name,p_parentId);
END;


BEGIN
    add_stage_subnode('Djarax Bexar',1);
END;

SELECT * FROM "USER";

SELECT * FROM TABLE(display_stage_subnodes(1));



CREATE OR REPLACE PROCEDURE move_stage_subtree (
    p_old_parent IN NUMBER,
    p_new_parent IN NUMBER
) IS
BEGIN
    UPDATE "USER"
    SET PARENTUSER = p_new_parent
    WHERE PARENTUSER = p_old_parent;
END;

    BEGIN
        move_stage_subtree(1, 2);
    END;

SELECT * FROM TABLE(display_stage_subnodes(2));