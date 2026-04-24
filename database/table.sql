CREATE DATABASE QuanLyNhaHang;
GO

USE QuanLyNhaHang;
GO

CREATE TABLE Category (
    CategoryID   INT           IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(255) NULL
);
GO

CREATE TABLE MenuItem (
    ItemID      INT            IDENTITY(1,1) PRIMARY KEY,
    ItemName    NVARCHAR(100)  NOT NULL,
    Price       DECIMAL(10,2)  NOT NULL CHECK (Price >= 0),
    Description NVARCHAR(255)  NULL,
    Status      NVARCHAR(20)   NOT NULL DEFAULT 'Available'
                               CHECK (Status IN ('Available', 'Unavailable')),
    CategoryID  INT            NOT NULL,
    CONSTRAINT FK_MenuItem_Category FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
);
GO

CREATE TABLE [Table] (
    TableID    INT          IDENTITY(1,1) PRIMARY KEY,
    TableName  NVARCHAR(50) NOT NULL,
    Capacity   INT          NOT NULL CHECK (Capacity > 0),
    Status     NVARCHAR(20) NOT NULL DEFAULT 'Empty'
               CHECK (Status IN ('Empty', 'Occupied', 'Reserved'))
);
GO

CREATE TABLE Customer (
    CustomerID INT           IDENTITY(1,1) PRIMARY KEY,
    FullName   NVARCHAR(100) NOT NULL,
    Phone      VARCHAR(15)   NOT NULL UNIQUE,
    Email      VARCHAR(100)  NULL,
    Address    NVARCHAR(255) NULL
);
GO

CREATE TABLE Staff (
    StaffID   INT            IDENTITY(1,1) PRIMARY KEY,
    FullName  NVARCHAR(100)  NOT NULL,
    Position  NVARCHAR(50)   NOT NULL
              CHECK (Position IN ('Manager', 'Cashier', 'Waiter')),
    Phone     VARCHAR(15)    NULL,
    Address   NVARCHAR(255)  NULL,
    StartDate DATE           NOT NULL DEFAULT GETDATE(),
    Salary    DECIMAL(10,2)  NOT NULL CHECK (Salary >= 0)
);
GO

CREATE TABLE Account (
    AccountID  INT           IDENTITY(1,1) PRIMARY KEY,
    Username   VARCHAR(50)   NOT NULL UNIQUE,
    Password   VARCHAR(255)  NOT NULL,
    Role       NVARCHAR(20)  NOT NULL DEFAULT 'Customer'
               CHECK (Role IN ('Manager', 'Cashier', 'Waiter', 'Customer')),
    StaffID    INT           NULL,
    CustomerID INT           NULL,
    CONSTRAINT FK_Account_Staff    FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID),
    CONSTRAINT FK_Account_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),
   
    CONSTRAINT CHK_Account_Owner CHECK (
        (StaffID IS NOT NULL AND CustomerID IS NULL) OR
        (StaffID IS NULL AND CustomerID IS NOT NULL)
    )
);
GO

CREATE TABLE Reservation (
    ReservationID   INT           IDENTITY(1,1) PRIMARY KEY,
    ReservationDate DATETIME      NOT NULL,
    GuestCount      INT           NOT NULL CHECK (GuestCount > 0),
    Note            NVARCHAR(255) NULL,
    Status          NVARCHAR(20)  NOT NULL DEFAULT 'Pending'
                    CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    CustomerID      INT           NOT NULL,
    TableID         INT           NOT NULL,
    CONSTRAINT FK_Reservation_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID),
    CONSTRAINT FK_Reservation_Table FOREIGN KEY (TableID)
        REFERENCES [Table](TableID)
);
GO

CREATE TABLE Invoice (
    InvoiceID     INT           IDENTITY(1,1) PRIMARY KEY,
    CreatedAt     DATETIME      NOT NULL DEFAULT GETDATE(),
    TotalAmount   DECIMAL(10,2) NOT NULL DEFAULT 0,
    Status        NVARCHAR(20)  NOT NULL DEFAULT 'Unpaid'
                  CHECK (Status IN ('Unpaid', 'Paid')),
    PaymentMethod NVARCHAR(50)  NULL
                  CHECK (PaymentMethod IN ('Cash', 'Transfer', NULL)),
    TableID       INT           NOT NULL,
    StaffID       INT           NOT NULL,
    CONSTRAINT FK_Invoice_Table FOREIGN KEY (TableID)
        REFERENCES [Table](TableID),
    CONSTRAINT FK_Invoice_Staff FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
);
GO

CREATE TABLE InvoiceDetail (
    InvoiceDetailID INT           IDENTITY(1,1) PRIMARY KEY,
    Quantity        INT           NOT NULL CHECK (Quantity > 0),
    UnitPrice       DECIMAL(10,2) NOT NULL CHECK (UnitPrice >= 0),
    InvoiceID       INT           NOT NULL,
    MenuItemID      INT           NOT NULL,
    CONSTRAINT FK_InvoiceDetail_Invoice  FOREIGN KEY (InvoiceID)
        REFERENCES Invoice(InvoiceID),
    CONSTRAINT FK_InvoiceDetail_MenuItem FOREIGN KEY (MenuItemID)
        REFERENCES MenuItem(ItemID)
);
GO