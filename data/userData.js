const pool = require("../database");

async function getUserByEmail(email) {
    const [rows] = await pool.execute(
        "SELECT * FROM users WHERE email = ?",
        [email]
    );
    return rows[0];
}

async function getUserById(userId) {
    // leave passwors so we never send hash
    const [rows] = await pool.execute(
        "SELECT userId, fullName, email, salutation, country FROM users WHERE userId = ?",
        [userId]
    )
    return rows[0];
}   

// return the id to user
async function createUser(fullName, email, password, salutation, country) {
    const [result] = await pool.execute(
        "INSERT into users (fullName, email, password, salutation, country) VALUES (?, ?, ?, ?, ?)",
        [fullName, email, password, salutation, country]
    );
    return result.insertId;
}

module.exports = {
    getUserByEmail,
    getUserById,
    createUser
};