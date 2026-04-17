const db = require('../models');
const Subscription = db.Subscription;
const SubscriptionPlan = db.SubscriptionPlan;
const User = db.User;

exports.getActivePlans = async (req, res) => {
    try {
        const plans = await SubscriptionPlan.findAll({
            where: { isActive: true },
            order: [['durationMonths', 'ASC']],
        });
        res.json(plans);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.purchaseSubscription = async (req, res) => {
    try {
        const { planName, amount, paymentMethod, durationMonths } = req.body;
        const userId = req.user.id;

        // Check for existing active subscription to extend it
        const existingSub = await Subscription.findOne({
            where: { userId, isActive: true, paymentStatus: 'completed' },
            order: [['endDate', 'DESC']]
        });

        let startDate = new Date();
        let endDate = new Date();
        const months = durationMonths || (planName.includes('Year') ? 12 : planName.includes('6 Month') ? 6 : 1);

        if (existingSub && existingSub.endDate > startDate) {
            // Extend from existing expiry
            startDate = new Date(existingSub.endDate);
            endDate = new Date(existingSub.endDate);
        }
        
        endDate.setMonth(endDate.getMonth() + months);

        const subscription = await Subscription.create({
            userId,
            planName,
            amount: amount || 0,
            startDate,
            endDate,
            paymentMethod: paymentMethod || 'Cash',
            paymentStatus: 'completed',
            isActive: true
        });

        // Ensure user role is venue_owner
        await User.update({ role: 'venue_owner' }, { where: { id: userId } });

        res.status(201).json({ message: 'Subscription purchased successfully', subscription });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getMySubscription = async (req, res) => {
    try {
        const userId = req.user.id;
        const subscription = await Subscription.findOne({
            where: { userId, paymentStatus: 'completed', isActive: true },
            order: [['endDate', 'DESC']]
        });
        
        res.json(subscription || { message: 'No active subscription found' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};
