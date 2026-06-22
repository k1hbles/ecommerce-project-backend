const pool = require("../database");

// user's order

async function getOrdersByUserId(userId) {
    const [rows] = await pool.execute(
    `SELECT
        orders.orderId,
        orders.listingId,
        CAST(orders.totalPrice AS DOUBLE) AS totalPrice,
        orders.checkIn,
        orders.checkOut,
        listings.title,
        listings.imageUrl,
        payments.status AS paymentStatus
    FROM orders
    JOIN listings ON orders.listingId = listings.listingId
    JOIN payments ON payments.orderId = orders.orderId
    WHERE orders.userId = ?
    ORDER BY orders.orderId DESC
    `,
    [userId]
    );
    return rows;
};

 // we make the orders, payments and clear the cart in a transaction
 async function createOrdersWithPayments(userId, orders) {
    const connection = await pool.getConnection();
    try {
        await connection.beginTransaction();

        const orderIds = [];
        // order row
        for (const order of orders) {
        const [orderResult] = await connection.execute(
            "INSERT INTO orders (userId, cartId, listingId, totalPrice, checkIn, checkOut) VALUES (?, ?, ?, ?, ?, ?)",
            [userId, order.cartId, order.listingId, order.totalPrice, order.checkIn, order.checkOut]
        );
        const orderId = orderResult.insertId;
        orderIds.push(orderId);
        // payment row per order
        await connection.execute(
            "INSERT INTO payments (orderId, stripe_checkout_session, status) VALUES (?, ?, ?)",
            [orderId, null, "pending"]
        );
    }
    // clear user's cart now that it is in orders
    await connection.execute("DELETE FROM cartLists WHERE userId = ?", [userId]);

    await connection.commit();
    return orderIds;

} catch(e) {
    await connection.rollback();
    throw e;
    } finally {
        connection.release();
    }
 }

 module.exports = {
    getOrdersByUserId,
    createOrdersWithPayments
 };