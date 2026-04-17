const models = require('./src/models');

async function db() {
    try {
        await models.sequelize.authenticate();
        console.log('Connection has been established successfully.');

        await models.sequelize.query('DROP DATABASE IF EXISTS venue_booking;');
        await models.sequelize.query('CREATE DATABASE venue_booking;');
        await models.sequelize.query('USE venue_booking;');
        await models.sequelize.sync({ force: true });
        console.log('Database dropped, recreated, and tables synced.');
    } catch (error) {
        console.error('Unable to connect to the database or reset tables:', error);
    } finally {
        await models.sequelize.close();
    }
}

db();
