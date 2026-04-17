const db = require('../models');
const User = db.User;
const Venue = db.Venue;
const Booking = db.Booking;
const Coaching = db.Coaching;
const CoachingPayment = db.CoachingPayment;
const Subscription = db.Subscription;
const { Op } = require('sequelize');

exports.getDashboardStats = async (req, res) => {
    try {
        const totalPlayers = await User.count({ where: { role: 'user' } });
        const totalVenueOwners = await User.count({ where: { role: 'venue_owner' } });
        const totalVenues = await Venue.count();
        const totalVenueBookings = await Booking.count();
        const totalCoachingBookings = await CoachingPayment.count();

        // Subscription Stats
        const totalSubscriptionRevenue = await Subscription.sum('amount', { where: { paymentStatus: 'completed' } }) || 0;
        const activeSubscriptions = await Subscription.count({ where: { isActive: true } });
        const nearingExpiryCount = await Subscription.count({
            where: {
                isActive: true,
                endDate: {
                    [Op.lte]: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
                }
            }
        });

        res.json({
            totalPlayers,
            totalVenueOwners,
            totalVenues,
            totalVenueBookings,
            totalCoachingBookings,
            totalSubscriptionRevenue,
            activeSubscriptions,
            nearingExpiryCount
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getOwnersList = async (req, res) => {
    try {
        const owners = await User.findAll({
            where: { role: 'venue_owner' },
            attributes: ['id', 'username', 'email']
        });
        res.json(owners);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getOwnerStats = async (req, res) => {
    try {
        const ownerId = req.params.ownerId;
        
        const owner = await User.findOne({ where: { id: ownerId, role: 'venue_owner' } });
        if (!owner) return res.status(404).json({ message: 'Owner not found' });

        const totalVenues = await Venue.count({ where: { ownerId } });

        const venues = await Venue.findAll({ where: { ownerId }, attributes: ['id'] });
        const venueIds = venues.map(v => v.id);
        const totalVenueBookings = await Booking.count({ where: { venueId: venueIds } });

        const coachings = await Coaching.findAll({ where: { ownerId }, attributes: ['id'] });
        const coachingIds = coachings.map(c => c.id);
        const totalCoachingBookings = await CoachingPayment.count({ where: { coachingId: coachingIds } });

        res.json({
            ownerId: parseInt(ownerId),
            username: owner.username,
            totalVenues,
            totalVenueBookings,
            totalCoachingBookings
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.exportBookingsCSV = async (req, res) => {
    try {
        // Fetch all bookings with associated User and Venue details
        const bookings = await Booking.findAll({
            include: [
                { model: User, attributes: ['username', 'email'] },
                { model: Venue, attributes: ['name', 'location'] }
            ],
            order: [['bookingDate', 'DESC']]
        });

        const coachingPayments = await CoachingPayment.findAll({
            include: [
                { model: User, attributes: ['username', 'email'] },
                { model: Coaching, attributes: ['name', 'durationMonths'] }
            ],
            order: [['createdAt', 'DESC']]
        });

        // Set Headers for file download
        res.setHeader('Content-Type', 'text/csv');
        res.setHeader('Content-Disposition', 'attachment; filename=financial_report.csv');

        // Write CSV Header
        res.write('Type,ID,Date,Time Slot / Duration,Status,Amount,Player Name,Player Email,Venue / Coaching Name,Location\n');

        const escapeCSV = (str) => {
            if (str === null || str === undefined) return '"N/A"';
            return `"${String(str).replace(/"/g, '""')}"`;
        };

        const formatDate = (dateValue) => {
            if (!dateValue) return '"N/A"';
            try {
                return `"${new Date(dateValue).toISOString().split('T')[0]}"`;
            } catch (e) {
                return '"Invalid Date"';
            }
        };

        // Write data rows for venue bookings
        for (const b of bookings) {
            const row = [
                '"Venue Booking"',
                b.id,
                formatDate(b.bookingDate),
                escapeCSV(b.timeSlot),
                escapeCSV(b.status),
                b.totalAmount,
                escapeCSV(b.User?.username),
                escapeCSV(b.User?.email),
                escapeCSV(b.Venue?.name),
                escapeCSV(b.Venue?.location)
            ].join(',');
            res.write(row + '\n');
        }

        // Write data rows for coaching registrations
        for (const cp of coachingPayments) {
            const row = [
                '"Coaching Registration"',
                cp.id,
                formatDate(cp.createdAt),
                escapeCSV(cp.Coaching?.durationMonths ? cp.Coaching.durationMonths + ' months' : 'N/A'),
                escapeCSV(cp.paymentStatus),
                cp.amount,
                escapeCSV(cp.User?.username),
                escapeCSV(cp.User?.email),
                escapeCSV(cp.Coaching?.name),
                '"N/A"' // Location not strictly tracked for coaching in this model format
            ].join(',');
            res.write(row + '\n');
        }

        res.end();
    } catch (error) {
        console.error("Export Error:", error);
        // If we encounter an error but already started writing headers, we can't send JSON anymore.
        // But since this is a download endpoint, if headers weren't sent yet, we can try to send error status.
        if (!res.headersSent) {
            res.status(500).json({ message: 'Error generating report' });
        } else {
            res.end();
        }
    }
};

exports.getExpiringSubscriptions = async (req, res) => {
    try {
        const expiringSubscribers = await Subscription.findAll({
            where: {
                isActive: true,
                endDate: {
                    [Op.lte]: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
                }
            },
            include: [{
                model: db.User,
                attributes: ['username', 'email']
            }],
            order: [['endDate', 'ASC']]
        });
        res.json(expiringSubscribers);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ===== Subscription Plan Management =====
const SubscriptionPlan = db.SubscriptionPlan;

exports.getPlans = async (req, res) => {
    try {
        const plans = await SubscriptionPlan.findAll({ order: [['durationMonths', 'ASC']] });
        res.json(plans);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.createPlan = async (req, res) => {
    try {
        const { name, price, durationMonths, features, badgeText, isPopular } = req.body;
        const plan = await SubscriptionPlan.create({
            name: name || 'New Plan',
            price: price || 0,
            durationMonths: durationMonths || 1,
            features: features || [],
            badgeText: badgeText || null,
            isPopular: isPopular || false,
        });
        res.status(201).json({ message: 'Plan created successfully', plan });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.updatePlan = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, price, durationMonths, features, badgeText, isPopular } = req.body;
        const plan = await SubscriptionPlan.findByPk(id);
        if (!plan) return res.status(404).json({ message: 'Plan not found' });

        await plan.update({
            name: name ?? plan.name,
            price: price ?? plan.price,
            durationMonths: durationMonths ?? plan.durationMonths,
            features: features ?? plan.features,
            badgeText: badgeText ?? plan.badgeText,
            isPopular: isPopular ?? plan.isPopular,
        });
        res.json({ message: 'Plan updated successfully', plan });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.deletePlan = async (req, res) => {
    try {
        const { id } = req.params;
        const plan = await SubscriptionPlan.findByPk(id);
        if (!plan) return res.status(404).json({ message: 'Plan not found' });

        await plan.update({ isActive: false });
        res.json({ message: 'Plan deactivated successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
