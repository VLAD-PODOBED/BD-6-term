ALTER TABLE DRIVER ADD MANAGER_HIERARCHY HIERARCHYID;

select * from DRIVER;
ALTER TABLE DRIVER DROP COLUMN TempHierachy;
-- ������� ��������� �������
ALTER TABLE DRIVER
DROP COLUMN TempHierarchy;


INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL,MANAGER_HIERARCHY) VALUES ('Michael', 'Johnson', 987654321, '555-123-4567', 'michael@example.com',hierarchyid::Parse('/'));
INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL,MANAGER_HIERARCHY) VALUES ('Emily', 'Anderson', 654321987, '555-987-6543', 'emily@example.com',hierarchyid::Parse('/1/1/'));
INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL,MANAGER_HIERARCHY) VALUES ('John', 'Doe', 123456789, '123-456-7890', 'johndoe@example.com',hierarchyid::Parse('/1/1/1/'));

-- ������� ��������� ��� ����������� ���� ����������� ����� � ��������� ������ ��������
CREATE OR ALTER PROCEDURE GetSubordinates
    @nodeValue NVARCHAR(MAX)
AS
BEGIN
    DECLARE @node hierarchyid
    SET @node = hierarchyid::Parse(@nodeValue)

    ;WITH Subordinates AS (
        SELECT ID, NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL, MANAGER_HIERARCHY,
            BRANCH = MANAGER_HIERARCHY.ToString()
        FROM DRIVER
        WHERE MANAGER_HIERARCHY.IsDescendantOf(@node) = 1
    )
    SELECT ID, NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL, BRANCH
    FROM Subordinates
    ORDER BY ID;
END;


EXEC GetSubordinates '/';

DROP PROCEDURE GetSubordinates;


-- ������� ��������� ��� ���������� ������������ ����
CREATE OR ALTER PROCEDURE AddSubordinate
    @parentNodeValue NVARCHAR(MAX)
AS
BEGIN
    DECLARE @parentNode hierarchyid
    SET @parentNode = hierarchyid::Parse(@parentNodeValue)

    DECLARE @maxHierarchyId hierarchyid
    SELECT @maxHierarchyId = MAX(MANAGER_HIERARCHY)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY = @parentNode

    INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL, MANAGER_HIERARCHY)
    VALUES ('PODOBED', 'Subordinate', 0, '', '', @maxHierarchyId.GetDescendant(NULL, NULL))
END;

DECLARE @parentNodeValue NVARCHAR(MAX) = '/1/2/'

EXEC AddSubordinate @parentNodeValue;



DROP PROCEDURE AddSubordinate;

-- ������� ��������� ��� ����������� ���� ����������� �����
CREATE OR ALTER PROCEDURE MoveSubordinates
    @currentParentNodeValue NVARCHAR(MAX),
    @newParentNodeValue NVARCHAR(MAX)
AS
BEGIN
    -- �������� ������������� ���� �������� ����
    DECLARE @currentParentNode hierarchyid
    SET @currentParentNode = hierarchyid::Parse(@currentParentNodeValue)

    -- �������� ������������� ���� ������ ����
    DECLARE @newParentNode hierarchyid
    SET @newParentNode = hierarchyid::Parse(@newParentNodeValue)

    -- �������� ������� ����������� ����
    DECLARE @moveNodeFunction hierarchyid
    SELECT @moveNodeFunction = @newParentNode.GetDescendant(MAX(MANAGER_HIERARCHY), NULL)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY.IsDescendantOf(@currentParentNode) = 1

    -- ��������� �������� MANAGER_HIERARCHY � ������� DRIVER
    UPDATE DRIVER
    SET MANAGER_HIERARCHY = CASE
                            WHEN MANAGER_HIERARCHY.IsDescendantOf(@currentParentNode) = 0
                            THEN MANAGER_HIERARCHY -- ���� �������� ���� �� ��������� � ��������� �����
                            ELSE MANAGER_HIERARCHY.GetReparentedValue(@moveNodeFunction, @newParentNode)
                            END
    WHERE MANAGER_HIERARCHY.IsDescendantOf(@currentParentNode) = 1;
END;


EXEC MoveSubordinates '/1/1/1/1/', '/1/1/1/1/'

EXEC MoveSubordinates '2', '3';

DROP PROCEDURE MoveSubordinates;

SELECT * FROM DRIVER WHERE MANAGER_HIERARCHY.IsDescendantOf('/1/1/') = 3;