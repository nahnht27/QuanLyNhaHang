const express = require('express');
const router = express.Router();
const { sql, getPool } = require('../config/db');

// POST /api/invoice – Tạo hóa đơn mới
router.post('/', async (req, res) => {
    try {
        const { tableID, staffID } = req.body;
        const pool = await getPool();
        const result = await pool.request()
            .input('TableID', sql.Int, tableID)
            .input('StaffID', sql.Int, staffID)
            .execute('sp_AddInvoice');
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /api/invoice/detail – Thêm món vào hóa đơn
router.post('/detail', async (req, res) => {
    try {
        const { invoiceID, menuItemID, quantity } = req.body;
        const pool = await getPool();
        await pool.request()
            .input('InvoiceID',  sql.Int, invoiceID)
            .input('MenuItemID', sql.Int, menuItemID)
            .input('Quantity',   sql.Int, quantity)
            .execute('sp_AddInvoiceDetail');
        res.json({ message: 'Thêm món thành công!' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// PUT /api/invoice/pay – Thanh toán
router.put('/pay', async (req, res) => {
    try {
        const { invoiceID, paymentMethod } = req.body;
        const pool = await getPool();
        const result = await pool.request()
            .input('InvoiceID',     sql.Int,         invoiceID)
            .input('PaymentMethod', sql.NVarChar(50), paymentMethod)
            .execute('sp_PayInvoice');
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/invoice/revenue/date/:date
router.get('/revenue/date/:date', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .input('Date', sql.Date, req.params.date)
            .execute('sp_GetRevenueByDate');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/invoice/revenue/month/:month/:year
router.get('/revenue/month/:month/:year', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .input('Month', sql.Int, parseInt(req.params.month))
            .input('Year',  sql.Int, parseInt(req.params.year))
            .execute('sp_GetRevenueByMonth');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/invoice/bestselling
router.get('/bestselling', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .input('TopN', sql.Int, 5)
            .execute('sp_GetBestSellingItems');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;