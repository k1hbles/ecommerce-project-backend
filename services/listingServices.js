const listingData = require("../data/listingData");

async function getAllListings(filters) {
    return await listingData.getAllListings(filters);
}

async function getListingById(listingId) {
    const listing = await listingData.getListingById(listingId);
    if (!listing) {
        throw new Error("Listing not found");
    }

    listing.amenities = await listingData.getAmenitiesByListingId(listingId);
    listing.reviews = await listingData.getReviewsByListingId(listingId);
    return listing;
}

async function addReview(listingId, userId, orderId) {
    return await listingData.createReview(listingId, userId, orderId || null);
}

module.exports = {
    getAllListings,
    getListingById,
    addReview
}