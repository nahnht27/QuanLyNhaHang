CREATE LOGIN ManagerLogin WITH PASSWORD = 'Manager@123';
CREATE LOGIN CashierLogin WITH PASSWORD = 'Cashier@123';
CREATE LOGIN WaiterLogin WITH PASSWORD = 'Waiter@123';
GO

USE QuanLyNhaHang;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_manager')
    DROP USER user_manager;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_cashier')
    DROP USER user_cashier;
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'user_waiter')
    DROP USER user_waiter;
GO

CREATE USER user_manager FOR LOGIN ManagerLogin;
CREATE USER user_cashier FOR LOGIN CashierLogin;
CREATE USER user_waiter FOR LOGIN WaiterLogin;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON Category      TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON MenuItem      TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON [Table]       TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customer      TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Staff         TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Account       TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservation   TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Invoice       TO user_manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON InvoiceDetail TO user_manager;

GRANT EXECUTE ON sp_AddInvoice          TO user_manager;
GRANT EXECUTE ON sp_AddInvoiceDetail    TO user_manager;
GRANT EXECUTE ON sp_PayInvoice          TO user_manager;
GRANT EXECUTE ON sp_GetRevenueByDate    TO user_manager;
GRANT EXECUTE ON sp_GetRevenueByMonth   TO user_manager;
GRANT EXECUTE ON sp_GetBestSellingItems TO user_manager;

GRANT SELECT ON vw_TableStatus      TO user_manager;
GRANT SELECT ON vw_BestSellingItems TO user_manager;

GRANT SELECT ON Category  TO user_cashier;
GRANT SELECT ON MenuItem  TO user_cashier;
GRANT SELECT ON [Table]   TO user_cashier;

GRANT SELECT, INSERT, UPDATE ON Invoice       TO user_cashier;
GRANT SELECT, INSERT, UPDATE ON InvoiceDetail TO user_cashier;

GRANT EXECUTE ON sp_PayInvoice          TO user_cashier;
GRANT EXECUTE ON sp_GetRevenueByDate    TO user_cashier;
GRANT EXECUTE ON sp_GetRevenueByMonth   TO user_cashier;
GRANT EXECUTE ON sp_GetBestSellingItems TO user_cashier;

GRANT SELECT ON vw_TableStatus      TO user_cashier;
GRANT SELECT ON vw_BestSellingItems TO user_cashier;

DENY DELETE ON Invoice       TO user_cashier;
DENY DELETE ON InvoiceDetail TO user_cashier;
DENY DELETE ON MenuItem      TO user_cashier;
DENY DELETE ON [Table]       TO user_cashier;

GRANT SELECT ON Category TO user_waiter;
GRANT SELECT ON MenuItem TO user_waiter;
GRANT SELECT ON [Table]  TO user_waiter;

GRANT SELECT ON Invoice                TO user_waiter;
GRANT SELECT, INSERT ON InvoiceDetail  TO user_waiter;
GRANT SELECT ON Customer               TO user_waiter;
GRANT SELECT ON Reservation            TO user_waiter;

GRANT EXECUTE ON sp_AddInvoice       TO user_waiter;
GRANT EXECUTE ON sp_AddInvoiceDetail TO user_waiter;

GRANT SELECT ON vw_TableStatus TO user_waiter;

DENY INSERT, UPDATE, DELETE ON Invoice        TO user_waiter;
DENY UPDATE, DELETE ON InvoiceDetail          TO user_waiter;
DENY SELECT, INSERT, UPDATE, DELETE ON Staff  TO user_waiter;
DENY SELECT, INSERT, UPDATE, DELETE ON Account TO user_waiter;
DENY INSERT, UPDATE, DELETE ON [Table]        TO user_waiter;