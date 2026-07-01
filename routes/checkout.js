const express = require("express");
const router = express.Router();

const checkoutServices = require("../services/checkoutServices") ;
const AuthenticateWithJWT = require("../middlewares/AuthenticationWithJWT");

// POST checkout
router.post("/", AuthenticateWithJWT, async function (req, res){
    try {
        const results = await checkoutServices.checkout(req.userId);
        res.json(results);
    } catch (e) {
        console.error(e);
        res.status(400).json({ error: e.message })
    }
});

module.exports = router;