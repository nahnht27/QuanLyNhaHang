# QuanLyNhaHang
Hệ thống quản lý nhà hàng sử dụng SQL Server + Node.js.

## Công nghệ
* SQL Server / SSMS
* T-SQL
* Node.js + Express
* HTML/CSS/JS
* Git + GitHub

## Cách chạy project

1. Clone repo về máy
2. Mở SSMS, chạy file `database/01_create_tables.sql`
3. Chạy tiếp các file SQL theo thứ tự từ `02` đến `08`
4. Vào thư mục server, cài dependencies:
cd server
npm install
5. Chạy server:
npm start
6. Truy cập `http://localhost:3000`

## Cấu trúc chính
* `database/`: các file SQL tạo bảng, stored procedure, trigger...
* `server/`: backend Node.js + Express
* `server/config/`: cấu hình kết nối database
* `server/routes/`: định nghĩa API
* `server/controllers/`: xử lý logic
* `client/`: giao diện HTML/JS
* `docs/`: ERD và tài liệu