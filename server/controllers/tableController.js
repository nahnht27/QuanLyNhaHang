const { sql, getPool } = require('../config/db');

// Lấy danh sách tất cả bàn
async function getAllTables(req, res) {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .query('SELECT * FROM [Table] ORDER BY TableID');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

// Lấy danh sách bàn trống
async function getEmptyTables(req, res) {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .query("SELECT * FROM [Table] WHERE Status = 'Empty' ORDER BY TableID");
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

module.exports = { getAllTables, getEmptyTables };