const pool = require("../database");

async function updateSessionForOrders(orderIds, sessionId) {
    for (const orderId of orderIds) {
        await pool.execute(
            "UPDATE payments SET stripe_checkout_session = ? WHERE orderId = ?",
            [sessionId, orderId]
        );
    }
}

// webhook calls with paid
async function updateStatusBySession(sessionId, status) {
    await pool.execute(
        "UPDATE payments SET status = ? WHERE stripe_checkout_session = ?",
        [status, sessionId]
    );
}

module.exports = {
    updateSessionForOrders,
    updateStatusBySession
};