module.exports = (sequelize, DataTypes) => {
    const Coaching = sequelize.define('Coaching', {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        name: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        pic: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        mobileNo: {
            type: DataTypes.STRING,
            allowNull: false,
        },
        durationMonths: {
            type: DataTypes.INTEGER,
            allowNull: false,
        },
        pricePerMonth: {
            type: DataTypes.DECIMAL(10, 2),
            allowNull: false,
        },
        ownerId: {
            type: DataTypes.INTEGER,
            allowNull: false,
        }
    }, {
        timestamps: true,
        updatedAt: false
    });

    return Coaching;
};
