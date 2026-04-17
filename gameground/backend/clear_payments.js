const db = require('./src/models');

async function clearPayments() {
    try {
        await db.sequelize.authenticate();
        console.log('Connection has been established successfully.');
        await db.Payment.destroy({
            where: {},
            truncate: true
        });
        console.log('Payments table cleared successfully.');
    } catch (error) {
        console.error('Unable to connect to the database or clear table:', error);
    } finally {
        await db.sequelize.close();
    }
}

clearPayments();
