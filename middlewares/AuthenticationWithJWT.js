const jwt = require("jsonwebtoken");

function AuthenticateWithJWT(req, res, next) {
    const authHeader = req.headers.authorization;


    if (!authHeader || !authHeader.startsWith("Bearer")) {
    return res.status(401).json({
        error: "Authorization header not found or Bearer not found"
    });
    }

    const token = authHeader.split(" ")[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.userId = decoded.userId; 
        next();
    } catch (error) {
        console.error(error);
        return res.status(401).json({
        error: error.message
        });
    }
}


module.exports = AuthenticateWithJWT;