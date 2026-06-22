const express = require("express");
const router = express.Router();

const orderServices = require("../services/orderServices");
const AuthenticateWithJWT = require("../middlewares/AuthenticationWithJWT");

// GET the logged user's orders with payment
router.get("/", AuthenticateWithJWT, async function (req, res) {
    try {
        const orders = await orderServices.getOrders(req.userId);
        res.json({ orders });
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: e.message });
    }
});

module.exports = router;