const express = require('express');
const router = express.Router();
const coachingPaymentController = require('../controllers/coachingPaymentController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, coachingPaymentController.createPayment);
router.get('/my', authMiddleware, coachingPaymentController.getMyPayments);
router.get('/coaching/:coachingId', authMiddleware, coachingPaymentController.getCoachingPayments);

module.exports = router;
