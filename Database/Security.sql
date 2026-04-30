CREATE LOGIN login_name WITH PASSWORD = 'password@123'

CREATE LOGIN ManagerLogin WITH PASSWORD = 'Manager@123';
CREATE LOGIN CashierLogin WITH PASSWORD = 'Cashier@123';
CREATE LOGIN WaiterLogin WITH PASSWORD = 'Waiter@123';
GO

USE QuanLyNhaHang;
GO

CREATE USER user_manager FOR LOGIN ManagerLogin;
CREATE USER user_cashier FOR LOGIN CashierLogin;
CREATE USER user_waiter FOR LOGIN WaiterLogin;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON Category           TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON MenuItem           TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Table]            TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customer           TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff              TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Account            TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservation        TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Invoice            TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON InvoiceDetail      TO user_manager;

GRANT EXECUTE ON sp_AddInvoice          TO user_manager;
GRANT EXECUTE ON sp_AddInvoiceDetail    TO user_manager;
GRANT EXECUTE ON sp_PayInvoice          TO user_manager;
GRANT EXECUTE ON sp_GetRevenueByDate    TO user_manager;
GRANT EXECUTE ON sp_GetRevenueByMonth   TO user_manager;
GRANT EXECUTE ON sp_GetBestSellingItems TO user_manager;

GRANT SELECT ON vw_TableStatus          TO user_manager;
GRANT SELECT ON vw_BestSellingItems     TO user_manager;
GO


--Cashier
GRANT SELECT ON Category						TO user_cashier;
GRANT SELECT ON MenuItem						TO user_cashier;
GRANT SELECT ON [Table]							TO user_cashier;

GRANT SELECT, INSERT, UPDATE ON Invoice         TO user_cashier;
GRANT SELECT, INSERT, UPDATE ON InvoiceDetail   TO user_cashier;

GRANT EXECUTE ON sp_PayInvoice                  TO user_cashier;
GRANT EXECUTE ON sp_GetRevenueByDate			TO user_cashier;
GRANT EXECUTE ON sp_GetRevenueByMonth			TO user_cashier;
GRANT EXECUTE ON sp_GetBestSellingItems			TO user_cashier;

GRANT SELECT ON vw_TableStatus					TO user_cashier;
GRANT SELECT ON vw_BestSellingItems				TO user_cashier;

DENY DELETE ON Invoice							TO user_cashier;
DENY DELETE ON InvoiceDetail					TO user_cashier;
DENY DELETE ON MenuItem							TO user_cashier;
DENY DELETE ON [Table]							TO user_cashier;
GO


--Waiter
GRANT SELECT ON Category						TO user_waiter;
GRANT SELECT ON MenuItem						TO user_waiter;
GRANT SELECT ON [Table]							TO user_waiter;

GRANT SELECT ON Invoice							TO user_waiter;
GRANT SELECT, INSERT ON InvoiceDetail			TO user_waiter;
GRANT SELECT ON Customer						TO user_waiter;

GRANT EXECUTE ON sp_AddInvoice					TO user_waiter;
GRANT EXECUTE ON sp_AddInvoiceDetail			TO user_waiter;

GRANT SELECT ON vw_TableStatus					TO user_waiter;
GRANT SELECT ON Reservation						TO user_waiter;

DENY INSERT, UPDATE, DELETE ON Invoice			TO user_waiter;
DENY UPDATE, DELETE ON InvoiceDetail            TO user_waiter;
DENY SELECT, INSERT, UPDATE, DELETE ON Staff    TO user_waiter;
DENY SELECT, INSERT, UPDATE, DELETE ON Account	TO user_waiter;
DENY INSERT, UPDATE, DELETE ON [Table]			TO user_waiter;
GO


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
SELECT * FROM Invoice;
INSERT INTO Invoice (TotalAmount, Status, PaymentMethod, TableID, StaffID) VALUES (0, 'Unpaid', NULL, 1, 1);
UPDATE Invoice SET TotalAmount = 50000 WHERE InvoiceID = 6;
DELETE FROM Invoice WHERE InvoiceID = 5;

EXEC sp_GetBestSellingItems;

SELECT * FROM vw_TableStatus;

--Cashier
SELECT * FROM MenuItem;
SELECT * FROM [Table];

INSERT INTO Invoice (TotalAmount, Status, PaymentMethod, TableID, StaffID) VALUES (0, 'Unpaid', NULL, 2, 2);
UPDATE Invoice SET TotalAmount = 120000 WHERE InvoiceID = 2;

EXEC sp_PayInvoice @InvoiceID = 2, @PaymentMethod = 'Cash';
EXEC sp_GetRevenueByDate @Date = '2026-04-27';

DELETE FROM Invoice WHERE InvoiceID = 2;

--Waiter
USE QuanLyNhaHang;
EXECUTE AS USER = 'user_waiter';
GO

SELECT * FROM MenuItem;
SELECT * FROM [Table];
SELECT * FROM Customer;
SELECT * FROM Reservation;

EXEC sp_AddInvoiceDetail @InvoiceID = 1, @ItemID = 13, @Quantity = 2;

DELETE FROM InvoiceDetail WHERE InvoiceDetailID = 1;

SELECT * FROM Staff;   -- Lỗi
SELECT * FROM Account; -- Lỗi

UPDATE [Table] SET Status = 'Occupied' WHERE TableID = 1;

