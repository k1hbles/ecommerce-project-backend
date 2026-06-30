const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const pool = require('./database');

// Middleware
app.use(cors());

// Routers
const listingRouter = require("./routes/listings");
const userRouter = require("./routes/users");
const cartRouter = require("./routes/cart");
const orderRouter = require("./routes/orders");
const checkoutRouter = require("./routes/checkout");
const stripeRouter = require("./routes/stripe");

// Register routers
app.use("/api/listings", [express.json()], listingRouter);
app.use("/api/users", [express.json()], userRouter);
app.use("/api/cart", [express.json()], cartRouter);
app.use("/api/orders", [express.json()], orderRouter);
app.use("/api/checkout", [express.json()], checkoutRouter);
app.use("/api/stripe", stripeRouter);

// Routes
app.get('/', (req, res) => {
    res.json ({ message: "Welcome to the API"});
})

// Start the server
const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Server is running on port ${PORT}`);
    })
