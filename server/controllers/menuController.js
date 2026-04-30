const { getPool } = require('../config/db');

const getAllMenu = async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .query(`SELECT c.CategoryName AS DanhMuc, 
                    mi.ItemID, 
                    mi.ItemName AS TenMon, 
                    mi.Price AS Gia, 
                    mi.Description AS MoTa,
                    mi.Status AS TrangThai
                    FROM MenuItem mi
                    JOIN Category c ON mi.CategoryID = c.CategoryID
                    ORDER BY DanhMuc, TenMon`);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

const getAvailableMenu = async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .query(`SELECT c.CategoryName AS DanhMuc,
                    mi.ItemID,
                    mi.ItemName AS TenMon,
                    mi.Price AS Gia,
                    mi.Description AS MoTa,
                    mi.Status AS TrangThai
                    FROM MenuItem mi
                    JOIN Category c ON mi.CategoryID = c.CategoryID
                    WHERE mi.Status = 'Available'
                    ORDER BY DanhMuc, TenMon`);
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

module.exports = { getAllMenu, getAvailableMenu };