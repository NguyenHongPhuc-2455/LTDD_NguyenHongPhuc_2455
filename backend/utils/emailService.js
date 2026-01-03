const nodemailer = require('nodemailer');

// Configure Gmail SMTP
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_APP_PASSWORD,
    },
});

/**
 * Send OTP code to user's email
 * @param {string} email - Recipient email
 * @param {string} otpCode - 6-digit OTP code
 */
async function sendOTP(email, otpCode) {
    // MOCK MODE: If credentials are missing or default, log to console
    if (!process.env.GMAIL_USER || process.env.GMAIL_USER.includes('your-email')) {
        console.log('⚠️  MOCK EMAIL MODE (No Gmail Configured) ⚠️');
        console.log(`📨  To: ${email}`);
        console.log(`🔑  OTP CODE: ${otpCode}`);
        console.log('==============================================');
        return true; // Pretend success
    }

    const mailOptions = {
        from: process.env.GMAIL_USER,
        to: email,
        subject: 'NHP Calendar - Your Login OTP Code',
        html: `
      <div style="font-family: Arial, sans-serif; padding: 20px;">
        <h2>Your OTP Verification Code</h2>
        <p>Your OTP code for NHP Calendar login is:</p>
        <h1 style="color: #4F46E5; font-size: 32px; letter-spacing: 5px;">${otpCode}</h1>
        <p>This code will expire in <strong>5 minutes</strong>.</p>
        <p>If you didn't request this code, please ignore this email.</p>
      </div>
    `,
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`✅ OTP email sent to ${email}`);
        return true;
    } catch (error) {
        console.error('❌ Error sending OTP email:', error.message);
        // Fallback to console log if send fails
        console.log('⚠️  FALLBACK MOCK MODE ⚠️');
        console.log(`📨  To: ${email}`);
        console.log(`🔑  OTP CODE: ${otpCode}`);
        return true; // Allow login to proceed even if email fails
    }
}

module.exports = { sendOTP };
