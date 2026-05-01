const express = require('express');
const router  = express.Router();
const { sql, getPool } = require('../config/db');

// GET /api/reservation/tables – bàn trống để khách chọn 
router.get('/tables', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .query("SELECT TableID, TableName, Capacity FROM [Table] WHERE Status = 'Empty' ORDER BY TableID");
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /api/reservation – khách đặt bàn mới
router.post('/', async (req, res) => {
    try {
        const { fullName, phone, reservationDate, guestCount, tableID, note } = req.body;
        if (!fullName || !phone || !reservationDate || !guestCount || !tableID)
            return res.status(400).json({ error: 'Vui lòng điền đầy đủ thông tin!' });

        const pool = await getPool();

        // Tìm hoặc tạo Customer
        let cusResult = await pool.request()
            .input('Phone', sql.VarChar(15), phone)
            .query('SELECT CustomerID FROM Customer WHERE Phone = @Phone');

        let customerID;
        if (cusResult.recordset.length > 0) {
            customerID = cusResult.recordset[0].CustomerID;
        } else {
            const newCus = await pool.request()
                .input('FullName', sql.NVarChar(100), fullName)
                .input('Phone',    sql.VarChar(15),   phone)
                .query('INSERT INTO Customer (FullName, Phone) OUTPUT INSERTED.CustomerID VALUES (@FullName, @Phone)');
            customerID = newCus.recordset[0].CustomerID;
        }

        // Tạo Reservation
        await pool.request()
            .input('ReservationDate', sql.DateTime,     new Date(reservationDate))
            .input('GuestCount',      sql.Int,          parseInt(guestCount))
            .input('Note',            sql.NVarChar(255), note || null)
            .input('CustomerID',      sql.Int,          customerID)
            .input('TableID',         sql.Int,          parseInt(tableID))
            .query(`INSERT INTO Reservation (ReservationDate, GuestCount, Note, CustomerID, TableID)
                    VALUES (@ReservationDate, @GuestCount, @Note, @CustomerID, @TableID)`);

        res.json({ message: 'Đặt bàn thành công! Chúng tôi sẽ liên hệ xác nhận sớm.' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/reservation – danh sách đặt bàn (dành cho dashboard)
router.get('/', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request().query(`
            SELECT r.ReservationID, c.FullName, c.Phone,
                   t.TableName, r.ReservationDate, r.GuestCount,
                   r.Note, r.Status
            FROM Reservation r
            JOIN Customer c ON r.CustomerID = c.CustomerID
            JOIN [Table]   t ON r.TableID   = t.TableID
            ORDER BY r.ReservationDate DESC
        `);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /api/reservation/:id – cập nhật trạng thái (Confirmed/Cancelled)
router.put('/:id', async (req, res) => {
    try {
        const { status } = req.body;
        if (!['Confirmed','Cancelled'].includes(status))
            return res.status(400).json({ error: 'Trạng thái không hợp lệ!' });
        const pool = await getPool();
        await pool.request()
            .input('Status',        sql.NVarChar(20), status)
            .input('ReservationID', sql.Int,          parseInt(req.params.id))
            .query('UPDATE Reservation SET Status = @Status WHERE ReservationID = @ReservationID');
        res.json({ message: 'Cập nhật thành công!' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
