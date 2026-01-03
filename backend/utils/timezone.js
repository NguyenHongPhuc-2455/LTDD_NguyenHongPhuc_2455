const moment = require('moment-timezone');
const VIETNAM_TZ = 'Asia/Ho_Chi_Minh';

/**
 * Convert local datetime string to Vietnam timezone ISO string
 * Input: '2026-01-04T20:30:00.000' (local time)
 * Output: '2026-01-04T20:30:00+07:00' (Vietnam timezone)
 */
function toVietnamTime(datetimeString) {
    // Parse as local time and set to Vietnam timezone
    return moment.tz(datetimeString, VIETNAM_TZ).format();
}

/**
 * Convert SQL Server DATETIMEOFFSET to Vietnam timezone
 * Input: SQL Server DATETIMEOFFSET value
 * Output: ISO string with Vietnam timezone
 */
function formatVietnamTime(sqlDatetime) {
    return moment(sqlDatetime).tz(VIETNAM_TZ).format();
}

/**
 * Get current Vietnam time
 * Output: ISO string with Vietnam timezone
 */
function nowVietnam() {
    return moment().tz(VIETNAM_TZ).format();
}

module.exports = {
    toVietnamTime,
    formatVietnamTime,
    nowVietnam,
    VIETNAM_TZ
};
