const paymentData = require("../data/paymentData");

async function updateSessionForOrders(orderIds, sessionId) {
    return await paymentData.updateSessionForOrders(orderIds, sessionId);
}

async function updateStatusBySession(sessionId, status) {
    return await paymentData.updateStatusBySession(sessionId, status);
}

module.exports = {
    updateSessionForOrders,
    updateStatusBySession
}