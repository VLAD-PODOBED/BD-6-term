CREATE TABLE Report (
    id NUMBER PRIMARY KEY,
    xml_data XMLTYPE
);

select * from Report;

-- Создание таблицы Customers
CREATE TABLE Customers (
    CustomerID NUMBER PRIMARY KEY,
    CustomerName NVARCHAR2(100)
);

-- Заполнение таблицы Customers
INSERT INTO Customers (CustomerID, CustomerName) VALUES (1, 'Customer 1');
INSERT INTO Customers (CustomerID, CustomerName) VALUES (2, 'Customer 2');
INSERT INTO Customers (CustomerID, CustomerName) VALUES (3, 'Customer 3');

-- Создание таблицы Orders
CREATE TABLE Orders (
    OrderID NUMBER PRIMARY KEY,
    CustomerID NUMBER,
    OrderDate DATE
);

-- Заполнение таблицы Orders
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (101, 1, TO_DATE('2024-05-01', 'YYYY-MM-DD'));
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (102, 2, TO_DATE('2024-05-02', 'YYYY-MM-DD'));
INSERT INTO Orders (OrderID, CustomerID, OrderDate) VALUES (103, 3, TO_DATE('2024-05-03', 'YYYY-MM-DD'));

-- Создание таблицы OrderDetails
CREATE TABLE OrderDetails (
    OrderDetailID NUMBER PRIMARY KEY,
    OrderID NUMBER,
    ProductID NUMBER,
    Quantity NUMBER,
    UnitPrice NUMBER(10, 2)
);

-- Заполнение таблицы OrderDetails
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (201, 101, 1, 5, 10.00);
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (202, 101, 2, 3, 15.00);
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (203, 102, 3, 2, 20.00);
INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice) VALUES (204, 103, 4, 4, 25.00);

CREATE OR REPLACE PROCEDURE Generate_XML AS
    v_xml CLOB;
BEGIN
    SELECT XMLSerialize(DOCUMENT XMLElement("Report",
                XMLAgg(
                    XMLElement("Order",
                        XMLForest(
                            o.OrderID AS "OrderID",
                            c.CustomerName AS "CustomerName",
                            o.OrderDate AS "OrderDate",
                            (SELECT XMLAgg(
                                XMLElement("OrderDetail",
                                    XMLForest(
                                        od.OrderDetailID AS "OrderDetailID",
                                        od.ProductID AS "ProductID",
                                        od.Quantity AS "Quantity",
                                        od.UnitPrice AS "UnitPrice"
                                    )
                                )
                            ) FROM OrderDetails od
                            WHERE od.OrderID = o.OrderID
                            ) AS "OrderDetails"
                        )
                    )
                )
            ) AS CLOB)
    INTO v_xml
    FROM Orders o
    JOIN Customers c ON o.CustomerID = c.CustomerID;

    INSERT INTO Report (id, xml_data) VALUES (1, v_xml);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('XML generated and stored in Report table.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END Generate_XML;

exec Generate_XML;

-- Создание процедуры для вставки XML в таблицу
CREATE OR REPLACE PROCEDURE InsertXMLIntoReport(xmlData IN xml_data) AS
BEGIN
  INSERT INTO Report (xml_data) VALUES (xmlData);
  COMMIT;
END InsertXMLIntoReport;
/

-- Создание индекса XML на таблице Report
CREATE INDEX IX_Report_xmlData ON Report(xml_data);

-- Создание процедуры для извлечения данных из XML в таблице
CREATE OR REPLACE PROCEDURE ExtractXMLDataFromReport(attribute IN VARCHAR2) AS
  xml_data XMLType;
  result VARCHAR2(4000);
BEGIN
  -- Получаем XML из таблицы Report
  SELECT xml_data INTO xml_data FROM Report;

  -- Формируем запрос для извлечения значения атрибута из XML
  result := xml_data.extract('/Customers/Customer/@' || attribute).getStringVal();

  -- Выводим результат
  DBMS_OUTPUT.PUT_LINE('ExtractedValue: ' || result);
END ExtractXMLDataFromReport;
/

-- Вызов процедуры для извлечения данных из XML в таблице
EXEC ExtractXMLDataFromReport('Attribute_Name');

