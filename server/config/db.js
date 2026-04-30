const sql = require('mssql');

const config = {
    user: 'sa',
    password: '123456',
    server: 'localhost',
    port: 1433,
    database: 'QuanLyNhaHang',
    options: {
        trustServerCertificate: true,
        encrypt: false
    }
};

let pool = null;

async function getPool() {
    if (!pool) {
        pool = await sql.connect(config);
        console.log('Kết nối SQL Server thành công!');
    }
    return pool;
}

module.exports = { sql, getPool };