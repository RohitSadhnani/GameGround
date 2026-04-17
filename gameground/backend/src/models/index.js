const Sequelize = require('sequelize');
const sequelize = require('../config/database');

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

// Import Models
db.User = require('./user')(sequelize, Sequelize);
db.Venue = require('./venue')(sequelize, Sequelize);
db.Booking = require('./booking')(sequelize, Sequelize);
db.Payment = require('./payment')(sequelize, Sequelize);
db.Notification = require('./notification')(sequelize, Sequelize);
db.Coaching = require('./coaching')(sequelize, Sequelize);
db.CoachingPayment = require('./coachingPayment')(sequelize, Sequelize);
db.Subscription = require('./subscription')(sequelize, Sequelize);
db.SubscriptionPlan = require('./subscriptionPlan')(sequelize, Sequelize);

// Relationships
db.Venue.hasMany(db.Booking, { foreignKey: 'venueId' });
db.Booking.belongsTo(db.Venue, { foreignKey: 'venueId' });

db.User.hasMany(db.Booking, { foreignKey: 'userId' });
db.Booking.belongsTo(db.User, { foreignKey: 'userId' });

db.Booking.hasMany(db.Payment, { foreignKey: 'bookingId' });
db.Payment.belongsTo(db.Booking, { foreignKey: 'bookingId' });

db.User.hasMany(db.Venue, { foreignKey: 'ownerId' });
db.Venue.belongsTo(db.User, { foreignKey: 'ownerId' });

db.User.hasMany(db.Payment, { foreignKey: 'userId' });
db.Payment.belongsTo(db.User, { foreignKey: 'userId' });

db.User.hasMany(db.Notification, { foreignKey: 'userId' });
db.Notification.belongsTo(db.User, { foreignKey: 'userId' });

db.User.hasMany(db.Coaching, { foreignKey: 'ownerId' });
db.Coaching.belongsTo(db.User, { foreignKey: 'ownerId' });

db.Coaching.hasMany(db.CoachingPayment, { foreignKey: 'coachingId' });
db.CoachingPayment.belongsTo(db.Coaching, { foreignKey: 'coachingId' });

db.User.hasMany(db.CoachingPayment, { foreignKey: 'playerId' });
db.CoachingPayment.belongsTo(db.User, { foreignKey: 'playerId' });

db.User.hasMany(db.Subscription, { foreignKey: 'userId' });
db.Subscription.belongsTo(db.User, { foreignKey: 'userId' });

module.exports = db;
