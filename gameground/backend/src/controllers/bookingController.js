const db = require('../models');
const Booking = db.Booking;
const Venue = db.Venue;
const User = db.User;

exports.createBooking = async (req, res) => {
    try {
        const { venueId, userId, bookingDate, timeSlot, totalAmount } = req.body;

        // timeSlot could be a comma-separated string like "06:00-07:00,07:00-08:00"
        const requestedSlots = timeSlot.split(',').map(s => s.trim());

        // Check availability strictly for any overlapping slots
        const existingBookings = await Booking.findAll({
            where: { venueId, bookingDate, status: ['confirmed'] } // Only confirmed bookings block slots now
        });

        // Verify none of the requested slots overlap with already booked ones
        for (const booking of existingBookings) {
            const bookedSlots = booking.timeSlot.split(',').map(s => s.trim());
            for (const rSlot of requestedSlots) {
                if (bookedSlots.includes(rSlot)) {
                    return res.status(400).json({ message: `Slot ${rSlot} is already booked` });
                }
            }
        }

        const booking = await Booking.create({
            venueId,
            userId,
            bookingDate,
            timeSlot, // Store exactly as sent "slot1,slot2"
            totalAmount,
            status: 'pending' // Set to pending until payment is processed
        });

        res.status(201).json(booking);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getUserBookings = async (req, res) => {
    try {
        const { userId } = req.params;
        const bookings = await Booking.findAll({
            where: { userId },
            include: [{ model: Venue, attributes: ['name', 'location'] }]
        });
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getBookedSlotsForVenue = async (req, res) => {
    try {
        const { venueId, date } = req.params;
        const bookings = await Booking.findAll({
            where: {
                venueId,
                bookingDate: date,
                status: ['confirmed'] // Only show confirmed bookings locally as booked
            },
            attributes: ['timeSlot']
        });

        const bookedSlots = bookings.map(b => b.timeSlot);
        res.json(bookedSlots);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getOwnerReports = async (req, res) => {
    try {
        const ownerId = req.user.id; // From auth middleware

        // 1. Get all venues owned by this user
        const venues = await Venue.findAll({
            where: { ownerId },
            attributes: ['id', 'name']
        });

        if (!venues.length) {
            return res.json([]);
        }

        const venueIds = venues.map(v => v.id);
        const venueMap = venues.reduce((acc, v) => {
            acc[v.id] = v.name;
            return acc;
        }, {});

        // 2. Get all confirmed bookings for these venues
        const bookings = await Booking.findAll({
            where: {
                venueId: venueIds,
                status: 'confirmed'
            },
            attributes: ['venueId', 'bookingDate', 'timeSlot', 'totalAmount']
        });

        // 3. Aggregate data: Group by date, then venue -> [slots]
        const reports = {}; // date -> venueId -> { venueName, totalSlotsBooked, revenue }

        bookings.forEach(b => {
            const date = b.bookingDate;
            const vId = b.venueId;
            const slotsCount = b.timeSlot ? b.timeSlot.split(',').length : 0;
            const revenue = parseFloat(b.totalAmount) || 0;

            if (!reports[date]) {
                reports[date] = {};
            }

            if (!reports[date][vId]) {
                reports[date][vId] = {
                    venueName: venueMap[vId],
                    totalSlotsBooked: 0,
                    revenue: 0
                };
            }

            reports[date][vId].totalSlotsBooked += slotsCount;
            reports[date][vId].revenue += revenue;
        });

        // Format for frontend
        const formattedReports = [];
        Object.keys(reports).sort().forEach(date => {
            const dateData = { date, venues: [] };
            Object.keys(reports[date]).forEach(vId => {
                dateData.venues.push(reports[date][vId]);
            });
            formattedReports.push(dateData);
        });

        res.json(formattedReports);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
