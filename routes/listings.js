const express = require('express');
const router = express.Router();

const listingServices = require("../services/listingServices");
const AuthenticateWithJWT = require("../middlewares/AuthenticationWithJWT");

// GET /api/listings 
router.get('/', async function (req, res) {
    try {
        const listings = await listingServices.getAllListings({
            category: req.query.category,
            search: req.query.search,
            maxPrice: req.query.maxPrice
        });
        res.json({ listings });
    } catch (e) {
        console.error(e);
        res.status(500).json({ error: e.messgae });
    }
})

// GET /api/listings/:id
router.post("/:id/reviews", AuthenticateWithJWT, async function (req, res) {
    try {
        const reviewId = await listingServices.addReview(
            req.params.id,
            req.userId,
            req.body.orderId
        );
        res.status(201).json({ message: "Review added", reviewId });
    } catch(e) {
        console.error(e);
        res.status(400).json({ error: e.message });
    }
})

module.exports = router;