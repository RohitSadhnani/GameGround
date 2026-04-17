const db = require('../models');
const { Op } = require('sequelize');
const Subscription = db.Subscription;
const User = db.User;

const checkExpirations = async () => {
    try {
        console.log('Running subscription expiration check...');
        const now = new Date();

        const expiredSubscriptions = await Subscription.findAll({
            where: {
                isActive: true,
                endDate: {
                    [Op.lt]: now
                }
            }
        });

        for (const sub of expiredSubscriptions) {
            sub.isActive = false;
            await sub.save();

            // Check if user has any other active subscriptions
            const activeSub = await Subscription.findOne({
                where: {
                    userId: sub.userId,
                    isActive: true,
                    endDate: {
                        [Op.gt]: now
                    }
                }
            });

            if (!activeSub) {
                // Downgrade user
                await User.update({ role: 'user' }, { where: { id: sub.userId } });
                console.log(`Downgraded user ${sub.userId} to 'user' role due to subscription expiry.`);
            }
        }
    } catch (error) {
        console.error('Error during subscription expiration check:', error);
    }
};

const initCron = () => {
    // Run immediately on startup
    checkExpirations();
    
    // Then run every 24 hours (24 * 60 * 60 * 1000 ms)
    setInterval(checkExpirations, 24 * 60 * 60 * 1000);
};

module.exports = { initCron, checkExpirations };
