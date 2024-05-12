-- процедура вывода данных (2 задание)

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

-- вывод данных (запуск этой процедуры)
EXEC dbo.GetSubNodes '/';

--добавление вершины(3 задание)

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

    -- Ќаходим максимальный дочерний узел дл€ данного родительского узла
    SELECT @ChildNode = MAX(MANAGER_HIERARCHY)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY.GetAncestor(1) = @ParentNode;

    -- ≈сли дочерних узлов нет, создаем первый дочерний узел
    IF @ChildNode IS NULL
        SET @ChildNode = @ParentNode.GetDescendant(NULL, NULL);
    -- ¬ противном случае создаем следующий дочерний узел
    ELSE
        SET @ChildNode = @ParentNode.GetDescendant(@ChildNode, NULL);

    -- ƒобавл€ем нового водител€ с указанным дочерним узлом
    INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL, MANAGER_HIERARCHY)
    VALUES (@Name, @Surname, @License, @Phone_Number, @Email, @ChildNode);
END;
GO

DECLARE @ParentNode hierarchyid = '/'; -- ”становите значение родительского узла
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


-- ввывод
GO
DECLARE @Node hierarchyid;
SET @Node = 0x;

EXEC ShowChildNodesWithLevel @Node;
GO

-- перемещение подчинЄнных(4 задание)
CREATE PROCEDURE dbo.MoveSubNodes
    @OldParentNode hierarchyid,
    @NewParentNode hierarchyid
AS
BEGIN
    DECLARE @MaxChild hierarchyid;

    -- Ќаходим максимальный дочерний узел дл€ нового родительского узла
    SELECT @MaxChild = MAX(MANAGER_HIERARCHY)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY.GetAncestor(1) = @NewParentNode;

    -- ≈сли дочерних узлов нет, создаем первый дочерний узел
    IF @MaxChild IS NULL
        SET @MaxChild = @NewParentNode.GetDescendant(NULL, NULL);
    -- ¬ противном случае создаем следующий дочерний узел
    ELSE
        SET @MaxChild = @NewParentNode.GetDescendant(@MaxChild, NULL);

    -- ѕеремещаем всех подчиненных от старого родительского узла к новому
    UPDATE DRIVER
    SET MANAGER_HIERARCHY = MANAGER_HIERARCHY.GetReparentedValue(@OldParentNode, @MaxChild)
    WHERE MANAGER_HIERARCHY.IsDescendantOf(@OldParentNode) = 1;
END;
GO

DECLARE @OldParentNode hierarchyid = '/1/'; -- значение старого родительского узла
DECLARE @NewParentNode hierarchyid = '/3/'; -- значение нового родительского узла

EXEC dbo.MoveSubNodes 
    @OldParentNode,
    @NewParentNode;


