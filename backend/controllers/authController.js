const { sql } = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { generateOTP } = require('../utils/otpGenerator');
const { sendOTP } = require('../utils/emailService');

exports.register = async (req, res) => {
    console.log('📝 REGISTER REQUEST:', req.body);
    const { username, password, fullName, role, email } = req.body;
    try {
        // Validate email format
        if (!email || !email.endsWith('@gmail.com')) {
            return res.status(400).json({ message: 'Email must be a valid Gmail address' });
        }

        // Check if user or email exists
        const userCheck = await sql.query`SELECT * FROM Users WHERE Username = ${username} OR Email = ${email}`;
        if (userCheck.recordset.length > 0) {
            return res.status(400).json({ message: 'Username or Email already exists' });
        }

        // Get Role ID
        const roleResult = await sql.query`SELECT RoleID FROM Roles WHERE RoleName = ${role}`;
        if (roleResult.recordset.length === 0) {
            return res.status(400).json({ message: 'Invalid Role. Allowed: Admin, Nhân viên, Khách hàng' });
        }
        const roleId = roleResult.recordset[0].RoleID;

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        // Insert User with Email
        await sql.query`
            INSERT INTO Users (Username, Password, FullName, RoleID, Email, Is2FAEnabled) 
            VALUES (${username}, ${hashedPassword}, ${fullName}, ${roleId}, ${email}, 0)
        `;

        res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.login = async (req, res) => {
    console.log('🔐 LOGIN REQUEST:', req.body);
    const { username, password } = req.body;
    try {
        // Check User with Email
        const result = await sql.query`
            SELECT u.UserID, u.Username, u.Password, u.FullName, u.Email, r.RoleName 
            FROM Users u 
            JOIN Roles r ON u.RoleID = r.RoleID 
            WHERE u.Username = ${username}
        `;

        if (result.recordset.length === 0) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        const user = result.recordset[0];

        // Check if user has email
        if (!user.Email) {
            return res.status(400).json({ message: 'Please update your profile with an email address' });
        }

        // Validate Password
        const isMatch = await bcrypt.compare(password, user.Password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        // Generate 6-digit OTP
        const otpCode = generateOTP();
        const otpExpiry = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

        // Save OTP to database
        await sql.query`
            UPDATE Users 
            SET OTPCode = ${otpCode}, OTPExpiry = ${otpExpiry}
            WHERE UserID = ${user.UserID}
        `;

        // Send OTP via email
        const emailSent = await sendOTP(user.Email, otpCode);
        if (!emailSent) {
            return res.status(500).json({ message: 'Failed to send OTP email' });
        }

        console.log(`✅ OTP sent to ${user.Email}`);
        res.json({
            requiresOTP: true,
            userId: user.UserID,
            email: user.Email
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.verifyOTP = async (req, res) => {
    const { userId, otpCode } = req.body;
    try {
        const result = await sql.query`
            SELECT u.UserID, u.Username, u.FullName, u.OTPCode, u.OTPExpiry, r.RoleName
            FROM Users u
            JOIN Roles r ON u.RoleID = r.RoleID
            WHERE u.UserID = ${userId}
        `;

        if (result.recordset.length === 0) {
            return res.status(400).json({ message: 'User not found' });
        }

        const user = result.recordset[0];

        //  Check OTP
        if (!user.OTPCode || user.OTPCode !== otpCode) {
            return res.status(400).json({ message: 'Invalid OTP code' });
        }

        // Check expiry
        if (new Date() > new Date(user.OTPExpiry)) {
            return res.status(400).json({ message: 'OTP has expired' });
        }

        // Clear OTP
        await sql.query`
            UPDATE Users 
            SET OTPCode = NULL, OTPExpiry = NULL
            WHERE UserID = ${userId}
        `;

        // Generate JWT
        const payload = { id: user.UserID, username: user.Username, role: user.RoleName };
        const token = jwt.sign(payload, process.env.JWT_SECRET || 'secret', { expiresIn: '1h' });

        console.log('✅ OTP verified, login successful');
        res.json({ token, role: user.RoleName });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};
