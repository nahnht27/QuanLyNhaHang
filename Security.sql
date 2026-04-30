CREATE LOGIN login_name WITH PASSWORD = 'password@123'

-- Tạo login ở cấp SQL server 
CREATE LOGIN ManagerLogin WITH PASSWORD = 'Manager@123';
CREATE LOGIN CashierLogin WITH PASSWORD = 'Cashier@123';
CREATE LOGIN WaiterLogin WITH PASSWORD = 'Waiter@123';
GO

-- Chuyển sang database QuanLyNhaHang 
USE QuanLyNhaHang;
GO

-- Tạo user từ login tương ứng
CREATE USER user_manager FOR LOGIN ManagerLogin;
CREATE USER user_cashier FOR LOGIN CashierLogin;
CREATE USER user_waiter FOR LOGIN WaiterLogin;
GO

-- PHÂN QUYỀN
-- Manager 
-- Toàn quyền trên các bảng
GRANT SELECT, INSERT, UPDATE, DELETE ON Category           TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON MenuItem           TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Table]            TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customer           TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff              TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Account            TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservation        TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Invoice            TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON InvoiceDetail      TO user_manager;
-- Toàn quyền thực thi Stored Procedure
GRANT EXECUTE ON sp_AddInvoice          TO user_manager;
GRANT EXECUTE ON sp_AddInvoiceDetail    TO user_manager;
GRANT EXECUTE ON sp_PayInvoice          TO user_manager;
GRANT EXECUTE ON sp_GetRevenueByDate    TO user_manager;
GRANT EXECUTE ON sp_GetRevenueByMonth   TO user_manager;
GRANT EXECUTE ON sp_GetBestSellingItems TO user_manager;
-- Quyền xem View
GRANT SELECT ON vw_TableStatus          TO user_manager;
GRANT SELECT ON vw_BestSellingItems     TO user_manager;
GO


--Cashier
-- Xem thực đơn và bàn để phục vụ tra cứu
GRANT SELECT ON Category						TO user_cashier;
GRANT SELECT ON MenuItem						TO user_cashier;
GRANT SELECT ON [Table]							TO user_cashier;
-- Thao tác hóa đơn
GRANT SELECT, INSERT, UPDATE ON Invoice         TO user_cashier;
GRANT SELECT, INSERT, UPDATE ON InvoiceDetail   TO user_cashier;
-- Thực thi SP liên quan đến nghiệp vụ thu ngân
GRANT EXECUTE ON sp_PayInvoice                  TO user_cashier;
GRANT EXECUTE ON sp_GetRevenueByDate			TO user_cashier;
GRANT EXECUTE ON sp_GetRevenueByMonth			TO user_cashier;
GRANT EXECUTE ON sp_GetBestSellingItems			TO user_cashier;
-- Xem View báo cáo
GRANT SELECT ON vw_TableStatus					TO user_cashier;
GRANT SELECT ON vw_BestSellingItems				TO user_cashier;
-- Từ chối quyền xóa trên toàn bộ bảng
DENY DELETE ON Invoice							TO user_cashier;
DENY DELETE ON InvoiceDetail					TO user_cashier;
DENY DELETE ON MenuItem							TO user_cashier;
DENY DELETE ON [Table]							TO user_cashier;
GO


--Waiter
-- Xem thực đơn và trạng thái bàn
GRANT SELECT ON Category						TO user_waiter;
GRANT SELECT ON MenuItem						TO user_waiter;
GRANT SELECT ON [Table]							TO user_waiter;
-- Xem và thêm chi tiết hóa đơn
GRANT SELECT ON Invoice							TO user_waiter;
GRANT SELECT, INSERT ON InvoiceDetail			TO user_waiter;
GRANT SELECT ON Customer						TO user_waiter;
-- Thực thi SP ghi nhận order
GRANT EXECUTE ON sp_AddInvoice					TO user_waiter;
GRANT EXECUTE ON sp_AddInvoiceDetail			TO user_waiter;
-- Xem trạng thái bàn
GRANT SELECT ON vw_TableStatus					TO user_waiter;
GRANT SELECT ON Reservation						TO user_waiter;
-- Từ chối các thao tác nhạy cảm
DENY INSERT, UPDATE, DELETE ON Invoice			TO user_waiter;
DENY UPDATE, DELETE ON InvoiceDetail            TO user_waiter;
DENY SELECT, INSERT, UPDATE, DELETE ON Staff    TO user_waiter;
DENY SELECT, INSERT, UPDATE, DELETE ON Account	TO user_waiter;
DENY INSERT, UPDATE, DELETE ON [Table]			TO user_waiter;
GO


-- xóa bảng
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'login_name')
    DROP LOGIN login_name;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_manager')
    DROP USER user_manager;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_cashier')
    DROP USER user_cashier;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_waiter')
    DROP USER user_waiter;
GO

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'ManagerLogin')
    DROP LOGIN ManagerLogin;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'CashierLogin')
    DROP LOGIN CashierLogin;
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'WaiterLogin')
    DROP LOGIN WaiterLogin;
GO

--Manager
-- Kiểm tra SELECT, INSERT, UPDATE, DELETE trên bảng Invoice
SELECT * FROM Invoice;
INSERT INTO Invoice (TotalAmount, Status, PaymentMethod, TableID, StaffID) VALUES (0, 'Unpaid', NULL, 1, 1);
UPDATE Invoice SET TotalAmount = 50000 WHERE InvoiceID = 6;
DELETE FROM Invoice WHERE InvoiceID = 5;

-- Kiểm tra thực thi stored procedure
EXEC sp_GetBestSellingItems;

-- Kiểm tra xem View
SELECT * FROM vw_TableStatus;

--Cashier
-- Được phép xem thực đơn và bàn
SELECT * FROM MenuItem;
SELECT * FROM [Table];

-- Được phép thêm và cập nhật hóa đơn
INSERT INTO Invoice (TotalAmount, Status, PaymentMethod, TableID, StaffID) VALUES (0, 'Unpaid', NULL, 2, 2);
UPDATE Invoice SET TotalAmount = 120000 WHERE InvoiceID = 2;

-- Được phép thực thi stored procedure thanh toán và báo cáo
EXEC sp_PayInvoice @InvoiceID = 2, @PaymentMethod = 'Cash';
EXEC sp_GetRevenueByDate @Date = '2026-04-27';

-- Bị từ chối xóa hóa đơn
DELETE FROM Invoice WHERE InvoiceID = 2;

--Waiter
USE QuanLyNhaHang;
EXECUTE AS USER = 'user_waiter';
GO
-- Được phép xem thực đơn, bàn, khách hàng, đặt bàn
SELECT * FROM MenuItem;
SELECT * FROM [Table];
SELECT * FROM Customer;
SELECT * FROM Reservation;

-- Được phép thêm món vào chi tiết hóa đơn (thông qua SP)
EXEC sp_AddInvoiceDetail @InvoiceID = 1, @ItemID = 13, @Quantity = 2;

-- Bị từ chối xóa chi tiết hóa đơn
DELETE FROM InvoiceDetail WHERE InvoiceDetailID = 1;

-- Bị từ chối xem bảng Staff và Account
SELECT * FROM Staff;   -- Lỗi
SELECT * FROM Account; -- Lỗi

-- Bị từ chối cập nhật trạng thái bàn
UPDATE [Table] SET Status = 'Occupied' WHERE TableID = 1;

