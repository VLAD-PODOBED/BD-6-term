--6.	Определите тип пространственных данных во всех таблицах.

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'

--7.	Определите SRID.
SELECT srid FROM dbo.geometry_columns

--8.	Определите атрибутивные столбцы.
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo' AND DATA_TYPE != 'geometry'
--9.	Верните описания пространственных объектов в формате WKT.
SELECT geom.STAsText() AS WKT_Description
FROM myPackage

--10.	Продемонстрируйте:
--10.1.	Нахождение пересечения пространственных объектов;
SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM myPackage obj1, myPackage obj2
WHERE obj1.qgs_fid = 10 AND obj2.qgs_fid = 10

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM myPackage obj1, myPackage obj2
WHERE obj1.qgs_fid = 23 AND obj2.qgs_fid = 23

SELECT obj1.geom.STIntersection(obj2.geom) AS Intersection
FROM myPackage obj1, myPackage obj2
WHERE obj1.qgs_fid = 23 AND obj2.qgs_fid = 12

-- 10.2.  Нахождение координат вершин пространственного объектов

SELECT geom.STPointN(1).ToString() AS Coordinates
FROM myPackage
WHERE qgs_fid = 56

-- 10.3  Нахождение площади пространственных объектов;
-- Площадь (Area): Измерение площади замкнутых объектов, таких как полигоны.
SELECT geom.STArea() AS ObjectArea
FROM myPackage
WHERE qgs_fid = 28

-- 11.  Создайте пространственный объект в виде точки (1) /линии (2) /полигона (3).
DECLARE @pointGeometry GEOMETRY;
SET @pointGeometry = GEOMETRY::STGeomFromText('POINT(10 10)', 4326);
SELECT @pointGeometry AS PointGeometry;

-- линия
DECLARE @lineGeometry GEOMETRY;
SET @lineGeometry = GEOMETRY::STGeomFromText('LINESTRING(5 5, 5 24, 29 29)', 4326);
SELECT @lineGeometry AS LineGeometry;

-- полигон
DECLARE @polygonGeometry GEOMETRY;
SET @polygonGeometry = GEOMETRY::STGeomFromText('POLYGON((5 5, 20 20, 25 15, 20 5, 5 5))', 4326);
SELECT @polygonGeometry AS PolygonGeometry;


-- 12.  Найдите, в какие пространственные объекты попадают созданные вами объекты

-- Точка
DECLARE @point GEOMETRY = GEOMETRY::STGeomFromText('POINT(10 10)', 4326);
SELECT * FROM myPackage WHERE geom.STContains(@point) = 1;

-- Линия
DECLARE @line GEOMETRY = GEOMETRY::STGeomFromText('LINESTRING(25 -15, 25 -10, 26 -10)', 4326);
SELECT * FROM myPackage WHERE geom.STContains(@line) = 1;

-- Полигон
DECLARE @polygon GEOMETRY = GEOMETRY::STGeomFromText('POLYGON((5 5, 20 20, 25 15, 20 5, 5 5))', 4326);
SELECT * FROM myPackage WHERE geom.STIntersects(@polygon) = 1;

--13.	Продемонстрируйте индексирование пространственных объектов.
CREATE SPATIAL INDEX SpatialIndex_new
ON [dbo].[geometry_columns] ([geom])
USING GEOMETRY_GRID
WITH (GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM), BOUNDING_BOX = (0, 0, 50, 50));
------------------------
DECLARE @searchPoint GEOMETRY;
SET @searchPoint = GEOMETRY::STGeomFromText('POINT(10 10)', 4326);

SELECT TOP 1 *
FROM [dbo].[geometry_columns] WITH(INDEX(SpatialIndex_new))
WHERE [geom].STIntersects(@searchPoint.STBuffer(5)) = 1;
------------------------
SELECT *
FROM [dbo].[geometry_columns]
WHERE [geom].STIntersects(geometry::STGeomFromText('POINT (10 10)', 0)) = 1;

DECLARE @searchPoint GEOMETRY;
SET @searchPoint = GEOMETRY::STGeomFromText('POINT(10 10)', 4326);

SELECT TOP 1 *
FROM [dbo].[geometry_columns] WITH(INDEX(SpatialIndex_new))
WHERE [geom].STIntersects(@searchPoint.STBuffer(5)) = 1;


SELECT name, type_desc, is_disabled
FROM sys.indexes
WHERE object_id = OBJECT_ID('dbo.geometry_columns');
-----------------------------------------------------
CREATE SPATIAL INDEX SpatialIndex_new
ON [dbo].[geometry_columns] ([geom])
USING GEOMETRY_GRID
WITH (GRIDS = (LEVEL_1 = MEDIUM, LEVEL_2 = MEDIUM, LEVEL_3 = MEDIUM, LEVEL_4 = MEDIUM), BOUNDING_BOX = (0, 0, 50, 50));

DECLARE @searchPoint GEOMETRY;
SET @searchPoint = GEOMETRY::STGeomFromText('POINT(20 20)', 4326);

SELECT TOP 1 *
FROM [dbo].[geometry_columns] WITH(INDEX(SpatialIndex_new))
WHERE [geom].STIntersects(@searchPoint.STBuffer(5)) = 1;

INSERT INTO [dbo].[geometry_columns]
VALUES
    ('QGIS_LAB2','dbo','myPackage1','geom1',2,4326,'MULTIPOLYGON',GEOMETRY::STGeomFromText('POINT(20 20)', 4326)),
    ('QGIS_LAB3','dbo','myPackage2','geom2',2,4326,'MULTIPOLYGON',GEOMETRY::STGeomFromText('POLYGON((30 30, 30 40, 40 40, 40 30, 30 30))', 4326)),
    ('QGIS_LAB4','dbo','myPackage3','geom3',2,4326,'MULTIPOLYGON',GEOMETRY::STGeomFromText('LINESTRING(10 10, 15 15, 20 20)', 4326));
	UPDATE STATISTICS [dbo].[geometry_columns] WITH FULLSCAN;

select * from [dbo].[geometry_columns];

--14.  Разработайте хранимую процедуру, которая принимает координаты точки и возвращает пространственный объект, в который эта точка попадает.
CREATE PROCEDURE FindContainingObject
    @latitude FLOAT,
    @longitude FLOAT
AS
BEGIN
    DECLARE @point GEOMETRY;
    SET @point = GEOMETRY::STPointFromText('POINT(' + CAST(@longitude AS VARCHAR(20)) + ' ' + CAST(@latitude AS VARCHAR(20)) + ')', 4326);
    
    SELECT *
    FROM myPackage
    WHERE geom.STContains(@point) = 1;
END

EXEC FindContainingObject @latitude = 10, @longitude = 10;