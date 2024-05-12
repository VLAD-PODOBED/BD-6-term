CREATE TABLE Report (
    id INT PRIMARY KEY IDENTITY,
    xml_data XML
);

select * from Report;

drop table Report;

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName NVARCHAR(100)
);

-- Заполним таблицу Customers
INSERT INTO Customers (CustomerID, CustomerName) VALUES (1, 'Customer 1');
INSERT INTO Customers (CustomerID, CustomerName) VALUES (2, 'Customer 2');
INSERT INTO Customers (CustomerID, CustomerName) VALUES (3, 'Customer 3');

CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE
);

-- Заполним таблицу Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (101, 1, '2024-05-01');
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (102, 2, '2024-05-02');
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (103, 3, '2024-05-03');

CREATE TABLE OrderDetails
(
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2)
);

-- Заполним таблицу OrderDetails
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (201, 101, 1, 5, 10.00);
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (202, 101, 2, 3, 15.00);
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (203, 102, 3, 2, 20.00);
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (204, 103, 4, 4, 25.00);

CREATE PROCEDURE GenerateXML
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @xml XML;

    -- Запрос для формирования XML
    SET @xml = (
        SELECT
            (
                SELECT
                    CustomerID AS 'Customer/@ID',
                    CustomerName AS 'Customer/Name',
                    (
                        SELECT
                            OrderID AS 'Order/@ID',
                            OrderDate AS 'Order/Date',
                            (
                                SELECT
                                    ProductID AS 'Product/@ID',
                                    Quantity AS 'Product/Quantity',
                                    UnitPrice AS 'Product/UnitPrice'
                                FROM
                                    OrderDetails
                                WHERE
                                    OrderDetails.OrderID = Orders.OrderID
                                FOR XML PATH('Item'), TYPE
                            )
                        FROM
                            Orders
                        WHERE
                            Orders.CustomerID = Customers.CustomerID
                        FOR XML PATH('Order'), TYPE
                    )
                FROM
                    Customers
                FOR XML PATH('Customer'), ROOT('Customers'), TYPE
            )
    );

    -- Выводим результат
    SELECT @xml AS GeneratedXML;
END;

EXEC GenerateXML;


CREATE PROCEDURE InsertXMLIntoReport
(
    @xmlData XML
)
AS
BEGIN
    INSERT INTO Report (xml_data) VALUES (@xmlData);
END;

DECLARE @xml XML;
SET @xml = '<Customers>
  <Customer>
    <Customer ID="1">
      <Name>Customer 1</Name>
    </Customer>
    <Order>
      <Order ID="101">
        <Date>2024-05-01</Date>
      </Order>
      <Item>
        <Product ID="1">
          <Quantity>5</Quantity>
          <UnitPrice>10.00</UnitPrice>
        </Product>
      </Item>
      <Item>
        <Product ID="2">
          <Quantity>3</Quantity>
          <UnitPrice>15.00</UnitPrice>
        </Product>
      </Item>
    </Order>
  </Customer>
  <Customer>
    <Customer ID="2">
      <Name>Customer 2</Name>
    </Customer>
    <Order>
      <Order ID="102">
        <Date>2024-05-02</Date>
      </Order>
      <Item>
        <Product ID="3">
          <Quantity>2</Quantity>
          <UnitPrice>20.00</UnitPrice>
        </Product>
      </Item>
    </Order>
  </Customer>
  <Customer>
    <Customer ID="3">
      <Name>Customer 3</Name>
    </Customer>
    <Order>
      <Order ID="103">
        <Date>2024-05-03</Date>
      </Order>
      <Item>
        <Product ID="4">
          <Quantity>4</Quantity>
          <UnitPrice>25.00</UnitPrice>
        </Product>
      </Item>
    </Order>
  </Customer>
</Customers>';

EXEC InsertXMLIntoReport @xmlData = @xml;


CREATE PRIMARY XML INDEX IX_Report_xmlData ON Report(xml_data);

CREATE PROCEDURE ExtractXMLDataFromReport
(
    @attribute NVARCHAR(100)
)
AS
BEGIN
    DECLARE @xml XML;
    DECLARE @query NVARCHAR(MAX);
    DECLARE @result NVARCHAR(MAX);

    -- Получаем XML из таблицы Report
    SELECT @xml = xml_data FROM Report;

    -- Формируем запрос для извлечения значения атрибута из XML
    SET @query = '/Root/@' + @attribute;

    -- Извлекаем значение атрибута из XML
    SELECT @result = @xml.value('(sql:variable("@query"))[1]', 'NVARCHAR(MAX)');

    -- Выводим результат
    SELECT @result AS ExtractedValue;
END;

EXEC ExtractXMLDataFromReport @attribute = 'Attribute_Name';
