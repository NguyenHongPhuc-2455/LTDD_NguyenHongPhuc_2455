const { sql } = require('../config/db');

exports.getAllRoles = async (req, res) => {
    try {
        const result = await sql.query`SELECT * FROM Roles`;
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.createRole = async (req, res) => {
    const { roleName } = req.body;
    try {
        await sql.query`INSERT INTO Roles (RoleName) VALUES (${roleName})`;
        res.status(201).json({ message: 'Role created successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.updateRole = async (req, res) => {
    const { id } = req.params;
    const { roleName } = req.body;
    try {
        await sql.query`UPDATE Roles SET RoleName = ${roleName} WHERE RoleID = ${id}`;
        res.json({ message: 'Role updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.deleteRole = async (req, res) => {
    const { id } = req.params;
    try {
        await sql.query`DELETE FROM Roles WHERE RoleID = ${id}`;
        res.json({ message: 'Role deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};
