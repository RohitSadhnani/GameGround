const db = require('../models');
const CoachingPayment = db.CoachingPayment;
const Coaching = db.Coaching;
const User = db.User;
const Notification = db.Notification;

exports.createPayment = async (req, res) => {
    try {
        const { coachingId, amount, paymentMethod } = req.body;
        const playerId = req.user.id;

        const coaching = await Coaching.findByPk(coachingId);
        if (!coaching) {
            return res.status(404).json({ message: 'Coaching session not found' });
        }

        const payment = await CoachingPayment.create({
            playerId,
            coachingId,
            amount,
            paymentMethod: paymentMethod || 'Cash',
            paymentStatus: 'completed'
        });

        const player = await User.findByPk(playerId);

        if (player && coaching) {
            const userName = player.username;
            const coachingName = coaching.name;

            // Notify Player
            await Notification.create({
                userId: playerId,
                title: "Coaching Registration Confirmed!",
                message: `Hey ${userName}, your registration for the coaching session '${coachingName}' is confirmed. Amount: ₹${amount} (${paymentMethod || 'Cash'}).`,
            });

            // Notify Coach (Owner)
            if (coaching.ownerId) {
                const ownerMessage = `${userName} has registered for your coaching session '${coachingName}'. Amount: ₹${amount} (${paymentMethod || 'Cash'}).`;
                await Notification.create({
                    userId: coaching.ownerId,
                    title: "New Student Registered!",
                    message: ownerMessage,
                });
            }
        }

        res.status(201).json(payment);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getMyPayments = async (req, res) => {
    try {
        const playerId = req.user.id;
        const payments = await CoachingPayment.findAll({
            where: { playerId },
            include: [{ model: Coaching }]
        });
        res.json(payments);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getCoachingPayments = async (req, res) => {
    try {
        const { coachingId } = req.params;
        const ownerId = req.user.id;

        const coaching = await Coaching.findOne({ where: { id: coachingId, ownerId } });
        if (!coaching) {
            return res.status(404).json({ message: 'Coaching not found or unauthorized' });
        }

        const payments = await CoachingPayment.findAll({
            where: { coachingId },
            include: [{ model: User, attributes: ['id', 'name', 'email', 'phoneNumber'] }]
        });

        res.json(payments);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
