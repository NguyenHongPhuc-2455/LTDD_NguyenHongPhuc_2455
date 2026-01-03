const { sql } = require('../config/db');
const { toVietnamTime } = require('../utils/timezone');

exports.getAllEvents = async (req, res) => {
    try {
        let query = `
            SELECT 
                e.EventID, e.Title, e.Description,
                FORMAT(e.StartTime, 'yyyy-MM-dd HH:mm:ss') as StartTime,
                FORMAT(e.EndTime, 'yyyy-MM-dd HH:mm:ss') as EndTime,
                e.UserID, e.Status, e.PriorityID,
                p.LevelName, p.ColorCode, p.Weight
            FROM Events e
            LEFT JOIN Priorities p ON e.PriorityID = p.PriorityID
        `;

        if (req.user.role === 'Admin' || req.user.role === 'Manager') {
            query += ' ORDER BY p.Weight DESC, e.StartTime ASC';
            const result = await sql.query(query);
            return res.json(result.recordset);
        }

        const result = await sql.query`
            SELECT 
                e.EventID, e.Title, e.Description,
                FORMAT(e.StartTime, 'yyyy-MM-dd HH:mm:ss') as StartTime,
                FORMAT(e.EndTime, 'yyyy-MM-dd HH:mm:ss') as EndTime,
                e.UserID, e.Status, e.PriorityID,
                p.LevelName, p.ColorCode, p.Weight
            FROM Events e
            LEFT JOIN Priorities p ON e.PriorityID = p.PriorityID
            WHERE e.UserID = ${req.user.id}
            ORDER BY p.Weight DESC, e.StartTime ASC
        `;
        res.json(result.recordset);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.getEventById = async (req, res) => {
    const { id } = req.params;
    try {
        const result = await sql.query`SELECT * FROM Events WHERE EventID = ${id}`;
        if (result.recordset.length === 0) {
            return res.status(404).json({ message: 'Event not found' });
        }

        const event = result.recordset[0];

        if (req.user.role === 'Khách hàng' && event.UserID !== req.user.id) {
            return res.status(403).json({ message: 'Forbidden' });
        }

        res.json(event);
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.createEvent = async (req, res) => {
    const { title, description, startTime, endTime, priorityId } = req.body;
    const userId = req.user.id;
    const finalPriorityId = priorityId || 2;

    try {
        // Convert to Vietnam timezone
        const startTimeVN = toVietnamTime(startTime);
        const endTimeVN = toVietnamTime(endTime);

        await sql.query`
            INSERT INTO Events (Title, Description, StartTime, EndTime, UserID, Status, PriorityID) 
            VALUES (${title}, ${description}, ${startTimeVN}, ${endTimeVN}, ${userId}, 'Pending', ${finalPriorityId})
        `;
        res.status(201).json({ message: 'Event created successfully' });
    } catch (err) {
        console.error('CREATE EVENT ERROR:', err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.updateEvent = async (req, res) => {
    const { id } = req.params;
    const { title, description, startTime, endTime, status, priorityId } = req.body;

    try {
        const check = await sql.query`SELECT * FROM Events WHERE EventID = ${id}`;
        if (check.recordset.length === 0) {
            return res.status(404).json({ message: 'Event not found' });
        }

        // Allow Admin and Manager to update any event
        if (req.user.role === 'Khách hàng' && check.recordset[0].UserID !== req.user.id) {
            return res.status(403).json({ message: 'Forbidden' });
        }

        // Convert to Vietnam timezone
        const startTimeVN = toVietnamTime(startTime);
        const endTimeVN = toVietnamTime(endTime);

        await sql.query`
            UPDATE Events 
            SET Title = ${title}, Description = ${description}, StartTime = ${startTimeVN}, 
                EndTime = ${endTimeVN}, Status = ${status}, PriorityID = ${priorityId} 
            WHERE EventID = ${id}
        `;

        res.json({ message: 'Event updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};

exports.deleteEvent = async (req, res) => {
    const { id } = req.params;
    try {
        const check = await sql.query`SELECT * FROM Events WHERE EventID = ${id}`;
        if (check.recordset.length === 0) {
            return res.status(404).json({ message: 'Event not found' });
        }

        // Allow Admin and Manager to delete any event
        if (req.user.role === 'Khách hàng' && check.recordset[0].UserID !== req.user.id) {
            return res.status(403).json({ message: 'Forbidden' });
        }

        await sql.query`DELETE FROM Events WHERE EventID = ${id}`;
        res.json({ message: 'Event deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Server Error' });
    }
};
