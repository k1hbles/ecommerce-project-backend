const userData = require("../data/userData");
const bcrypt = require("bcrypt");

async function registerUser(fullName, email, password, salutation, country) {
    // make sure the email has not been used
    const existingUser = await userData.getUserByEmail(email);
    if (existingUser) {
        throw new Error("Email is already registered");
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    return await userData.createUser(fullName, email, hashedPassword, salutation, country);
}

async function loginUser(email, password) {
    const user = await userData.getUserByEmail(email);
    if (!user) {
        throw new Error("Invalid email or password");
    }

    // check password against the stored hash
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        throw new Error("Invalid email or password");
    }
    return user;
}

async function getUserDetailsById(userId) {
    return await userData.getUserById(userId);
}

module.exports = {
    registerUser,
    loginUser,
    getUserDetailsById
}