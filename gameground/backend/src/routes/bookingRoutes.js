const express = require('express');
const router = express.Router();
const bookingController = require('../controllers/bookingController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', bookingController.createBooking);
router.get('/user/:userId', bookingController.getUserBookings);
router.get('/venue/:venueId/date/:date', bookingController.getBookedSlotsForVenue);
router.get('/owner/reports', authMiddleware, bookingController.getOwnerReports);

module.exports = router;
