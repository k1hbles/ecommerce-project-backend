const cartData = require("../data/cartData");
const orderData = require("../data/orderData");
const paymentServices = require("./paymentServices");
const stripeServices = require("./stripeServices");

async function checkout(userId) {
    // 1. read the user's cart
    const cartItems = await cartData.getCartByUser(userId);
    if (cartItems.length === 0) {
        throw new Error("Your cart is empty");
    }

    // 2. turn each cart row into an order
    const order = cartItems.map((item) => ({
        cartId: item.cartId,
        listingId: item.listingId,
        totalPrice: item.nights * item.price_per_night,
        checkIn: item.checkIn,
        checkOut: item.checkout
    }));

    // create orders + payments
    const orderId = await orderData.createOrdersWithPayments(userId, orders);

    // create stripe checkout session
    const session = await stripeServices.createCheckoutSession(userId, cartItems);

    // save the session id on payment rows
    await paymentServices.updateSessionForOrders(orderIds, session.id);

    // frontend redirect
    return { session };
}

module.exports = {
    checkout
};