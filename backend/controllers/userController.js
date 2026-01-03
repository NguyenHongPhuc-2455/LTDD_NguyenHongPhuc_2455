const { sql } = require('../config/db');
const bcrypt = require('bcryptjs');

exports.getAllUsers = async (req, res) => {
    try {
        const result = await sql.query`
            SELECT u.UserID, u.Username, u.FullName, u.Email, r.RoleName 
            FROM Users u 
            JOIN Roles r ON u.RoleID = r.RoleID
        `;
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.createUser = async (req, res) => {
    const { username, password, fullName, role, email } = req.body;
    try {
        // Check if user exists
        const userCheck = await sql.query`SELECT * FROM Users WHERE Username = ${username} OR Email = ${email}`;
        if (userCheck.recordset.length > 0) {
            return res.status(400).json({ message: 'Username or Email already exists' });
        }

        // Get Role ID
        const roleResult = await sql.query`SELECT RoleID FROM Roles WHERE RoleName = ${role}`;
        if (roleResult.recordset.length === 0) {
            return res.status(400).json({ message: 'Invalid Role' });
        }
        const roleId = roleResult.recordset[0].RoleID;

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert User
        await sql.query`
            INSERT INTO Users (Username, Password, FullName, RoleID, Email, Is2FAEnabled) 
            VALUES (${username}, ${hashedPassword}, ${fullName}, ${roleId}, ${email}, 0)
        `;

        res.status(201).json({ message: 'User created successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.updateUser = async (req, res) => {
    const { id } = req.params;
    const { fullName, role, email } = req.body;
    try {
        // Get Role ID
        const roleResult = await sql.query`SELECT RoleID FROM Roles WHERE RoleName = ${role}`;
        if (roleResult.recordset.length === 0) {
            return res.status(400).json({ message: 'Invalid Role' });
        }
        const roleId = roleResult.recordset[0].RoleID;

        await sql.query`
            UPDATE Users 
            SET FullName = ${fullName}, RoleID = ${roleId}, Email = ${email}
            WHERE UserID = ${id}
        `;

        res.json({ message: 'User updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.deleteUser = async (req, res) => {
    const { id } = req.params;
    try {
        await sql.query`DELETE FROM Users WHERE UserID = ${id}`;
        res.json({ message: 'User deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};
