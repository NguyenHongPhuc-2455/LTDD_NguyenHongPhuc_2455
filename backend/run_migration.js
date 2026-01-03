const { sql, poolPromise } = require('./config/db');
const fs = require('fs');
const path = require('path');

async function runMigration() {
    try {
        const pool = await poolPromise;
        const sqlFilePath = path.join(__dirname, 'sql', 'add_email_otp.sql');
        const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');

        // Split by GO command as mssql driver might not handle it directly in one go if it's a batch separator
        // Simple split by 'GO' (case insensitive)
        const batches = sqlContent.split(/\bGO\b/i);

        console.log(`Found ${batches.length} batches to execute.`);

        for (let i = 0; i < batches.length; i++) {
            const batch = batches[i].trim();
            if (batch) {
                console.log(`Executing batch ${i + 1}...`);
                await pool.request().query(batch);
            }
        }

        console.log('✅ Migration completed successfully!');
    } catch (err) {
        console.error('❌ Migration failed:', err);
    } finally {
        // Close connection
        // sql.close(); // Keep open or let process exit
        process.exit(0);
    }
}

runMigration();
