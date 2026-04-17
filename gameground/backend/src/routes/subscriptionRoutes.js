const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscriptionController');
const authMiddleware = require('../middleware/authMiddleware');

// Public endpoint — no auth needed
router.get('/plans', subscriptionController.getActivePlans);

// Authenticated endpoints
router.post('/purchase', authMiddleware, subscriptionController.purchaseSubscription);
router.get('/me', authMiddleware, subscriptionController.getMySubscription);

module.exports = router;
