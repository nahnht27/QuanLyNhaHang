
USE QuanLyNhaHang;
GO
drop table if exists InvoiceDetail, Invoice, Reservation, Account, Staff, Customer, [Table], MenuItem, Category;

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
    InvoiceDetailID INT            IDENTITY(1,1) PRIMARY KEY,
    Quantity        INT            NOT NULL CHECK (Quantity > 0),
    UnitPrice       DECIMAL(10,2)  NOT NULL CHECK (UnitPrice >= 0),
    InvoiceID       INT            NOT NULL,
    ItemID          INT            NOT NULL, 
    CONSTRAINT FK_InvoiceDetail_Invoice  FOREIGN KEY (InvoiceID)
        REFERENCES Invoice(InvoiceID),
    CONSTRAINT FK_InvoiceDetail_MenuItem FOREIGN KEY (ItemID)
        REFERENCES MenuItem(ItemID)            
);
GO

SELECT * 
FROM INFORMATION_SCHEMA.TABLES

INSERT INTO Category (CategoryName, Description) VALUES
(N'Khai vị',      N'Các món ăn nhẹ trước bữa chính'),
(N'Món chính',    N'Các món ăn chính trong bữa'),
(N'Tráng miệng',  N'Các món ngọt sau bữa ăn'),
(N'Đồ uống',      N'Nước giải khát, sinh tố, bia rượu');
GO

INSERT INTO MenuItem (ItemName, Price, Description, Status, CategoryID) VALUES

(N'Gỏi cuốn tôm thịt',     45000,  N'Gỏi cuốn tươi với tôm và thịt heo', 'Available', 1),
(N'Chả giò chiên giòn',    40000,  N'Chả giò nhân thịt chiên giòn',       'Available', 1),
(N'Súp cua',               55000,  N'Súp cua thịt cua tươi',              'Available', 1),

(N'Cơm tấm sườn bì chả',   75000,  N'Cơm tấm với sườn nướng, bì, chả',   'Available', 2),
(N'Bún bò Huế',            65000,  N'Bún bò cay đặc trưng Huế',           'Available', 2),
(N'Lẩu thái hải sản',      350000, N'Lẩu thái chua cay với hải sản tươi', 'Available', 2),
(N'Bít tết bò Úc',         185000, N'Bít tết bò Úc áp chảo',              'Available', 2),
(N'Cá lóc nướng trui',     220000, N'Cá lóc nướng theo kiểu miền Tây',    'Unavailable', 2),

(N'Chè khúc bạch',         45000,  N'Chè khúc bạch thạch, hạt sen',       'Available', 3),
(N'Bánh flan caramel',     35000,  N'Bánh flan mềm mịn với caramel',      'Available', 3),

(N'Nước ngọt lon',         20000,  N'Coca, Pepsi, 7Up',                   'Available', 4),
(N'Sinh tố bơ',            45000,  N'Sinh tố bơ sữa tươi',                'Available', 4),
(N'Bia Tiger lon',         30000,  N'Bia Tiger 330ml',                    'Available', 4);
GO

INSERT INTO [Table] (TableName, Capacity, Status) VALUES
(N'Bàn 01', 2,  'Empty'),
(N'Bàn 02', 2,  'Empty'),
(N'Bàn 03', 4,  'Empty'),
(N'Bàn 04', 4,  'Occupied'),
(N'Bàn 05', 4,  'Empty'),
(N'Bàn 06', 6,  'Reserved'),
(N'Bàn 07', 6,  'Empty'),
(N'Bàn 08', 8,  'Occupied'),
(N'Bàn 09', 8,  'Empty'),
(N'Bàn 10', 10, 'Empty');
GO

INSERT INTO Customer (FullName, Phone, Email, Address) VALUES
(N'Nguyễn Văn An',    '0901234567', 'an.nguyen@gmail.com',    N'123 Lê Lợi, Q1, TP.HCM'),
(N'Trần Thị Bích',    '0912345678', 'bich.tran@gmail.com',    N'456 Nguyễn Huệ, Q1, TP.HCM'),
(N'Lê Hoàng Cường',   '0923456789', 'cuong.le@gmail.com',     N'789 Hai Bà Trưng, Q3, TP.HCM'),
(N'Phạm Thị Dung',    '0934567890', 'dung.pham@gmail.com',    N'321 Đinh Tiên Hoàng, BT, TP.HCM'),
(N'Hoàng Minh Đức',   '0945678901', 'duc.hoang@gmail.com',    N'654 Võ Văn Tần, Q3, TP.HCM'),
(N'Vũ Thị Em',        '0956789012', 'em.vu@gmail.com',        N'987 Cách Mạng Tháng 8, Q10, TP.HCM'),
(N'Đặng Văn Phú',     '0967890123', 'phu.dang@gmail.com',     N'147 Lý Tự Trọng, Q1, TP.HCM'),
(N'Bùi Thị Giang',    '0978901234', 'giang.bui@gmail.com',    N'258 Nam Kỳ Khởi Nghĩa, Q3, TP.HCM');
GO

