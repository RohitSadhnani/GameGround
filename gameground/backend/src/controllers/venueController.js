const db = require('../models');
const Venue = db.Venue;

exports.getAllVenues = async (req, res) => {
    try {
        const venues = await Venue.findAll();
        res.json(venues);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.createVenue = async (req, res) => {
    try {
        const { name, location, sportType, pricePerHour, description, facilities, timings, availableSlots, imageUrl, imageUrls, phoneNumber } = req.body;
        const ownerId = req.user.id;
        const venue = await Venue.create({
            name,
            location,
            sportType,
            pricePerHour,
            description,
            facilities,
            timings,
            availableSlots,
            imageUrl,
            imageUrls,
            phoneNumber,
            ownerId
        });
        res.status(201).json(venue);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getMyVenues = async (req, res) => {
    try {
        const ownerId = req.user.id;
        const venues = await Venue.findAll({ where: { ownerId } });
        res.json(venues);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.deleteVenue = async (req, res) => {
    try {
        const { id } = req.params;
        const ownerId = req.user.id;
        const venue = await Venue.findOne({ where: { id, ownerId } });

        if (!venue) {
            return res.status(404).json({ message: 'Venue not found or unauthorized' });
        }

        await venue.destroy();
        res.json({ message: 'Venue deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.updateVenue = async (req, res) => {
    try {
        const { id } = req.params;
        const ownerId = req.user.id;

        const venue = await Venue.findOne({ where: { id, ownerId } });

        if (!venue) {
            return res.status(404).json({ message: 'Venue not found or unauthorized' });
        }

        const { name, location, sportType, pricePerHour, description, facilities, timings, availableSlots, imageUrl, imageUrls, phoneNumber } = req.body;

        await venue.update({
            name,
            location,
            sportType,
            pricePerHour,
            description,
            facilities,
            timings,
            availableSlots,
            imageUrl,
            imageUrls,
            phoneNumber,
        });

        res.json(venue);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getVenueById = async (req, res) => {
    try {
        const venue = await Venue.findByPk(req.params.id);
        if (!venue) return res.status(404).json({ message: 'Venue not found' });
        res.json(venue);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.uploadImage = async (req, res) => {
    try {
        if (req.files && req.files.length > 0) {
            // Handle multiple files
            const urls = req.files.map(file => `/uploads/${file.filename}`);
            return res.status(200).json({ imageUrls: urls });
        } else if (req.file) {
             // Handle single file (fallback)
             const imageUrl = `/uploads/${req.file.filename}`;
             return res.status(200).json({ imageUrl });
        } else {
             return res.status(400).json({ message: 'No image files provided' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
