const { sql, getPool } = require('../config/db');

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