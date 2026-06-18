-- =============================================================
-- Airbnb-style seed data
-- Every demo user's password is:  password123
-- (stored as a real bcrypt hash, so /login actually works)
--
-- Requires two columns that the original schema didn't have:
--   ALTER TABLE users    ADD COLUMN password VARCHAR(255) NOT NULL AFTER email;
--   ALTER TABLE listings ADD COLUMN imageUrl VARCHAR(255)          AFTER description;
-- =============================================================
USE airbnb;

-- wipe in FK-safe order so this file is re-runnable
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE reviews;
TRUNCATE TABLE payments;
TRUNCATE TABLE orders;
TRUNCATE TABLE cartLists;
TRUNCATE TABLE amenities_lists;
TRUNCATE TABLE amenities;
TRUNCATE TABLE categories;
TRUNCATE TABLE listings;
TRUNCATE TABLE users;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------- users ----------
INSERT INTO users (userId, fullName, email, password, salutation, country) VALUES
  (1, 'Liam O''Connor', 'liam@example.com',   '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Mr',  'Ireland'),
  (2, 'Sophia Tan',     'sophia@example.com', '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Ms',  'Singapore'),
  (3, 'Noah Williams',  'noah@example.com',   '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Mr',  'Australia'),
  (4, 'Emma Garcia',    'emma@example.com',   '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Mrs', 'Spain'),
  (5, 'Arjun Patel',    'arjun@example.com',  '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Mr',  'India'),
  (6, 'Mei Lin',        'mei@example.com',    '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Ms',  'Malaysia'),
  (7, 'Daniel Cohen',   'daniel@example.com', '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Mr',  'Israel'),
  (8, 'Yuki Tanaka',    'yuki@example.com',   '$2b$10$3TurT8sadH7j6Ukm2d5xdOytYw3Vgz35efSiAE3dpMMDMUrloAc9e', 'Ms',  'Japan');

-- ---------- listings ----------
INSERT INTO listings (listingId, title, description, imageUrl, price_per_night) VALUES
  (1, 'Beachfront Villa in Bali',     'Private villa with infinity pool steps from the sand.',   'https://picsum.photos/id/1018/600/400', 250.00),
  (2, 'Cozy Studio in Singapore CBD', 'Compact modern studio walking distance to MRT.',          'https://picsum.photos/id/1062/600/400', 180.00),
  (3, 'Sydney Harbour Apartment',     'Two-bed apartment with views of the Opera House.',        'https://picsum.photos/id/1067/600/400', 320.00),
  (4, 'Mountain Cabin Retreat',       'Off-grid cabin with wood fireplace and forest trails.',   'https://picsum.photos/id/1043/600/400', 140.00),
  (5, 'Modern Loft in Barcelona',     'Industrial loft in the Gothic Quarter.',                  'https://picsum.photos/id/1074/600/400', 200.00),
  (6, 'Tokyo Micro Apartment',        'Efficient micro-unit near Shinjuku station.',             'https://picsum.photos/id/1031/600/400',  95.00),
  (7, 'Kyoto Machiya Townhouse',      'Restored wooden townhouse with a private garden.',        'https://picsum.photos/id/1015/600/400', 160.00),
  (8, 'Lisbon Tile Apartment',        'Bright apartment with classic azulejo tilework.',         'https://picsum.photos/id/1024/600/400', 130.00);

-- ---------- categories (1 = Entire home, 2 = Private room) ----------
INSERT INTO categories (categoryId, listingId, category) VALUES
  (1, 1, 1), (2, 2, 2), (3, 3, 1), (4, 4, 1),
  (5, 5, 2), (6, 6, 2), (7, 7, 1), (8, 8, 1);

-- ---------- amenities (master list) ----------
INSERT INTO amenities (amenitiesId, listingsId, amenitie_name) VALUES
  (1, NULL, 'WiFi'),
  (2, NULL, 'Pool'),
  (3, NULL, 'Air Conditioning'),
  (4, NULL, 'Kitchen'),
  (5, NULL, 'Free Parking'),
  (6, NULL, 'Washer'),
  (7, NULL, 'Hot Tub'),
  (8, NULL, 'Pet Friendly'),
  (9, NULL, 'Heating'),
  (10, NULL, 'Workspace');

-- ---------- amenities_lists (which listing has which amenity) ----------
INSERT INTO amenities_lists (listingId, amenitiesId) VALUES
  (1, 1), (1, 2), (1, 7), (1, 3),
  (2, 1), (2, 3), (2, 10),
  (3, 1), (3, 4), (3, 6),
  (4, 1), (4, 5), (4, 8), (4, 9),
  (5, 1), (5, 6), (5, 10),
  (6, 1), (6, 3),
  (7, 1), (7, 4), (7, 9),
  (8, 1), (8, 4), (8, 6);

-- ---------- cartLists (staged bookings, not yet checked out) ----------
INSERT INTO cartLists (cartId, userId, listingId, checkIn, checkOut, guests) VALUES
  (1, 1, 1, '2026-07-10 15:00:00', '2026-07-14 11:00:00', 2),
  (2, 2, 3, '2026-08-01 15:00:00', '2026-08-05 11:00:00', 3),
  (3, 3, 4, '2026-09-12 15:00:00', '2026-09-15 11:00:00', 1),
  (4, 5, 5, '2026-10-20 15:00:00', '2026-10-23 11:00:00', 2),
  (5, 7, 7, '2026-11-01 15:00:00', '2026-11-05 11:00:00', 4),
  (6, 8, 2, '2026-12-02 15:00:00', '2026-12-06 11:00:00', 1);

-- ---------- orders (checked-out bookings; total = nights * price) ----------
INSERT INTO orders (orderId, cartId, listingId, totalPrice, checkIn, checkOut) VALUES
  (1, 1, 1, 1000.00, '2026-07-10 15:00:00', '2026-07-14 11:00:00'),  -- 4 x 250
  (2, 2, 3, 1280.00, '2026-08-01 15:00:00', '2026-08-05 11:00:00'),  -- 4 x 320
  (3, 3, 4,  420.00, '2026-09-12 15:00:00', '2026-09-15 11:00:00'),  -- 3 x 140
  (4, 4, 5,  600.00, '2026-10-20 15:00:00', '2026-10-23 11:00:00'),  -- 3 x 200
  (5, 5, 7,  640.00, '2026-11-01 15:00:00', '2026-11-05 11:00:00');  -- 4 x 160

-- ---------- payments (1:1 with orders) ----------
INSERT INTO payments (paymentId, orderId, stripe_checkout_session, status) VALUES
  (1, 1, 'cs_test_a1b2c3d4e5', 'paid'),
  (2, 2, 'cs_test_f6g7h8i9j0', 'paid'),
  (3, 3, 'cs_test_k1l2m3n4o5', 'pending'),
  (4, 4, 'cs_test_p6q7r8s9t0', 'failed'),
  (5, 5, 'cs_test_u1v2w3x4y5', 'paid');

-- ---------- reviews (only for stays that were paid) ----------
INSERT INTO reviews (reviewId, listingId, userId, orderId, rating, comment) VALUES
  (1, 1, 1, 1, 5, 'Incredible villa, the infinity pool was the highlight.'),
  (2, 3, 2, 2, 4, 'Great harbour views, a little noisy at night.'),
  (3, 7, 7, 5, 5, 'The garden and woodwork made it feel magical.'),
  (4, 1, 4, NULL, 4, 'Stunning location, would happily return.');