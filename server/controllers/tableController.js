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

async function updateTableStatus(req, res) {
    const { id } = req.params;
    const { status } = req.body; 
    try {
        const pool = await getPool();
        // Kiểm tra bàn 
        const checkTable = await pool.request()
            .input('tableID', sql.Int, id)
            .query('SELECT * FROM [Table] WHERE TableID = @tableID');

        if (checkTable.recordset.length === 0) {
            return res.status(404).json({ error: 'Không tìm thấy bàn' });
        }
        // Cập nhật
        await pool.request()
            .input('status', sql.NVarChar, status)
            .input('tableID', sql.Int, id)
            .query('UPDATE [Table] SET Status = @status WHERE TableID = @tableID');

        res.json({ message: 'Cập nhật trạng thái bàn thành công', tableID: id, status });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
}

async function handleReservedTable(tableID) {
  const confirmAction = confirm(`Bạn có muốn chuyển trạng thái bàn ${tableID} thành Đang sử dụng (Có khách) không?`);
  
  if (confirmAction) {
    try {
      // Gọi API mới tạo ở backend
      const data = await apiFetch(`/api/table/${tableID}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'Occupied' })
      });
      
      showToast('Cập nhật trạng thái bàn thành công!', 'success');
      loadTables(); // Tải lại danh sách bàn
    } catch (e) {
      showToast('Lỗi thao tác: ' + e.message, 'error');
    }
  }
}

module.exports = { 
    getAllTables, 
    getEmptyTables,
    updateTableStatus 
};
