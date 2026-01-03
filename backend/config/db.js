const sql = require('mssql');
require('dotenv').config();

const config = {
    user: process.env.DB_USER || 'sa',
    password: process.env.DB_PASSWORD || 'your_password',
    server: process.env.DB_SERVER || 'localhost',
    database: process.env.DB_NAME || 'NHPCalendar',
    options: {
        encrypt: true,
        trustServerCertificate: true,
        instanceName: 'SQLEXPRESS', // Dùng instance name để tự tìm port
        enableArithAbort: true
    },
    // Nếu instanceName không chạy, hãy thử bỏ comment dòng dưới và xóa instanceName
    // port: 1433 
};

const connectDB = async () => {
    try {
        await sql.connect(config);
        console.log('Connected to SQL Server (SQL Auth - Success)');
    } catch (err) {
        console.error('Database connection failed!');
        console.error('Error:', err.message);
    }
};

module.exports = {
    sql,
    connectDB
};
