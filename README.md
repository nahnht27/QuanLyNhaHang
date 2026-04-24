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
2. Mở SSMS và chạy file:
   database/database.sql
3. Vào thư mục server, cài dependencies:
   cd server  
   npm install
4. Chạy server:
   npm start
5. Truy cập:
   http://localhost:3000

## Cấu trúc chính
* `database/`: file SQL tạo bảng, stored procedure, trigger
* `server/`: backend Node.js + Express
* `client/`: giao diện người dùng
* `docs/`: ERD và tài liệu