INSERT INTO Staff (FullName, Position, Phone, Address, StartDate, Salary) VALUES
(N'Trần Quốc Bảo',    'Manager',  '0911111111', N'100 Nguyễn Trãi, Q5, TP.HCM',   '2022-01-10', 15000000),
(N'Lê Thị Cẩm',       'Cashier',  '0922222222', N'200 Trần Hưng Đạo, Q5, TP.HCM', '2022-03-15', 9000000),
(N'Phạm Văn Dũng',    'Cashier',  '0933333333', N'300 Nguyễn Thị Minh Khai, Q3',   '2023-01-20', 9000000),
(N'Nguyễn Thị Hoa',   'Waiter',   '0944444444', N'400 Đinh Bộ Lĩnh, BT, TP.HCM',  '2023-06-01', 7000000),
(N'Võ Minh Khoa',     'Waiter',   '0955555555', N'500 Xô Viết Nghệ Tĩnh, BT',      '2023-06-01', 7000000),
(N'Đỗ Thị Lan',       'Waiter',   '0966666666', N'600 Bạch Đằng, BT, TP.HCM',      '2024-01-05', 7000000);
GO

INSERT INTO Account (Username, Password, Role, StaffID, CustomerID) VALUES

('baotran',    '123456', 'Manager', 1, NULL),
('camle',      '123456', 'Cashier', 2, NULL),
('dungpham',   '123456', 'Cashier', 3, NULL),
('hoangnv',    '123456', 'Waiter',  4, NULL),
('khoavo',     '123456', 'Waiter',  5, NULL),
('lando',      '123456', 'Waiter',  6, NULL),

('annguyen',   '123456', 'Customer', NULL, 1),
('bichtran',   '123456', 'Customer', NULL, 2),
('cuongle',    '123456', 'Customer', NULL, 3);
GO

INSERT INTO Reservation (ReservationDate, GuestCount, Note, Status, CustomerID, TableID) VALUES
(N'2026-04-25 18:00:00', 4, N'Sinh nhật, cần cắm hoa',  'Confirmed', 1, 6),
(N'2026-04-25 19:00:00', 2, N'Kỷ niệm ngày cưới',       'Confirmed', 2, 1),
(N'2026-04-26 12:00:00', 6, N'Họp mặt gia đình',        'Pending',   3, 7),
(N'2026-04-26 18:30:00', 3, NULL,                        'Pending',   4, 3),
(N'2026-04-24 20:00:00', 5, N'Tiệc công ty',             'Cancelled', 5, 8);
GO


INSERT INTO Invoice (TotalAmount, Status, PaymentMethod, TableID, StaffID) VALUES
(0,       'Unpaid', NULL,       4, 4),   -- Bàn 04 đang có khách, chưa thanh toán
(0,       'Unpaid', NULL,       8, 5),   -- Bàn 08 đang có khách, chưa thanh toán
(475000,  'Paid',   'Cash',     2, 2),   -- Đã thanh toán tiền mặt
(610000,  'Paid',   'Transfer', 5, 3);   -- Đã thanh toán chuyển khoản
GO

INSERT INTO InvoiceDetail (Quantity, UnitPrice, InvoiceID, ItemID) VALUES

(2, 45000,  1, 1),
(1, 350000, 1, 6),
(4, 30000,  1, 13), 

(2, 75000,  2, 4),   
(2, 65000,  2, 5),  
(2, 45000,  2, 12),

(1, 185000, 3, 7), 
(2, 65000,  3, 5),  
(2, 45000,  3, 10),
(2, 35000,  3, 10), 

(2, 185000, 4, 7),   
(1, 55000,  4, 3),  
(2, 45000,  4, 9),  
(3, 30000,  4, 13);
GO

