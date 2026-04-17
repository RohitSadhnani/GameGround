module.exports = (sequelize, DataTypes) => {
    const Venue = sequelize.define('Venue', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        description: {
            type: DataTypes.TEXT,
            allowNull: true,
        },
        location: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        sportType: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        pricePerHour: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        facilities: {
            type: DataTypes.JSON,
            allowNull: true,
        },
        timings: {
            type: DataTypes.STRING,
            allowNull: true,
            defaultValue: "06:00 - 22:00"
        },
        availableSlots: {
            type: DataTypes.JSON,
            allowNull: true,
            defaultValue: ["06:00-07:00", "07:00-08:00", "18:00-19:00", "19:00-20:00"]
        },
        imageUrl: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        imageUrls: {
            type: DataTypes.JSON,
            allowNull: true,
        },
        phoneNumber: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        ownerId: {
            type: DataTypes.INTEGER,
            allowNull: true,
        }
    }, {
        timestamps: true,
        updatedAt: false
    });

    return Venue;
};
