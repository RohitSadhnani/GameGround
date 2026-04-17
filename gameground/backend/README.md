# Venue Booking Backend

This is the Node.js/Express backend for the Venue Booking App.

## Prerequisites
- **Node.js** (v18+)
- **MySQL** Database

## Setup

1.  **Install Dependencies**
    ```bash
    cd backend
    npm install
    ```

2.  **Environment Variables**
    Create a `.env` file in the `backend` root:
    ```env
    PORT=5000
    DB_HOST=localhost
    DB_USER=root
    DB_PASS=your_password
    DB_NAME=venue_booking
    JWT_SECRET=your_secret_key
    ```

3.  **Run Server**
    ```bash
    npm start
    # or for development
    npm run dev
    ```

## API Endpoints

### Auth
- `POST /api/auth/login` - Request OTP
- `POST /api/auth/verify-otp` - Verify OTP & Get Token

### Venues
- `GET /api/venues` - List all venues
- `POST /api/venues` - Create a venue
- `GET /api/venues/:id` - Get details

### Bookings
- `POST /api/bookings` - Create a booking
- `GET /api/bookings/user/:userId` - Get user history
