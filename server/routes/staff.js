const express = require('express');
const router = express.Router();
const { sql, getPool } = require('../config/db');

// GET /api/staff – Danh sách nhân viên
router.get('/', async (req, res) => {
    try {
        const pool = await poolPromise;
        const result = await pool.request()
            .query('SELECT StaffID, FullName, Position, Phone FROM Staff');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;