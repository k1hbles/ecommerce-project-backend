# Stayfinder — Book Unique Places to Stay

> A full‑stack stays marketplace where guests browse unique homes, filter by style and price,
> book dates, pay securely with Stripe, and review their stays.

**Live demo:** Deployed on Render — `https://YOUR-APP.onrender.com` <!-- replace with your live Render URL -->
**Repositories:** Backend — `github.com/k1hbles/ecommerce-project-backend` · Frontend — `github.com/k1hbles/ecommerce_project_frontend`

---

## 1. Project Summary
Stayfinder is a short‑stay booking platform (an Airbnb‑style marketplace) built for a specific
domain: **holiday accommodation**. Instead of a general store, it sells *stays* — each listing has
domain‑specific data such as **price per night**, **check‑in / check‑out dates**, **guest count**,
**amenities**, and **location‑themed categories** (Beachfront, Cabins, City, Countryside, Luxury).

**Why it exists / goals**
- Give travellers one clean place to discover and book unique homes.
- Give the platform owner a working online‑payment shop with orders and reviews.
- Demonstrate a three‑tier full‑stack build: a RESTful Express API + a React single‑page app.

**Target users:** leisure travellers looking for a distinctive place to stay, and the host/owner
who manages listings and receives paid bookings.

---

## 2. UX / UI

### User stories & acceptance criteria
| # | As a… | I want to… | Acceptance criteria |
|---|---|---|---|
| 1 | visitor | browse all stays | Home page lists every listing with photo, title, price |
| 2 | visitor | filter stays | Choosing a category / typing a search / setting a max price updates the results |
| 3 | visitor | view a stay | Detail page shows description, amenities, reviews, and a booking form |
| 4 | visitor | create an account | Register form validates input and creates a user; I can then log in |
| 5 | user | log in / out | Valid credentials return a token and the navbar shows Cart/Trips/Logout |
| 6 | user | book a stay | I pick dates + guests, it's added to my cart with the nightly total |
| 7 | user | pay | Checkout redirects me to Stripe; a successful test payment creates my order |
| 8 | user | see my trips | The Trips page lists my bookings with a payment status (pending → paid) |
| 9 | user | review a stay | I submit a rating + comment and it appears immediately on the listing |

### Wireframes / mockups
No formal wireframes were produced — the interface was designed **iteratively with AI assistance**,
using Airbnb's live UI as a visual reference. Screenshots of the running pages (Home, Listing
detail, Cart, Checkout, Trips) serve as the mockups; add them to a `/docs` folder to include here.

### Five Planes of UX
- **Strategy** — help travellers find and book a distinctive stay; give the owner a paid‑orders shop.
- **Scope** — browse/filter listings, view details, cart, Stripe checkout, order history, reviews.
- **Structure** — flat, shallow navigation: Explore → Listing → Cart → Checkout → Trips. Protected
  actions (cart, checkout, trips, reviews) require a JWT.
- **Skeleton** — Airbnb‑style layout: a search "pill", a scrollable category strip, a responsive
  card grid, and a two‑column detail page (content + sticky booking card).
- **Surface** — coral accent (`#ff385c`, "Rausch"), **Plus Jakarta Sans** typography, Bootstrap 5
  for structure, real Unsplash photography, subtle card hover/scale, and a floating flash‑message
  system for feedback.

---

## 3. Features
- **Authentication** — register (bcrypt‑hashed passwords) and login (JWT). A JWT middleware
  protects cart, checkout, orders and review endpoints.
- **Listings + filtering** — `GET /api/listings` builds a parameterised SQL query, adding
  `category` / `search (LIKE)` / `maxPrice` clauses only when provided (safe from SQL injection
  via `?` placeholders).
- **Listing detail** — composes one listing with its amenities (M:N join) and reviews in the
  service layer before returning it.
- **Cart** — add a booking (listing + dates + guests), remove, and a running total computed from
  `nights × price_per_night` (`DATEDIFF`).
- **Checkout + Stripe** — creates orders + pending payments in one DB transaction, opens a Stripe
  Checkout Session, and redirects the browser to it.
- **Stripe webhook** — verifies the signature and flips the matching payments to `paid` on
  `checkout.session.completed`.
- **Trips / orders** — lists a user's bookings joined to listings + payment status.
- **Reviews** — logged‑in users submit a star rating + comment; shown on the listing.

**Known limitations / pending**
- Payments show `pending` until the Stripe CLI webhook (`stripe listen`) is running.
- No admin dashboard for product CRUD yet (listings are seeded via SQL).
- Not deployed to a public host yet (runs locally / on Codespaces).

---

## 4. Technologies Used
| Tech | Where it's used | Link |
|---|---|---|
| **Express 5** | REST API, routing, middleware | https://github.com/expressjs/express |
| **mysql2/promise** | MariaDB access in the data layer | https://github.com/sidorares/node-mysql2 |
| **bcrypt** | password hashing | https://github.com/kelektiv/node.bcrypt.js |
| **jsonwebtoken** | JWT auth | https://github.com/auth0/node-jsonwebtoken |
| **Stripe** | checkout + webhook | https://github.com/stripe/stripe-node |
| **cors / dotenv** | CORS + env config | https://github.com/expressjs/cors |
| **React (Vite)** | single‑page frontend | https://github.com/vitejs/vite |
| **wouter** | client‑side routing | https://github.com/molefrog/wouter |
| **Jotai** | state (JWT, cart, flash) | https://github.com/pmndrs/jotai |
| **Formik + Yup** | forms + validation | https://github.com/jaredpalmer/formik |
| **axios** | HTTP requests | https://github.com/axios/axios |
| **Bootstrap 5** | styling/layout | https://github.com/twbs/bootstrap |

