module.exports = (sequelize, DataTypes) => {
    const CoachingPayment = sequelize.define('CoachingPayment', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        playerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        coachingId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        amount: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        paymentStatus: {
            type: DataTypes.STRING,
            defaultValue: 'completed'
        },
        paymentMethod: {
            type: DataTypes.STRING,
            allowNull: false,
            defaultValue: 'Cash'
        }
    }, {
        timestamps: true,
        updatedAt: false
    });

    return CoachingPayment;
};
