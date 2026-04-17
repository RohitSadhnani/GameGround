const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const verifyToken = require('../middleware/authMiddleware');

router.get('/', verifyToken, notificationController.getUserNotifications);

module.exports = router;
