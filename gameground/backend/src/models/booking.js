module.exports = (sequelize, DataTypes) => {
    const Booking = sequelize.define('Booking', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        bookingDate: {
            type: DataTypes.DATEONLY,
            allowNull: false,
        },
        timeSlot: {
            type: DataTypes.STRING, // e.g., "18:00-19:00"
            allowNull: false,
        },
        status: {
            type: DataTypes.ENUM('pending', 'confirmed', 'cancelled'),
            defaultValue: 'pending',
        },
        totalAmount: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        }
    }, {
        timestamps: true,
        updatedAt: false
    });

    return Booking;
};
