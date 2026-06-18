const cartData = require("../data/cartData");

async function getCart(userId) {
    return await cartData.getCartByUser(userId);
}

async function addToCart(userId, listingId, checkIn, checkOut, guests) {
    if (!listingId || !checkIn || !checkOut) {
        throw new Error("listingId, checkIn, checkOut are required");
    }
    if (new Date(checkOut) <= new Date(checkIn)) {
        throw new Error("checkOut must be after checkIn");
    }
    return await cartData.addToCart(userId, listingId, checkIn, checkOut, guests || 1);
}

async function removeFromCart(userId, cartId) {
    await cartData.removeFromCart(userId, cartId);
}

module.exports = {
    getCart,
    addToCart,
    removeFromCart
};