---

## 5. Architecture & Database

**Three‑tier backend:** `routes` (HTTP) → `services` (business logic) → `data` (SQL only).

**Tables & relationships**
- `users` 1—M `orders`, `cartLists`, `reviews`
- `listings` 1—M `cartLists`, `orders`, `reviews`, `categories`
- `listings` M—N `amenities` (via `amenities_lists`)
- `orders` 1—1 `payments`

**Added beyond the ER diagram:** `users.password`, `listings.imageUrl`, `orders.userId`,
`reviews.rating`, `reviews.comment` (rest matches the diagram).

**API Reference** — 🔒 = requires `Authorization: Bearer <token>`
| Method | Endpoint | Auth | Body / Query |
|---|---|---|---|
| POST | `/api/users` | — | `{ fullName, email, password, salutation, country }` |
| POST | `/api/users/login` | — | `{ email, password }` |
| GET | `/api/listings` | — | `?category=&search=&maxPrice=` |
| GET | `/api/listings/:id` | — | — |
| POST | `/api/listings/:id/reviews` | 🔒 | `{ rating, comment }` |
| GET | `/api/cart` | 🔒 | — |
| POST | `/api/cart` | 🔒 | `{ listingId, checkIn, checkOut, guests }` |
| DELETE | `/api/cart/:cartId` | 🔒 | — |
| POST | `/api/checkout` | 🔒 | — |
| GET | `/api/orders` | 🔒 | — |
| POST | `/api/stripe/webhook` | signature | raw Stripe event |

---

## 6. Setup Instructions
**Prerequisites:** Node.js 18+, MariaDB/MySQL, (optional) Stripe CLI.

**1. Database**
```bash
mysql -u root -p < data.sql
mysql -u root -p airbnb < sample.sql
```
**2. Backend** (`.env` below)
```bash
cd backend && npm install && npm start        # http://localhost:3000
```
```
DB_HOST=127.0.0.1
DB_USER=root
DB_PASSWORD=yourpassword
DB_NAME=airbnb
PORT=3000
JWT_SECRET=change_me
FRONTEND_URL=http://localhost:5173
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```
**3. Frontend**
```bash
cd airbnb-ecom && npm install && npm run dev   # http://localhost:5173
# airbnb-ecom/.env:  VITE_API_URL=http://localhost:3000   (no trailing slash, no /api)
```
**4. Stripe (test mode)**
```bash
stripe login
stripe listen --forward-to localhost:3000/api/stripe/webhook
# put the whsec_... into STRIPE_WEBHOOK_SECRET, restart backend
```
**Troubleshooting:** blank listings → check `VITE_API_URL` (no trailing slash) and that the
backend port is reachable; "pending" orders → make sure `stripe listen` is running.

---

## 7. Testing (manual test cases)
**Demo login:** `liam@example.com` / `password123`

| # | Description | Steps | Expected result |
|---|---|---|---|
| 1 | Login (valid) | Login → enter demo email/password → submit | Redirected home; navbar shows Cart/Trips/Logout |
| 2 | Login (invalid) | Login → correct email, wrong password → submit | Red flash "Invalid email or password" |
| 3 | Register | Register → fill all fields → submit | "Account created" flash, redirected to /login |
| 4 | Filter listings | Home → click "Luxury" | Only luxury stays shown; Luxury tab active |
| 5 | Search + price | Home → type a place, set max price → 🔍 | Results narrowed to matches under the price |
| 6 | Add to cart | Listing → pick dates + guests → Add to cart | "Added to your cart"; item appears in Cart with total |
| 7 | Checkout | Cart → Checkout → pay `4242 4242 4242 4242` | Redirected to Stripe; order created |
| 8 | Trips | Trips page | Booking listed with payment status |
| 9 | Review | Listing (logged in) → rating + comment → Post | Review appears immediately with ★ rating |

> No console errors or unhandled exceptions during the above flows.

---

## 8. Deployment
- **Hosting:** [Render](https://render.com) — the Express API runs as a **Web Service**; the React
  frontend as a **Static Site** (build with `npm run build`, publish `dist/`).
- **Database:** hosted MariaDB/MySQL (e.g. Railway or Aiven); the API connects via the `DB_*` env vars.
- **Environment variables:** see the `.env` list in §6 — DB credentials, `JWT_SECRET`, `FRONTEND_URL`
  (the deployed frontend URL, used for Stripe redirects), and the Stripe keys. **None are committed —
  `.env` is gitignored.**
- **Dependencies:** listed in each repo's `package.json`.
- **Steps:** (1) create the hosted DB and load `data.sql` + `sample.sql`; (2) deploy the API on
  Render, setting the env vars above; (3) deploy the frontend on Render as a static site with
  `VITE_API_URL` pointing at the deployed API URL.

---

## 9. Credits
- **Images:** [Unsplash](https://unsplash.com) (listing photos, hot‑linked with `?w=` sizing).
- **UI:** [Bootstrap 5](https://getbootstrap.com), [Plus Jakarta Sans](https://fonts.google.com/specimen/Plus+Jakarta+Sans).
- **Payments:** [Stripe](https://stripe.com) test mode.
- **Learning reference / conventions:** course tutor materials (`mysql-react`, `rocket01-ecommerce`).
- **Author:** Hanz Lesmana
