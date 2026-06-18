const express = require("express");
const router = express.Router();

const cartServices = require("../services/cartServices");
const AuthenticateWithJWT = require("../middlewares/AuthenticationWithJWT");

// GET users cart
router.get("/", AuthenticateWithJWT, async function (req, res) {
    try {
        const cart = await cartServices.getCart(req.userId);
        res.json({ cart });
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: e.message });
    }
})

// POST add a booking to cart
router.post("/", AuthenticateWithJWT, async function (req, res) {
    try {
        const cartId = await cartServices.addToCart(
            req.userId,
            req.body.listingId,
            req.body.checkIn,
            req.body.checkOut,
            req.body.guests
        ); res.status(201).json({ message: "Added to cart", cartId });
    } catch (e) {
        console.error(e);
        res.status(400).json({ error: e.message });
    }
});

// DELETE remove a booking from the cart
router.delete("/:cartId", AuthenticateWithJWT, async function (req, res) {
    try {
        await cartServices.removeFromCart(req.userId, req.params.cartId);
        res.json({ message: "Removed from cart"});
    } catch (e) {
        console.error(e);
        res.status(400).json({ error: e.message});
    }
});

module.exports = router;