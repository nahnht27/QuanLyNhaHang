#  QuanLyNhaHang — Happy Dinner

Hệ thống quản lý nhà hàng Việt sử dụng SQL Server + Node.js + Express, xây dựng cho môn **Hệ Quản Trị Cơ Sở Dữ Liệu**.

---

## Tech Stack

- Node.js + Express
- SQL Server / SSMS
- T-SQL (Stored Procedures, Triggers, Views)
- HTML5 / CSS3 / JavaScript
- Bootstrap 5
- Git + GitHub

---

### Customer / Storefront

| Feature | Description |
|---|---|
| Home Page | Landing page with restaurant info and navigation |
| Menu Page | Browse food & drink items by category |
| Reservation | Book a table by selecting date, time and guest count |
| Login / Register | Customer account authentication |

---

### Staff / Admin

| Feature | Description |
|---|---|
| Table Management | View and update table status (Empty / Occupied / Reserved) |
| Menu Management | Add, update, delete menu items and categories |
| Order & Invoice | Create invoices, add order items, process payment |
| Staff Management | View staff list, positions and salary info |
| Revenue Reports | Revenue by date, by month, best-selling items |

---

## Database

**Tables:** `Category`, `MenuItem`, `Table`, `Customer`, `Staff`, `Account`, `Reservation`, `Invoice`, `InvoiceDetail`

---

### Stored Procedures

| Procedure | Description |
|---|---|
| `sp_AddInvoice` | Create a new invoice |
| `sp_AddInvoiceDetail` | Add items to an invoice |
| `sp_PayInvoice` | Process invoice payment |
| `sp_GetRevenueByDate` | Revenue report by date |
| `sp_GetRevenueByMonth` | Revenue report by month |
| `sp_GetBestSellingItems` | Best-selling menu items report |

---

### Triggers

| Trigger | Description |
|---|---|
| `trg_UpdateTotalAmount` | Auto-update invoice total when items are added |
| `trg_UpdateTableStatus` | Auto-update table status on reservation/invoice changes |

---

### Views

| View | Description |
|---|---|
| `vw_TableStatus` | Current status of all tables |
| `vw_BestSellingItems` | Aggregated best-selling items |

---

## Getting Started

### Requirements

- Node.js
- SQL Server + SSMS

---

### 1. Clone repository

```bash
git clone https://github.com/nahnht27/QuanLyNhaHang.git
```

---

### 2. Set up database

Open SSMS and run:

```
Database/database.sql
```

(Optional) Run security/permission script:

```
Database/Security.sql
```

---

### 3. Configure database connection

Open `server/config/db.js` and update your SQL Server credentials:

```js
server: 'YOUR_SERVER_NAME',
user: 'YOUR_USERNAME',
password: 'YOUR_PASSWORD',
database: 'QuanLyNhaHang'
```

---

### 4. Install dependencies and run server

```bash
cd server
npm install
npm start
```

---

### 5. Open in browser

```
http://localhost:3000
```

---

## Project Structure

| Folder / File | Purpose |
|---|---|
| `client/` | Frontend pages (HTML/CSS/JS) |
| `client/index.html` | Home page |
| `client/menu.html` | Menu page |
| `client/reservation.html` | Table reservation page |
| `client/login.html` | Login page |
| `client/dashboard.html` | Staff dashboard |
| `server/` | Backend (Node.js + Express) |
| `server/app.js` | Express app, CORS, route config |
| `server/config/db.js` | SQL Server connection |
| `server/controllers/` | Business logic handlers |
| `server/routes/` | API route definitions |
| `Database/` | SQL scripts |

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| GET | `/api/menu` | Get all menu items |
| GET | `/api/table` | Get all tables |
| POST | `/api/reservation` | Create a reservation |
| GET | `/api/reservation/tables` | Get available tables |
| POST | `/api/invoice` | Create invoice |
| POST | `/api/invoice/detail` | Add item to invoice |
| PUT | `/api/invoice/pay/:id` | Pay invoice |
| GET | `/api/staff` | Get staff list |

---

## Test Accounts

> Login: `http://localhost:3000/login.html`

Role-based access — Manager, Cashier, Waiter and Customer have different permissions.

| Role | Username | Password |
|---|---|---|
| Manager | manager | *(set in Security.sql)* |
| Cashier | cashier | *(set in Security.sql)* |
| Waiter | waiter | *(set in Security.sql)* |
