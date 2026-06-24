const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

function createLineItems(cartItems) {
    const lineItems = [];
    for (let item of cartItems) {
        const lineItem = {
            price_data: {
                currency: 'sgd',
                unit_amount: Math.round(item.nights * item.price_per_night * 100),
                product_data: {
                    name: item.title,
                    images: [item.imageUrl || 'https://via.placeholder.com/150'],
                    metadata: {
                        listingId: item.listingId
                    }
                }
            },
            quantity: 1
        }
        lineItems.push(lineItem);
    }

    return lineItems;
}

async function createCheckoutSession(userId, orderItems, orderId) {
    // 1. line items
    const lineItems = createLineItems(orderItems);
    // 2. create the checkout session
    const session = await stripe.checkout.sessions.create({
        payment_method_types:['card'], 
        line_items: lineItems,
        mode: "payment",
        success_url: `${process.env.FRONTEND_URL}/orders?success=1`,
        cancel_url: `${process.env.FRONTEND_URL}/cart?canceled=1`,
        metadata: {
            userId: userId,
        }
    });
    return session;
}

module.exports = {
    createCheckoutSession
}