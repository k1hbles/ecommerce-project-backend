-- =============================================================
-- Airbnb-style schema (MySQL 8.0+, InnoDB)
-- Generated from ER diagram. Notes on corrections:
--   * All FK columns are UNSIGNED to match the UNSIGNED PKs
--     (mismatched signedness makes MySQL reject the FK).
--   * listings.title treated as a normal column, not an FK.
--   * DEMICAL -> DECIMAL.
--   * amenities.listingsId kept but nullable: it is redundant
--     with the amenities_lists junction. Prefer the junction.
--   * reviews.rating / reviews.comment added (diagram was cut off).
-- =============================================================

DROP DATABASE IF EXISTS airbnb;
CREATE DATABASE airbnb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airbnb;

-- ---------- core tables (no dependencies) ----------

CREATE TABLE users (
    userId INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    fullName VARCHAR(255),
    email VARCHAR(255),
    salutation  VARCHAR(100),
    country     VARCHAR(150),
    PRIMARY KEY (userId),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE listings (
    listingId       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    price_per_night DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (listingId)
) ENGINE=InnoDB;

-- ---------- tables that depend on the above ----------

CREATE TABLE cartLists (
    cartId      INT UNSIGNED NOT NULL AUTO_INCREMENT,
    userId      INT UNSIGNED NOT NULL,
    listingId   INT UNSIGNED NOT NULL,
    checkIn     DATETIME,
    checkOut    DATETIME,
    guests      INT,
    PRIMARY KEY (cartId),
    KEY idx_cart_user (userId),
    KEY idx_cart_listing (listingId),
    CONSTRAINT fk_cart_user
        FOREIGN KEY (userId) REFERENCES users (userId)
        ON DELETE CASCADE,
    CONSTRAINT fk_cart_listing
        FOREIGN KEY (listingId) REFERENCES listings (listingId)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE orders (
    orderId     INT UNSIGNED NOT NULL AUTO_INCREMENT,
    cartId      INT UNSIGNED,
    listingId   INT UNSIGNED NOT NULL,
    totalPrice  DECIMAL(10,2) NOT NULL,
    checkIn     DATETIME,
    checkOut    DATETIME,
    PRIMARY KEY (orderId),
    KEY idx_order_cart (cartId),
    KEY idx_order_listing (listingId),
    CONSTRAINT fk_order_cart
        FOREIGN KEY (cartId) REFERENCES cartLists (cartId)
        ON DELETE SET NULL,
    CONSTRAINT fk_order_listing
        FOREIGN KEY (listingId) REFERENCES listings (listingId)
) ENGINE=InnoDB;

CREATE TABLE payments (
    paymentId               INT UNSIGNED NOT NULL AUTO_INCREMENT,
    orderId                 INT UNSIGNED NOT NULL,
    stripe_checkout_session VARCHAR(255),
    status                  VARCHAR(50),
    PRIMARY KEY (paymentId),
    KEY idx_payment_order (orderId),
    CONSTRAINT fk_payment_order
        FOREIGN KEY (orderId) REFERENCES orders (orderId)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE amenities (
    amenitiesId    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    listingsId     INT UNSIGNED NULL,            -- redundant w/ junction; nullable
    amenitie_name  VARCHAR(255) NOT NULL,
    PRIMARY KEY (amenitiesId),
    KEY idx_amenity_listing (listingsId),
    CONSTRAINT fk_amenity_listing
        FOREIGN KEY (listingsId) REFERENCES listings (listingId)
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- M:N junction between listings and amenities
CREATE TABLE amenities_lists (
    listingId    INT UNSIGNED NOT NULL,
    amenitiesId  INT UNSIGNED NOT NULL,
    PRIMARY KEY (listingId, amenitiesId),
    KEY idx_al_amenity (amenitiesId),
    CONSTRAINT fk_al_listing
        FOREIGN KEY (listingId) REFERENCES listings (listingId)
        ON DELETE CASCADE,
    CONSTRAINT fk_al_amenity
        FOREIGN KEY (amenitiesId) REFERENCES amenities (amenitiesId)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE reviews (
    reviewId    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    listingId   INT UNSIGNED NOT NULL,
    userId      INT UNSIGNED NOT NULL,
    orderId     INT UNSIGNED,
    rating      TINYINT UNSIGNED,                -- added (diagram cut off)
    comment     TEXT,                            -- added (diagram cut off)
    PRIMARY KEY (reviewId),
    KEY idx_review_listing (listingId),
    KEY idx_review_user (userId),
    KEY idx_review_order (orderId),
    CONSTRAINT fk_review_listing
        FOREIGN KEY (listingId) REFERENCES listings (listingId)
        ON DELETE CASCADE,
    CONSTRAINT fk_review_user
        FOREIGN KEY (userId) REFERENCES users (userId)
        ON DELETE CASCADE,
    CONSTRAINT fk_review_order
        FOREIGN KEY (orderId) REFERENCES orders (orderId)
        ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE categories (
    categoryId  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    listingId   INT UNSIGNED NOT NULL,
    category    INT,                             -- as drawn (e.g. 1=Entire home, 2=Private room)
    PRIMARY KEY (categoryId),
    KEY idx_category_listing (listingId),
    CONSTRAINT fk_category_listing
        FOREIGN KEY (listingId) REFERENCES listings (listingId)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================================
-- Test data
-- =============================================================

INSERT INTO users (userId, fullName, email, salutation, country) VALUES
    (1, 'Liam O''Connor', 'liam@example.com',   'Mr',  'Ireland'),
    (2, 'Sophia Tan',     'sophia@example.com', 'Ms',  'Singapore'),
    (3, 'Noah Williams',  'noah@example.com',   'Mr',  'Australia'),
    (4, 'Emma Garcia',    'emma@example.com',   'Mrs', 'Spain'),
    (5, 'Arjun Patel',    'arjun@example.com',  'Mr',  'India'),
    (6, 'Mei Lin',        'mei@example.com',    'Ms',  'Malaysia');

INSERT INTO listings (listingId, title, description, price_per_night) VALUES
    (1, 'Beachfront Villa in Bali',     'Private villa with infinity pool steps from the sand.', 250.00),
    (2, 'Cozy Studio in Singapore CBD', 'Compact modern studio walking distance to MRT.',         180.00),
    (3, 'Sydney Harbour Apartment',     'Two-bed apartment with views of the Opera House.',        320.00),
    (4, 'Mountain Cabin Retreat',       'Off-grid cabin with wood fireplace and forest trails.',   140.00),
    (5, 'Modern Loft in Barcelona',     'Industrial loft in the Gothic Quarter.',                  200.00),
    (6, 'Tokyo Micro Apartment',        'Efficient micro-unit near Shinjuku station.',              95.00);

INSERT INTO amenities (amenitiesId, listingsId, amenitie_name) VALUES
    (1, 1, 'WiFi'),
    (2, 1, 'Pool'),
    (3, 2, 'Air Conditioning'),
    (4, 3, 'Kitchen'),
    (5, 4, 'Free Parking'),
    (6, 5, 'Washer'),
    (7, 1, 'Hot Tub'),
    (8, 4, 'Pet Friendly');

-- which amenities each listing actually has (the correct M:N model)
INSERT INTO amenities_lists (listingId, amenitiesId) VALUES
    (1, 1), (1, 2), (1, 7),
    (2, 1), (2, 3),
    (3, 1), (3, 4),
    (4, 1), (4, 5), (4, 8),
    (5, 1), (5, 6),
    (6, 1), (6, 3);

INSERT INTO categories (categoryId, listingId, category) VALUES
    (1, 1, 1),   -- 1 = Entire home
    (2, 2, 2),   -- 2 = Private room
    (3, 3, 1),
    (4, 4, 1),
    (5, 5, 2),
    (6, 6, 2);

INSERT INTO cartLists (cartId, userId, listingId, checkIn, checkOut, guests) VALUES
    (1, 1, 1, '2026-07-10 15:00:00', '2026-07-14 11:00:00', 2),
    (2, 2, 3, '2026-08-01 15:00:00', '2026-08-05 11:00:00', 3),
    (3, 3, 4, '2026-09-12 15:00:00', '2026-09-15 11:00:00', 1),
    (4, 5, 5, '2026-10-20 15:00:00', '2026-10-23 11:00:00', 2);

INSERT INTO orders (orderId, cartId, listingId, totalPrice, checkIn, checkOut) VALUES
    (1, 1, 1, 1000.00, '2026-07-10 15:00:00', '2026-07-14 11:00:00'),  -- 4 nights @ 250
    (2, 2, 3, 1280.00, '2026-08-01 15:00:00', '2026-08-05 11:00:00'),  -- 4 nights @ 320
    (3, 3, 4,  420.00, '2026-09-12 15:00:00', '2026-09-15 11:00:00'),  -- 3 nights @ 140
    (4, 4, 5,  600.00, '2026-10-20 15:00:00', '2026-10-23 11:00:00');  -- 3 nights @ 200

INSERT INTO payments (paymentId, orderId, stripe_checkout_session, status) VALUES
    (1, 1, 'cs_test_a1b2c3d4e5', 'paid'),
    (2, 2, 'cs_test_f6g7h8i9j0', 'paid'),
    (3, 3, 'cs_test_k1l2m3n4o5', 'pending'),
    (4, 4, 'cs_test_p6q7r8s9t0', 'failed');

INSERT INTO reviews (reviewId, listingId, userId, orderId, rating, comment) VALUES
    (1, 1, 1, 1, 5, 'Incredible villa, the pool was the highlight.'),
    (2, 3, 2, 2, 4, 'Great views, a little noisy at night.'),
    (3, 4, 3, 3, 5, 'Perfect quiet getaway, loved the fireplace.'),
    (4, 5, 5, 4, 3, 'Good location but smaller than expected.');