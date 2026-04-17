const express = require('express');
const router = express.Router();
const venueController = require('../controllers/venueController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, 'venue-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.post('/upload', authMiddleware, upload.array('images', 10), venueController.uploadImage);
router.get('/', venueController.getAllVenues);
router.get('/my', authMiddleware, venueController.getMyVenues);
router.post('/', authMiddleware, venueController.createVenue);
router.get('/:id', venueController.getVenueById);
router.put('/:id', authMiddleware, venueController.updateVenue);
router.delete('/:id', authMiddleware, venueController.deleteVenue);

module.exports = router;
