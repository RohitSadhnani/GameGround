const db = require('../models');
const Payment = db.Payment;
const Booking = db.Booking;
const User = db.User;
const Notification = db.Notification;

exports.payOnSpot = async (req, res) => {
    try {
        const { bookingId } = req.body;
        const userId = req.user.id;

        const booking = await Booking.findByPk(bookingId, {
            include: [{ model: db.Venue }, { model: db.User }]
        });

        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }

        if (booking.userId !== userId) {
            return res.status(403).json({ message: 'Unauthorized to pay for this booking' });
        }

        if (booking.status === 'confirmed') {
            return res.status(400).json({ message: 'Booking is already confirmed' });
        }

        const transactionId = `cash_${Date.now()}_${bookingId}`;
        // Store completed cash payment in DB
        await Payment.create({
            transactionId: transactionId,
            amount: booking.totalAmount,
            paymentMethod: 'cash',
            status: 'completed',
            bookingId: bookingId,
            userId: userId
        });

        booking.status = 'confirmed';
        await booking.save();

        // Create Notification
        if (booking.User && booking.Venue) {
            const userName = booking.User.username;
            const venueName = booking.Venue.name;
            const price = booking.totalAmount;
            const timeSlot = booking.timeSlot || 'Check Booking Details';

            // Generate a random 4-digit OTP
            const otpCode = Math.floor(1000 + Math.random() * 9000);

            const title = "Booking Confirmed!";
            // Notify Player
            const message = `Hey ${userName}, your booking at ${venueName} for ${timeSlot} is confirmed. Amount: ₹${price} (cash). Your entry OTP is: ${otpCode}.`;

            await Notification.create({
                userId: userId,
                title: title,
                message: message,
            });

            // Notify Venue Owner
            if (booking.Venue.ownerId) {
                const ownerMessage = `${userName} has booked ${venueName} for ${timeSlot}. Amount: ₹${price} (cash). Their entry OTP is: ${otpCode}.`;
                await Notification.create({
                    userId: booking.Venue.ownerId,
                    title: "New Booking Received!",
                    message: ownerMessage,
                });
            }
        }

        res.json({ message: "Booking confirmed with pay on spot" });
    } catch (error) {
        console.error('Error processing cash payment:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};

exports.payWithUpi = async (req, res) => {
    try {
        const { bookingId, upiId, pin } = req.body;
        const userId = req.user.id;

        if (!upiId || !pin) {
            return res.status(400).json({ message: 'UPI ID and PIN are required' });
        }

        const booking = await Booking.findByPk(bookingId, {
            include: [{ model: db.Venue }, { model: db.User }]
        });

        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }

        if (booking.userId !== userId) {
            return res.status(403).json({ message: 'Unauthorized to pay for this booking' });
        }

        if (booking.status === 'confirmed') {
            return res.status(400).json({ message: 'Booking is already confirmed' });
        }

        const transactionId = `upi_${Date.now()}_${bookingId}`;
        // Store completed upi payment in DB
        await Payment.create({
            transactionId: transactionId,
            amount: booking.totalAmount,
            paymentMethod: 'UPI',
            status: 'completed',
            bookingId: bookingId,
            userId: userId
        });

        booking.status = 'confirmed';
        await booking.save();

        // Create Notification
        if (booking.User && booking.Venue) {
            const userName = booking.User.username;
            const venueName = booking.Venue.name;
            const price = booking.totalAmount;
            const timeSlot = booking.timeSlot || 'Check Booking Details';

            // Generate a random 4-digit OTP
            const otpCode = Math.floor(1000 + Math.random() * 9000);

            const title = "Booking Confirmed!";
            // Notify Player
            const message = `Hey ${userName}, your booking at ${venueName} for ${timeSlot} is confirmed. Amount: ₹${price} (UPI). Your entry OTP is: ${otpCode}.`;

            await Notification.create({
                userId: userId,
                title: title,
                message: message,
            });

            // Notify Venue Owner
            if (booking.Venue.ownerId) {
                const ownerMessage = `${userName} has booked ${venueName} for ${timeSlot}. Amount: ₹${price} (UPI). Their entry OTP is: ${otpCode}.`;
                await Notification.create({
                    userId: booking.Venue.ownerId,
                    title: "New Booking Received!",
                    message: ownerMessage,
                });
            }
        }

        res.json({ message: "Booking confirmed with UPI payment" });
    } catch (error) {
        console.error('Error processing upi payment:', error);
        res.status(500).json({ message: 'Internal Server Error' });
    }
};

exports.getPaymentByBookingId = async (req, res) => {
    try {
        const { bookingId } = req.params;
        const payments = await Payment.findAll({ where: { bookingId } });
        res.json(payments);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
