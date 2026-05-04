const express = require('express');
const router = express.Router();
const { sql, getPool } = require('../config/db');

// POST /api/invoice – Tạo hóa đơn mới
router.post('/', async (req, res) => {
    try {
        const { tableID, staffID } = req.body;
        if (!tableID || !staffID) {
            return res.status(400).json({ error: 'Thiếu thông tin bàn hoặc nhân viên!' });
        }
        const pool = await getPool();
        const result = await pool.request()
            .input('TableID', sql.Int, tableID)
            .input('StaffID', sql.Int, staffID)
            .execute('sp_AddInvoice');
        if (!result.recordset || result.recordset.length === 0) {
            return res.status(400).json({ error: 'Không thể tạo hóa đơn, vui lòng thử lại.' });
        }
        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// POST /api/invoice/detail – Thêm món vào hóa đơn
router.post('/detail', async (req, res) => {
    try {
        const { invoiceID, menuItemID, quantity } = req.body; // menuItemID sẽ được gán vào ItemID
        if (!invoiceID || !menuItemID || !quantity) {
            return res.status(400).json({ error: 'Thiếu thông tin chi tiết hóa đơn!' });
        }
        const pool = await getPool();
        await pool.request()
            .input('InvoiceID', sql.Int, invoiceID)
            .input('ItemID',    sql.Int, menuItemID) // Khớp với ItemID trong CSDL
            .input('Quantity',  sql.Int, quantity)
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
        if (!invoiceID) {
            return res.status(400).json({ error: 'Vui lòng cung cấp mã hóa đơn!' });
        }
        const pool = await getPool();
        const result = await pool.request()
            .input('InvoiceID',     sql.Int,        invoiceID)
            .input('PaymentMethod', sql.NVarChar(50), paymentMethod)
            .execute('sp_PayInvoice');
        if (!result.recordset || result.recordset.length === 0) {
            return res.status(400).json({ error: 'Không tìm thấy hóa đơn cần thanh toán!' });
        }
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

// GET /api/invoice/table/:tableID – Lấy hóa đơn chưa thanh toán theo bàn
router.get('/table/:tableID', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .input('TableID', sql.Int, req.params.tableID)
            .query(`
                SELECT 
                    i.InvoiceID, 
                    i.TableID, 
                    i.StaffID, 
                    i.TotalAmount, 
                    i.PaymentMethod, 
                    i.Status, 
                    i.CreatedAt,
                    t.TableName
                FROM Invoice i
                LEFT JOIN [Table] t ON i.TableID = t.TableID
                WHERE i.TableID = @TableID AND i.Status = 'Unpaid'
            `);
        
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET /api/invoice/detail/:invoiceID – Lấy chi tiết món ăn trong hóa đơn
router.get('/detail/:invoiceID', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .input('InvoiceID', sql.Int, req.params.invoiceID)
            .query(`
                SELECT 
                    id.InvoiceDetailID,
                    id.InvoiceID,
                    id.ItemID AS MenuItemID,
                    id.Quantity,
                    id.UnitPrice,
                    m.ItemName
                FROM InvoiceDetail id
                LEFT JOIN MenuItem m ON id.ItemID = m.ItemID
                WHERE id.InvoiceID = @InvoiceID
            `);

        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;