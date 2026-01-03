const { sql } = require('../config/db');

exports.getAllPriorities = async (req, res) => {
    try {
        const result = await sql.query`SELECT * FROM Priorities ORDER BY Weight ASC`;
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};
