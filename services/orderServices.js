const orderData = require("../data/orderData");

async function getOrders(userId) {
    return await orderData.getOrdersByUserId(userId);
}

module.exports = {
    getOrders
};