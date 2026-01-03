const express = require('express');
const router = express.Router();
const priorityController = require('../controllers/priorityController');
const { verifyToken } = require('../middleware/auth');

// GET /api/priorities - Get all priority levels (authenticated users)
router.get('/', verifyToken, priorityController.getAllPriorities);

module.exports = router;
