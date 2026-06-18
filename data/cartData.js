const pool = require("../database");

async function getCartByUser(userId) {
    const [rows] = await pool.execute(
        `SELECT
            cartLists.cartId,
            cartLists.listingId,
            cartLists.checkIn,
            cartLists.checkOut,
            cartLists.guests,
            listings.title,
            listings.imageUrl,
            CAST(listings.price_per_night AS DOUBLE) AS price_per_night,
            DATEDIFF(cartLists.checkOut, cartLists.checkIn) AS nights
        FROM cartLists
        JOIN listings ON cartLists.listingId = listings.listingId
        WHERE cartLists.userId = ?
        ORDER BY cartLists.cartId`,
        [userId]
    );
    return rows;
}

async function addToCart(userId, listingId, checkIn, checkOut, guests) {
    const [result] = await pool.execute(
        "INSERT INTO cartLists (userId, listingId, checkIn, checkOut, guests) VALUES (?, ?, ?, ?, ?)",
        [userId, listingId, checkIn, checkOut, guests]
    );
    return result.insertId;
}

async function removeFromCart(userId, cartId) {
    await pool.execute(
        "DELETE FROM cartLists WHERE cartId = ? AND userId = ?",
        [cartId, userId]
    );
}

module.exports = {
    getCartByUser,
    addToCart,
    removeFromCart
};