const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middleware/authMiddleware');
const adminMiddleware = require('../middleware/adminMiddleware');

router.use(authMiddleware);
router.use(adminMiddleware);

router.get('/stats', adminController.getDashboardStats);
router.get('/owners', adminController.getOwnersList);
router.get('/owners/:ownerId/stats', adminController.getOwnerStats);
router.get('/export/bookings', adminController.exportBookingsCSV);
router.get('/subscriptions/expiring', adminController.getExpiringSubscriptions);

// Subscription Plan Management
router.get('/plans', adminController.getPlans);
router.post('/plans', adminController.createPlan);
router.put('/plans/:id', adminController.updatePlan);
router.delete('/plans/:id', adminController.deletePlan);

module.exports = router;
