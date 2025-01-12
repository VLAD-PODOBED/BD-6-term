CREATE DATABASE TRANSPORTATION;

CREATE LOGIN TRANS_LOGIN WITH PASSWORD =N'1122Aa11';

CREATE USER TRANS_USER FOR LOGIN TRANS_LOGIN;

USE TRANSPORTATION
ALTER ROLE db_owner ADD MEMBER TRANS_USER;


CREATE TABLE BRAND
(
    ID         INT IDENTITY(1,1) NOT NULL,
    BRAND_NAME NVARCHAR(40) NOT NULL,

    CONSTRAINT PK_BRAND_ID PRIMARY KEY (ID)
);
GO

CREATE TABLE COLOR
(
    ID         INT IDENTITY(1,1) NOT NULL,
    COLOR_NAME NVARCHAR(20) NOT NULL,

    CONSTRAINT PK_COLOR_ID PRIMARY KEY (ID)
);
GO

CREATE TABLE CAR
(
    REGISTRATION_NUM INT IDENTITY(1,1) NOT NULL,
    BRAND_ID         INT,
    MODEL            VARCHAR(20) NOT NULL,
    YEAR             DATE NOT NULL,
    COLOR_ID         INT,
	CAPACITY         INT,

    CONSTRAINT PK_REGISTRATION_NUM PRIMARY KEY (REGISTRATION_NUM),
    CONSTRAINT FK_CAR_BRAND_ID FOREIGN KEY (BRAND_ID)
        REFERENCES BRAND (ID) ON DELETE SET NULL,
    CONSTRAINT FK_CAR_COLOR_ID FOREIGN KEY (COLOR_ID)
        REFERENCES COLOR (ID) ON DELETE SET NULL
);
GO

CREATE TABLE DRIVER
(
    ID           INT IDENTITY(1,1) NOT NULL,
    NAME         NVARCHAR(40) NOT NULL,
    SURNAME      NVARCHAR(40),
    LICENSE      INT NOT NULL,
    PHONE_NUMBER VARCHAR(20) NOT NULL,
    EMAIL        NVARCHAR(50) NOT NULL,
	MANAGER_HIERARCHY HIERARCHYID NOT NULL,

    CONSTRAINT PK_DRIVER_ID PRIMARY KEY (ID)
);
GO

-- DROP TABLE DRIVER;

CREATE TABLE DRIVER_CAR
(
    DRIVER_ID INT NOT NULL,
    CAR_ID    INT NOT NULL,
    DATE DATETIME2 NOT NULL DEFAULT sysdatetime()

    CONSTRAINT FK_DRIVER_CAR_DRIVER_ID FOREIGN KEY (DRIVER_ID)
        REFERENCES DRIVER (ID) ON DELETE CASCADE,
    CONSTRAINT FK_DRIVER_CAR_CAR_ID FOREIGN KEY (CAR_ID)
        REFERENCES CAR (REGISTRATION_NUM) ON DELETE CASCADE
);
GO

CREATE TABLE CLIENT
(
    ID           INT IDENTITY(1,1) NOT NULL,
    NAME         NVARCHAR(40) NOT NULL,
    SURNAME      NVARCHAR(40) NOT NULL,
    ADDRESS      NVARCHAR(100) NOT NULL,
    PHONE_NUMBER VARCHAR(20),
    EMAIL        NVARCHAR(50),

    CONSTRAINT PK_CLIENT_ID PRIMARY KEY (ID),
    CONSTRAINT CK_CLIENT_CONTACT_NOT_NULL
        CHECK (PHONE_NUMBER IS NOT NULL OR EMAIL IS NOT NULL)
);
GO


        CREATE TABLE [ORDER]
        (
            ID          INT IDENTITY (1,1) NOT NULL,
            CLIENT_ID   INT,
            DRIVER_ID   INT,
            INFO        NVARCHAR(300),
            DATETIME    DATETIME DEFAULT GETDATE(),
            COST        FLOAT              NOT NULL,
            DESTINATION NVARCHAR(100)      NOT NULL,
            ARRIVAL     NVARCHAR(100)      NOT NULL,

            CONSTRAINT FK_ORDER_CLIENT_ID FOREIGN KEY (CLIENT_ID)
                REFERENCES CLIENT (ID) ON DELETE SET NULL,
            CONSTRAINT FK_ORDER_DRIVER_ID FOREIGN KEY (DRIVER_ID)
                REFERENCES DRIVER (ID) ON DELETE SET NULL,
            CONSTRAINT PK_ORDER_ID PRIMARY KEY (ID)
        );
        GO

CREATE TABLE REVIEW
(
    ORDER_ID INT NOT NULL,
    TEXT     NVARCHAR(500) NOT NULL,
    STARS    INT NOT NULL,

    CONSTRAINT FK_REVIEW_ORDER_ID FOREIGN KEY (ORDER_ID)
        REFERENCES [ORDER] (ID),
    CONSTRAINT PK_REVIEW_ORDER_ID PRIMARY KEY (ORDER_ID),
    CONSTRAINT CK_REVIEW_STARS_RANGE CHECK (STARS > 0 AND STARS <= 10)
) ;
GO

drop table BRAND;
drop table COLOR;
drop table CAR;
drop table DRIVER;
drop table DRIVER_CAR;
drop table CLIENT;
drop table [ORDER];
drop table REVIEW;

SELECT COUNT(*) AS TotalTables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'TRANSPORTATION';
