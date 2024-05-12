SELECT * FROM DRIVER;

CREATE PROCEDURE display_stage_subnodes (@node hierarchyid)
AS
BEGIN
    SELECT
        ID,
        NAME,
        SURNAME,
        LICENSE,
        PHONE_NUMBER,
        EMAIL,
        MANAGER_HIERARCHY.ToString() as node,
        MANAGER_HIERARCHY.GetLevel() as level
    FROM
        DRIVER
    WHERE
        MANAGER_HIERARCHY.IsDescendantOf(@node) = 1
END;
GO

DECLARE @node hierarchyid
SET @node = hierarchyid::Parse('/2/')
EXEC display_stage_subnodes @node


CREATE OR ALTER PROCEDURE add_stage_subnode (@parent_node hierarchyid, @name VARCHAR(200))
AS
BEGIN
    DECLARE @new_node hierarchyid

    -- Найдем максимальный дочерний узел по родительскому узлу
    SELECT @new_node = MAX(MANAGER_HIERARCHY)
    FROM DRIVER
    WHERE MANAGER_HIERARCHY.GetAncestor(1) = @parent_node

    -- Если нет дочерних узлов, начнем с первого дочернего узла
    IF @new_node IS NULL
        SET @new_node = @parent_node.GetDescendant(NULL, NULL)
    -- Иначе, добавим новый узел как следующего соседа
    ELSE
        SET @new_node = @parent_node.GetDescendant(@new_node, NULL)

    INSERT INTO DRIVER (NAME, SURNAME, LICENSE, PHONE_NUMBER, EMAIL, MANAGER_HIERARCHY)
    VALUES (@name, 'Geo', 654321987, '375-456-987', 'mama2003271@gmail.com', @new_node)
END;
GO

DECLARE @parent_node hierarchyid
DECLARE @name VARCHAR(200)

SET @parent_node = hierarchyid::Parse('/') -- значение родительского узла
SET @name = 'Podobed' -- имя нового узла

EXEC add_stage_subnode @parent_node, @name

CREATE OR ALTER PROCEDURE move_stage_subtree
    @old_parent hierarchyid,
    @new_parent hierarchyid
AS
BEGIN
    DECLARE @old_parent_string nvarchar(max) = @old_parent.ToString();
    DECLARE @new_parent_string nvarchar(max) = @new_parent.ToString();

    UPDATE DRIVER
    SET MANAGER_HIERARCHY = hierarchyid::Parse(
        replace(MANAGER_HIERARCHY.ToString(), @old_parent_string, @new_parent_string)
    )
    WHERE MANAGER_HIERARCHY.IsDescendantOf(@old_parent) = 1
    AND MANAGER_HIERARCHY <> @old_parent;
END;
GO
EXEC move_stage_subtree @old_parent = '/1/2/', @new_parent = '/1/2/1/';

