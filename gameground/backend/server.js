const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const db = require('./src/models');
const authRoutes = require('./src/routes/authRoutes');
const venueRoutes = require('./src/routes/venueRoutes');
const bookingRoutes = require('./src/routes/bookingRoutes');
const paymentRoutes = require('./src/routes/paymentRoutes');
const adminRoutes = require('./src/routes/adminRoutes');
const notificationRoutes = require('./src/routes/notificationRoutes');
const coachingRoutes = require('./src/routes/coachingRoutes');
const coachingPaymentRoutes = require('./src/routes/coachingPaymentRoutes');
const subscriptionRoutes = require('./src/routes/subscriptionRoutes');
const { initCron } = require('./src/services/subscriptionCron');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;



// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const path = require('path');
const fs = require('fs');

if (!fs.existsSync('uploads')) {
    fs.mkdirSync('uploads');
}

// Routes
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/api/auth', authRoutes);
app.use('/api/venues', venueRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/coaching', coachingRoutes);
app.use('/api/coaching-payments', coachingPaymentRoutes);
app.use('/api/subscriptions', subscriptionRoutes);

app.get('/', (req, res) => {
    res.send('Venue Booking API is running...');
});

// Database Sync & Server Start
db.sequelize.sync()
    .then(async () => {
        console.log('Database connected & synced.');

        // Auto-run schema updates for existing tables
        try {
            await db.sequelize.query("ALTER TABLE `Payments` MODIFY COLUMN `paymentMethod` VARCHAR(255) NOT NULL;", { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Payments` DROP COLUMN `updatedAt`;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Users` DROP COLUMN `updatedAt`;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Bookings` DROP COLUMN `updatedAt`;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Venues` DROP COLUMN `updatedAt`;', { logging: false }).catch(() => { });

            // Automatic Schema Updates
            await db.sequelize.query('ALTER TABLE `Venues` ADD COLUMN `imageUrls` JSON;', { logging: false }).catch(() => { });

            // Drop password reset columns since they are no longer used
            await db.sequelize.query('ALTER TABLE `Users` DROP COLUMN `resetPasswordOtp`;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Users` DROP COLUMN `resetPasswordExpires`;', { logging: false }).catch(() => { });

            // Reset AUTO_INCREMENT counters to 1 for all tables
            // This ensures if tables are emptied, exactly next ID will be 1
            await db.sequelize.query('ALTER TABLE `Users` AUTO_INCREMENT = 1;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Venues` AUTO_INCREMENT = 1;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Bookings` AUTO_INCREMENT = 1;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Payments` AUTO_INCREMENT = 1;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `Coachings` AUTO_INCREMENT = 1;', { logging: false }).catch(() => { });
            await db.sequelize.query('ALTER TABLE `CoachingPayments` AUTO_INCREMENT = 1;', { logging: false }).catch(() => { });
        } catch (e) {
            console.log('Migration check completed.');
        }

        initCron();

        app.listen(PORT, '0.0.0.0', () => {
            console.log(`Server running on port ${PORT} at 0.0.0.0`);
        });
    })
    .catch((err) => {
        console.error('Failed to sync database:', err.message);
    });