CREATE OR ALTER PROCEDURE sp_AddInvoice
    @TableID INT,
    @StaffID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION AddInvoice;

            IF NOT EXISTS (SELECT 1 FROM [Table] WHERE TableID = @TableID)
                THROW 50001, N'Bàn không tồn tại!', 1;

            IF EXISTS (SELECT 1 FROM [Table] WHERE TableID = @TableID AND Status <> 'Empty')
                THROW 50002, N'Bàn hiện không trống!', 1;

            IF NOT EXISTS (SELECT 1 FROM Staff WHERE StaffID = @StaffID)
                THROW 50003, N'Nhân viên không tồn tại!', 1;

            INSERT INTO Invoice (TotalAmount, Status, PaymentMethod, TableID, StaffID)
            VALUES (0, 'Unpaid', NULL, @TableID, @StaffID);

            SELECT SCOPE_IDENTITY() AS NewInvoiceID;

        COMMIT TRANSACTION AddInvoice;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION AddInvoice;
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_AddInvoiceDetail
    @InvoiceID  INT,
    @ItemID INT,
    @Quantity   INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION AddInvoiceDetail;

            IF NOT EXISTS (SELECT 1 FROM Invoice WHERE InvoiceID = @InvoiceID AND Status = 'Unpaid')
                THROW 50004, N'Hóa đơn không tồn tại hoặc đã thanh toán!', 1;

            IF NOT EXISTS (SELECT 1 FROM MenuItem WHERE ItemID = @ItemID AND Status = 'Available')
                THROW 50005, N'Món ăn không tồn tại hoặc đã hết!', 1;

            IF @Quantity <= 0
                THROW 50006, N'Số lượng phải lớn hơn 0!', 1;

            DECLARE @UnitPrice DECIMAL(10,2);
            SELECT @UnitPrice = Price FROM MenuItem WHERE ItemID = @ItemID;

            INSERT INTO InvoiceDetail (Quantity, UnitPrice, InvoiceID, ItemID)
            VALUES (@Quantity, @UnitPrice, @InvoiceID, @ItemID);

        COMMIT TRANSACTION AddInvoiceDetail;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION AddInvoiceDetail;
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_PayInvoice
    @InvoiceID     INT,
    @PaymentMethod NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION PayInvoice;

            IF NOT EXISTS (SELECT 1 FROM Invoice WHERE InvoiceID = @InvoiceID AND Status = 'Unpaid')
                THROW 50007, N'Hóa đơn không tồn tại hoặc đã thanh toán!', 1;

            IF NOT EXISTS (SELECT 1 FROM InvoiceDetail WHERE InvoiceID = @InvoiceID)
                THROW 50008, N'Hóa đơn chưa có món nào!', 1;

            IF @PaymentMethod NOT IN ('Cash', 'Transfer')
                THROW 50009, N'Phương thức thanh toán không hợp lệ!', 1;

            UPDATE Invoice
            SET Status = 'Paid',
                PaymentMethod = @PaymentMethod
            WHERE InvoiceID = @InvoiceID;

            SELECT 
                i.InvoiceID,
                i.TotalAmount,
                i.PaymentMethod,
                t.TableName
            FROM Invoice i
            JOIN [Table] t ON i.TableID = t.TableID
            WHERE i.InvoiceID = @InvoiceID;

        COMMIT TRANSACTION PayInvoice;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION PayInvoice;
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_GetRevenueByDate
    @Date DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION GetRevenueByDate;

            SELECT 
                CAST(i.CreatedAt AS DATE) AS NgayLap,
                COUNT(i.InvoiceID)        AS SoHoaDon,
                SUM(i.TotalAmount)        AS DoanhThu
            FROM Invoice i
            WHERE CAST(i.CreatedAt AS DATE) = @Date
              AND i.Status = 'Paid'
            GROUP BY CAST(i.CreatedAt AS DATE);

        COMMIT TRANSACTION GetRevenueByDate;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION GetRevenueByDate;
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_GetRevenueByMonth
    @Month INT,
    @Year  INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION GetRevenueByMonth;

            IF @Month < 1 OR @Month > 12
                THROW 50010, N'Tháng không hợp lệ!', 1;

            SELECT 
                MONTH(i.CreatedAt) AS Thang,
                YEAR(i.CreatedAt)  AS Nam,
                COUNT(i.InvoiceID) AS SoHoaDon,
                SUM(i.TotalAmount) AS DoanhThu
            FROM Invoice i
            WHERE MONTH(i.CreatedAt) = @Month
              AND YEAR(i.CreatedAt)  = @Year
              AND i.Status = 'Paid'
            GROUP BY MONTH(i.CreatedAt), YEAR(i.CreatedAt);

        COMMIT TRANSACTION GetRevenueByMonth;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION GetRevenueByMonth;
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE sp_GetBestSellingItems
    @TopN INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION GetBestSellingItems;

            IF @TopN <= 0
                THROW 50011, N'Số lượng top phải lớn hơn 0!', 1;

            SELECT TOP (@TopN)
                mi.ItemName,
                SUM(id.Quantity)                AS TongSoLuong,
                SUM(id.Quantity * id.UnitPrice) AS DoanhThu
            FROM InvoiceDetail id
            JOIN MenuItem mi ON id.ItemID = mi.ItemID
            JOIN Invoice i   ON id.InvoiceID  = i.InvoiceID
            WHERE i.Status = 'Paid'
            GROUP BY mi.ItemName
            ORDER BY TongSoLuong DESC;

        COMMIT TRANSACTION GetBestSellingItems;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION GetBestSellingItems;
        PRINT N'Error occurred: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Trigger 1: cập nhật tổng tiền và hóa đơn 

