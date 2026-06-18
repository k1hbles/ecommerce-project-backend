const pool = require("../database");

// filters
async function getAllListings(filter = {}) {
  let sql = `
        SELECT
            listings.listingId,
            listings.title,
            listings.description,
            CAST(listings.price_per_night AS DOUBLE) AS price_per_night,
            listings.imageUrl
        FROM listings`;
    const params = [];

    if (filter.category) {
        sql += " JOIN categories ON categories.listingId = listings.listingId";
    }

    sql += " WHERE 1 = 1";

    if (filter.category) {
        sql += " AND categories.category = ?";
        params.push(filters.category);
    }
    if (filter.search) {
        sql += " AND listings.title LIKE ?";
        params.push(`%${filters.search}%`);
    }
    if (filter.maxPrice) {
        sql += " AND listings.price_per_night <= ?";
        params.push(filters.maxPrice);
    }

    sql += " ORDER BY listings.listingId";

    const [rows] = await pool.execute(sql, params);
    return rows;
}

async function getListingById(listingId) {
    const [rows] = await pool.execute(
        ` SELECT
            listingId,
            title,
            description,
            CAST(price_per_night AS DOUBLE) AS price_per_night,
            imageUrl
        FROM listings
        WHERE listingId = ?`,
        [listingId]
    );
    return rows[0];
}

async function getAmenitiesByListingId(listingId) {
    const [rows] = await pool.execute(
        ` SELECT amenities.amenitiesId, amenities.amenitie_name
        FROM amenities_lists
        JOIN amenities ON amenities_lists.amenitiesId = amenities.amenitiesId
        WHERE amenities_lists.listingId = ?`,
        [listingId]
    );
    return rows;
}

async function getReviewsByListingId(listingId) {
    const [rows] = await pool.execute(
        ` SELECT reviews.reviewId, reviews.orderId, users.fullName
        FROM reviews
        JOIN users ON reviews.userId = users.userId
        WHERE reviews.listingId = ?
        ORDER BY reviews.reviewId DESC`,
        [listingId]
    );
    return rows;
}

async function createReview(listingId, userId, orderId) {
    const [ result] = await pool.execute(
        "INSERT INTO reviews (listingId, userId, orderId) VALUES (?, ?, ?)",
        [listingId, userId, orderId]
    );
    return result.insertId
}

module.exports = {
    getAllListings,
    getListingById,
    getAmenitiesByListingId,
    getReviewsByListingId,
    createReview
}