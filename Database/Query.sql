--xem thực đơn trong danh mục
SELECT 
    c.CategoryName AS DanhMuc,
    mi.ItemName AS TenMon,
    mi.Price AS DonGia,
    mi.Status AS TrangThai
FROM MenuItem mi
JOIN Category c ON mi.CategoryID = c.CategoryID
ORDER BY c.CategoryName, mi.ItemName;

--trạng thái bàn
SELECT
    t.TableName         AS TenBan,
    t.Capacity          AS SucChua,
    t.Status            AS TrangThai,
    i.InvoiceID         AS MaHoaDon,
    i.TotalAmount       AS TongTienHienTai
FROM [Table] t
LEFT JOIN Invoice i ON t.TableID = i.TableID
    AND i.Status = 'Unpaid'
ORDER BY t.TableName;

--xem chi tiết hóa đơn
SELECT
    i.InvoiceID                         AS N'Mã hóa đơn',
    t.TableName                         AS N'Tên bàn',
    m.ItemName                          AS N'Tên món',
    id.Quantity                         AS N'Số lượng',
    id.UnitPrice                        AS N'Đơn giá',
    id.Quantity * id.UnitPrice          AS N'Thành tiền'
FROM InvoiceDetail id
JOIN Invoice  i ON id.InvoiceID = i.InvoiceID
JOIN MenuItem m ON id.ItemID    = m.ItemID
JOIN [Table]  t ON i.TableID    = t.TableID
WHERE i.InvoiceID = 1
ORDER BY m.ItemName;

--Thống kê doanh thu theo ngày
EXEC sp_GetRevenueByDate 
    @Date = '2026-04-29';

--Thống kê doanh thu theo tháng
EXEC sp_GetRevenueByMonth 
    @Month = 4, 
    @Year  = 2026;

-- top 5 món bán chạy
EXEC sp_GetBestSellingItems 
    @TopN = 5;
-- Truy vấn trực tiếp
SELECT TOP 5
    m.ItemName                          AS TenMon,
    c.CategoryName                      AS DanhMuc,
    SUM(id.Quantity)                    AS TongSoLuong,
    SUM(id.Quantity * id.UnitPrice)     AS DoanhThu
FROM InvoiceDetail id
JOIN MenuItem m ON id.ItemID        = m.ItemID
JOIN Category c ON m.CategoryID     = c.CategoryID
JOIN Invoice  i ON id.InvoiceID     = i.InvoiceID
WHERE i.Status = 'Paid'
GROUP BY m.ItemName, c.CategoryName
ORDER BY TongSoLuong DESC;

--Xem lịch sử đặt bàn của khách hàng theo ngày cụ thể
SELECT 
    c.FullName          AS TenKhach,
    c.Phone             AS SoDienThoai,
    t.TableName         AS TenBan,
    r.ReservationDate   AS ThoiGianDen,
    r.GuestCount        AS SoNguoi,
    r.Note              AS GhiChu,
    r.Status            AS TrangThai
FROM Reservation r
JOIN Customer c ON r.CustomerID = c.CustomerID
JOIN [Table] t  ON r.TableID   = t.TableID
WHERE DAY(r.ReservationDate)   = 25
  AND MONTH(r.ReservationDate) = 4
  AND YEAR(r.ReservationDate)  = 2026
ORDER BY r.ReservationDate;


--Danh sách nhân viên theo chức vụ
SELECT 
    StaffID         AS MaNV,
    FullName        AS HoTen,
    Position        AS ChucVu,
    Phone           AS SoDienThoai,
    Salary          AS Luong,
    StartDate       AS NgayVaoLam
FROM Staff
ORDER BY Position, FullName;