CREATE OR ALTER TRIGGER trg_UpdateTotalAmount
ON InvoiceDetail
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InvoiceID INT;

    SELECT @InvoiceID = COALESCE(i.InvoiceID, d.InvoiceID)
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.InvoiceID = d.InvoiceID;

    UPDATE Invoice
    SET TotalAmount = (
        SELECT COALESCE(SUM(Quantity * UnitPrice), 0)
        FROM InvoiceDetail
        WHERE InvoiceID = @InvoiceID
    )
    WHERE InvoiceID = @InvoiceID;
END
GO

-- Trigger 2: cập nhật trạng thái bàn

CREATE OR ALTER TRIGGER trg_UpdateTableStatus
ON Invoice
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tạo hóa đơn mới bàn chuyển sang Occupied
    UPDATE [Table]
    SET Status = 'Occupied'
    FROM [Table] t
    INNER JOIN inserted i ON t.TableID = i.TableID
    WHERE i.Status = 'Unpaid';

    -- Thanh toán xong bàn chuyển về Empty
    UPDATE [Table]
    SET Status = 'Empty'
    FROM [Table] t
    INNER JOIN inserted i ON t.TableID = i.TableID
    WHERE i.Status = 'Paid';
END;
GO

CREATE OR ALTER VIEW vw_TableStatus
AS
    SELECT
        t.TableID,
        t.TableName                 AS TenBan,
        t.Capacity                  AS SucChua,
        t.Status                    AS TrangThai,
        i.InvoiceID,
        i.TotalAmount               AS TongTienHienTai,
        i.CreatedAt                 AS ThoiGianMoBan
    FROM [Table] t
    LEFT JOIN Invoice i ON t.TableID = i.TableID
        AND i.Status = 'Unpaid';
GO

CREATE OR ALTER VIEW vw_BestSellingItems
AS
    SELECT
        mi.ItemID,
        mi.ItemName                         AS TenMon,
        c.CategoryName                      AS DanhMuc,
        SUM(id.Quantity)                    AS TongSoLuong,
        SUM(id.Quantity * id.UnitPrice)     AS DoanhThu
    FROM InvoiceDetail id
    JOIN MenuItem mi    ON id.ItemID       = mi.ItemID
    JOIN Category c     ON mi.CategoryID   = c.CategoryID
    JOIN Invoice i      ON id.InvoiceID    = i.InvoiceID
    WHERE i.Status = 'Paid'
    GROUP BY mi.ItemID, mi.ItemName, c.CategoryName;
GO

-- Cập nhật lại TotalAmount cho tất cả hóa đơn
UPDATE Invoice
SET TotalAmount = (
    SELECT COALESCE(SUM(Quantity * UnitPrice), 0)
    FROM InvoiceDetail
    WHERE InvoiceID = Invoice.InvoiceID
);

--Demo thanh toán hóa đơn 
SELECT i.InvoiceID, i.Status AS InvoiceStatus,
       i.TotalAmount, t.TableName, t.Status AS TableStatus
FROM Invoice i
JOIN [Table] t ON i.TableID = t.TableID
WHERE i.InvoiceID = 1; 

--truy vấn trạng thái bàn
SELECT * FROM vw_TableStatus
ORDER BY TableID;

SELECT 
    InvoiceID, 
    Status, 
    TotalAmount
FROM Invoice 
WHERE InvoiceID = 1;

SELECT 
    TableID, 
    TableName, 
    Status 
FROM [Table] 
WHERE TableID = 4;

EXEC sp_PayInvoice 
    @InvoiceID = 1, 
    @PaymentMethod = 'Cash';

SELECT 
    InvoiceID, 
    Status, 
    TotalAmount
FROM Invoice 
WHERE InvoiceID = 1;

SELECT 
    TableID, 
    TableName, 
    Status
FROM [Table] 
WHERE TableID = 4;


SELECT InvoiceID, Status 
FROM Invoice 
WHERE InvoiceID = 2;

SELECT TableID, Status 
FROM [Table]
WHERE TableID = 8;

BEGIN TRANSACTION;
UPDATE Invoice
SET Status = 'Paid',
    PaymentMethod = 'Cash'
WHERE InvoiceID = 2;

SELECT InvoiceID, Status
FROM Invoice
WHERE InvoiceID = 2;

SELECT TableID, Status
FROM [Table]
WHERE TableID = 8;

ROLLBACK TRANSACTION;

SELECT InvoiceID, Status
FROM Invoice
WHERE InvoiceID = 2;

SELECT TableID, Status
FROM [Table]
WHERE TableID = 8;

EXEC sp_PayInvoice 
    @InvoiceID = 99, 
    @PaymentMethod = 'Cash';

EXEC sp_PayInvoice 
    @InvoiceID = 2, 
    @PaymentMethod = 'Paypal';

