const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');
const verifyToken = require('../middleware/authMiddleware');

router.post('/pay-on-spot', verifyToken, paymentController.payOnSpot);
router.post('/pay-with-upi', verifyToken, paymentController.payWithUpi);
router.get('/booking/:bookingId', verifyToken, paymentController.getPaymentByBookingId);

module.exports = router;
