const express = require("express");
const router = express.Router();
const jwt = require("jsonwebtoken");

const userServices = require("../services/userServices");
const AuthenticateWithJWT = require("../middlewares/AuthenticationWithJWT");

// POST register a new user
router.post("/", async function (req, res) {
    try {
        const userId = await userServices.registerUser(
            req.body.fullName,
            req.body.email,
            req.body.password,
            req.body.salutation,
            req.body.country
        );
        res.status(201).json({
            message: "User registered successfully",
            userId
        });
    } catch (e) {
        console.error(e);
        res.status(400).json({ error: e.message });
    }
});

// POST login a user, returns JWT & userId
router.post("/login", async function(req, res) {
    try {
        const { email, password } = req.body;
        const user = await userServices.loginUser(email, password);

        const token = jwt.sign(
            { userId: user.userId },
            process.env.JWT_SECRET,
            { expriresIn: "2w"}
        );

        res.json({ message: "Login successful", token });
    } catch (e) {
        console.error(e);
        res.status(400).json({ error: e.message });
    }
});

module.exports = router;