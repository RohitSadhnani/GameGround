const express = require('express');
const router = express.Router();
const coachingController = require('../controllers/coachingController');
const authMiddleware = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        cb(null, 'coaching-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

router.post('/upload', authMiddleware, upload.single('image'), coachingController.uploadImage);
router.get('/', coachingController.getAllCoachings);
router.get('/my', authMiddleware, coachingController.getMyCoachings);
router.post('/', authMiddleware, coachingController.createCoaching);
router.get('/:id', coachingController.getCoachingById);
router.delete('/:id', authMiddleware, coachingController.deleteCoaching);

module.exports = router;
