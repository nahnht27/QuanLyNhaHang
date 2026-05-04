const express = require('express');
const router = express.Router();
const { sql, getPool } = require('../config/db');

async function deleteStaffById(id) {
    const pool = await getPool();
    const ref = await pool.request()
        .input('id', sql.Int, id)
        .query(`
            SELECT
                (SELECT COUNT(1) FROM Invoice WHERE StaffID = @id) AS InvoiceCount
        `);

    const invoiceCount = ref.recordset[0]?.InvoiceCount || 0;
    if (invoiceCount > 0) {
        throw new Error('Không thể xóa nhân viên đã lập hóa đơn');
    }

    await pool.request()
        .input('id', sql.Int, id)
        .query('DELETE FROM Account WHERE StaffID = @id');

    const result = await pool.request()
        .input('id', sql.Int, id)
        .query('DELETE FROM Staff WHERE StaffID = @id');

    if (!result.rowsAffected || result.rowsAffected[0] === 0) {
        const notFoundError = new Error('Không tìm thấy nhân viên');
        notFoundError.statusCode = 404;
        throw notFoundError;
    }
}

router.get('/', async (req, res) => {
    try {
        const pool = await getPool();
        const result = await pool.request()
            .query('SELECT StaffID, FullName, Position, Phone FROM Staff');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const id = req.params.id;

        const pool = await getPool();
        const result = await pool.request()
            .input('id', sql.Int, id)
            .query(`
                SELECT StaffID, FullName, Position, Phone 
                FROM Staff 
                WHERE StaffID = @id
            `);

        if (result.recordset.length === 0) {
            return res.status(404).json({ error: 'Không tìm thấy nhân viên' });
        }

        res.json(result.recordset[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.post('/', async (req, res) => {
    try {
        const { fullName, phone, position, password, _action, staffID } = req.body;

        if (_action === 'delete') {
            if (!staffID) {
                return res.status(400).json({ error: 'Thiếu staffID để xóa nhân viên' });
            }
            await deleteStaffById(staffID);
            return res.json({ message: 'Xóa thành công' });
        }

        if (position === 'Manager') {
            return res.status(403).json({ error: 'Không cho phép tạo tài khoản Manager từ màn hình quản lý nhân viên' });
        }
        if (!password) {
            return res.status(400).json({ error: 'Vui lòng cung cấp mật khẩu cho tài khoản nhân viên' });
        }

        const pool = await getPool();
        const staffResult = await pool.request()
            .input('FullName', sql.NVarChar, fullName)
            .input('Phone', sql.VarChar, phone)
            .input('Position', sql.VarChar, position)
            .query(`
                INSERT INTO Staff (FullName, Phone, Position, Salary)
                OUTPUT INSERTED.StaffID
                VALUES (@FullName, @Phone, @Position, 0)
            `);

        const newStaffID = staffResult.recordset[0]?.StaffID;
        const username = `staff${newStaffID}`;
        await pool.request()
            .input('Username', sql.VarChar, username)
            .input('Password', sql.VarChar, password)
            .input('Role', sql.NVarChar, position)
            .input('StaffID', sql.Int, newStaffID)
            .query(`
                INSERT INTO Account (Username, Password, Role, StaffID, CustomerID)
                VALUES (@Username, @Password, @Role, @StaffID, NULL)
            `);

        res.json({ message: 'Thêm nhân viên thành công' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.put('/:id', async (req, res) => {
    try {
        const { fullName, phone, position, password } = req.body;
        const id = req.params.id;

        const pool = await getPool();
        const current = await pool.request()
            .input('id', sql.Int, id)
            .query('SELECT Position FROM Staff WHERE StaffID = @id');

        if (current.recordset.length === 0) {
            return res.status(404).json({ error: 'Không tìm thấy nhân viên' });
        }

        const currentPosition = current.recordset[0].Position;
        if (currentPosition !== 'Manager' && position === 'Manager') {
            return res.status(403).json({ error: 'Không cho phép nâng quyền lên Manager' });
        }

        if (currentPosition === 'Manager' && position !== 'Manager') {
            return res.status(403).json({ error: 'Không cho phép đổi vai trò của Manager từ màn hình quản lý nhân viên' });
        }

        const query = `
            UPDATE Staff
            SET FullName = @FullName,
                Phone = @Phone,
                Position = @Position
            WHERE StaffID = @id
        `;

        const request = pool.request()
            .input('FullName', sql.NVarChar, fullName)
            .input('Phone', sql.VarChar, phone)
            .input('Position', sql.VarChar, position)
            .input('id', sql.Int, id);

        await request.query(query);
        await pool.request()
            .input('Role', sql.NVarChar, position)
            .input('id', sql.Int, id)
            .query('UPDATE Account SET Role = @Role WHERE StaffID = @id');

        if (password) {
            await pool.request()
                .input('Password', sql.VarChar, password)
                .input('id', sql.Int, id)
                .query('UPDATE Account SET Password = @Password WHERE StaffID = @id');
        }

        res.json({ message: 'Cập nhật thành công' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        const id = req.params.id;
        await deleteStaffById(id);
        res.json({ message: 'Xóa thành công' });
    } catch (err) {
        res.status(err.statusCode || 400).json({ error: err.message });
    }
});

router.post('/delete/:id', async (req, res) => {
    try {
        const id = req.params.id;
        await deleteStaffById(id);
        res.json({ message: 'Xóa thành công' });
    } catch (err) {
        res.status(err.statusCode || 400).json({ error: err.message });
    }
});


module.exports = router;