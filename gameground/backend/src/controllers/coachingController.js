const db = require('../models');
const Coaching = db.Coaching;

exports.getAllCoachings = async (req, res) => {
    try {
        const coachings = await Coaching.findAll();
        res.json(coachings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.createCoaching = async (req, res) => {
    try {
        const { name, pic, mobileNo, durationMonths, pricePerMonth } = req.body;
        const ownerId = req.user.id;
        const coaching = await Coaching.create({
            name,
            pic,
            mobileNo,
            durationMonths,
            pricePerMonth,
            ownerId
        });
        res.status(201).json(coaching);
    } catch (error) {
        console.error("Coaching creation error:", error);
        res.status(500).json({ message: error.message });
    }
};

exports.getMyCoachings = async (req, res) => {
    try {
        const ownerId = req.user.id;
        const coachings = await Coaching.findAll({ where: { ownerId } });
        res.json(coachings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getCoachingById = async (req, res) => {
    try {
        const coaching = await Coaching.findByPk(req.params.id);
        if (!coaching) return res.status(404).json({ message: 'Coaching not found' });
        res.json(coaching);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.deleteCoaching = async (req, res) => {
    try {
        const { id } = req.params;
        const ownerId = req.user.id;
        const coaching = await Coaching.findOne({ where: { id, ownerId } });

        if (!coaching) {
            return res.status(404).json({ message: 'Coaching not found or unauthorized' });
        }

        await coaching.destroy();
        res.json({ message: 'Coaching deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.uploadImage = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'No image file provided' });
        }
        const pic = `/uploads/${req.file.filename}`;
        res.status(200).json({ pic });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
