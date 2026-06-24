const express = require("express");
const stripe = require("stripe")(process.env.STRIPE_SECRET_KEY);
const router = express.Router();

const paymentServices = require("../services/paymentServices");

// stripe webhook
router.post("/webhook", express.raw({ type: "application/json" }), async (req, res) => {
    let event = null;
    try {
        // verify webhook signature
        const sig = req.headers["stripe-signature"];
        event = stripe.webhookEndpoints.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    } catch (e) {
        console.error(e);
        return res.status(400).json({ error: e.message });
    }

    if (event.type === "checkout.session.completed") {
        const session = event.data.object;
        await paymentServices.updateStatusBySession(session.id, "paid");
    }
    res.json({ received: true });
})

module.exports = router;
