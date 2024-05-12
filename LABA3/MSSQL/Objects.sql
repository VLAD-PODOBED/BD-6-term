-- ��������� ������ ������ (2 �������)

CREATE PROCEDURE dbo.GetSubNodes
    @Node hierarchyid
AS
BEGIN
    ;WITH Hierarchy AS (
        SELECT ID, NAME, MANAGER_HIERARCHY, MANAGER_HIERARCHY.GetLevel() AS Level FROM DRIVER
      WHERE MANAGER_HIERARCHY = @Node
      UNION ALL
      SELECT D.ID, D.NAME, D.MANAGER_HIERARCHY, D.MANAGER_HIERARCHY.GetLevel() AS Level
      FROM DRIVER D
      INNER JOIN Hierarchy H ON D.MANAGER_HIERARCHY.GetAncestor(1) = H.MANAGER_HIERARCHY
    )
    SELECT ID, NAME, MANAGER_HIERARCHY.ToString() AS MANAGER_HIERARCHY, Level
    FROM Hierarchy
    ORDER BY Level, ID;
END;
GO

-- ����� ������ (������ ���� ���������)
EXEC dbo.GetSubNodes '/';

--���������� �������(3 �������)

CREATE PROCEDURE dbo.AddSubNode
    @ParentNode hierarchyid,
    @UserID INT,
    @Name NVARCHAR(100),
    @Surname NVARCHAR(40),
    @License INT, -- Added license parameter
    @Phone_Number VARCHAR(20),
    @Email NVARCHAR(100)
AS
BEGIN
    DECLARE @ChildNode hierarchyid;

    -- ������� ������������ �������� ���� ��� ������� ������������� ����
    SELECT @ChildNode = MAX(MANAGER_HIERARCHY)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY.GetAncestor(1) = @ParentNode;

    -- ���� �������� ����� ���, ������� ������ �������� ����
    IF @ChildNode IS NULL
        SET @ChildNode = @ParentNode.GetDescendant(NULL, NULL);
    -- � ��������� ������ ������� ��������� �������� ����
    ELSE
        SET @ChildNode = @ParentNode.GetDescendant(@ChildNode, NULL);

    -- ��������� ������ �������� � ��������� �������� �����
    INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL, MANAGER_HIERARCHY)
    VALUES (@Name, @Surname, @License, @Phone_Number, @Email, @ChildNode);
END;
GO

DECLARE @ParentNode hierarchyid = '/'; -- ���������� �������� ������������� ����
DECLARE @UserID INT = 1;
DECLARE @Name NVARCHAR(100) = 'Podobed';
DECLARE @Surname NVARCHAR(40) = 'Doe';
DECLARE @License INT = 12345;
DECLARE @Phone_Number VARCHAR(20) = '1234567890';
DECLARE @Email NVARCHAR(100) = 'john.doe@example.com';

EXEC dbo.AddSubNode 
    @ParentNode,
    @UserID,
    @Name,
    @Surname,
    @License,
    @Phone_Number,
    @Email;


-- ������
GO
DECLARE @Node hierarchyid;
SET @Node = 0x;

EXEC ShowChildNodesWithLevel @Node;
GO

-- ����������� ����������(4 �������)
CREATE PROCEDURE dbo.MoveSubNodes
    @OldParentNode hierarchyid,
    @NewParentNode hierarchyid
AS
BEGIN
    DECLARE @MaxChild hierarchyid;

    -- ������� ������������ �������� ���� ��� ������ ������������� ����
    SELECT @MaxChild = MAX(MANAGER_HIERARCHY)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY.GetAncestor(1) = @NewParentNode;

    -- ���� �������� ����� ���, ������� ������ �������� ����
    IF @MaxChild IS NULL
        SET @MaxChild = @NewParentNode.GetDescendant(NULL, NULL);
    -- � ��������� ������ ������� ��������� �������� ����
    ELSE
        SET @MaxChild = @NewParentNode.GetDescendant(@MaxChild, NULL);

    -- ���������� ���� ����������� �� ������� ������������� ���� � ������
    UPDATE DRIVER
    SET MANAGER_HIERARCHY = MANAGER_HIERARCHY.GetReparentedValue(@OldParentNode, @MaxChild)
    WHERE MANAGER_HIERARCHY.IsDescendantOf(@OldParentNode) = 1;
END;
GO

DECLARE @OldParentNode hierarchyid = '/1/'; -- �������� ������� ������������� ����
DECLARE @NewParentNode hierarchyid = '/3/'; -- �������� ������ ������������� ����

EXEC dbo.MoveSubNodes 
    @OldParentNode,
    @NewParentNode;


