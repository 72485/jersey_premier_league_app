# Jersey Premier League Backend

Express.js backend for the Jersey Premier League Flutter application with PostgreSQL database, JWT authentication, and FPL API integration.

## Project Structure

```
server/
├── src/
│   ├── config/
│   │   ├── database.js       # PostgreSQL connection pool
│   │   └── email.js          # Email configuration (Nodemailer)
│   ├── models/
│   │   ├── User.js           # User database operations
│   │   └── Announcement.js   # Announcement database operations
│   ├── routes/
│   │   ├── auth.js           # Authentication endpoints
│   │   ├── profile.js        # Profile management endpoints
│   │   ├── admin.js          # Admin endpoints
│   │   └── fpl.js            # FPL integration endpoints
│   ├── controllers/
│   │   ├── authController.js      # Auth business logic
│   │   ├── profileController.js   # Profile business logic
│   │   ├── adminController.js     # Admin business logic
│   │   └── fplController.js       # FPL integration logic
│   ├── middleware/
│   │   ├── authenticateToken.js   # JWT token verification
│   │   ├── adminCheck.js          # Admin authorization
│   │   └── errorHandler.js        # Error handling
│   ├── utils/
│   │   ├── validators.js     # Input validation using Joi
│   │   ├── tokenService.js   # JWT and token generation
│   │   └── fplService.js     # FPL API wrapper with caching
│   └── server.js             # Express app entry point
├── migrations/
│   └── init.sql              # Database schema initialization
├── package.json
├── .env.example              # Environment variables template
└── .gitignore

```

## Setup Instructions

### Prerequisites

- Node.js >= 16.0.0
- npm >= 8.0.0
- PostgreSQL database (use NeonDB for hosted solution)

### 1. Install Dependencies

```bash
cd server
npm install
```

### 2. Set Up Environment Variables

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

**Required variables:**
- `DATABASE_URL` - PostgreSQL connection string from NeonDB
- `JWT_SECRET` - Secret key for JWT signing (generate a random string)
- `EMAIL_FROM` - Email address for sending verification emails
- `EMAIL_APP_PASSWORD` - Gmail app-specific password (if using Gmail)
- `GOOGLE_CLIENT_ID` - Google OAuth client ID (for Google auth)
- `FRONTEND_URL` - Frontend app URL (for email verification links)

### 3. Initialize Database

Run the migration script to create all tables:

```bash
psql $DATABASE_URL < migrations/init.sql
```

Or use a PostgreSQL client to execute the SQL in `migrations/init.sql`.

### 4. Run Server Locally

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

Server will start on `http://localhost:5000`

## API Endpoints

### Authentication (`/api`)

- **POST** `/register` - Register new user
  ```json
  { "email": "user@example.com", "password": "password123", "name": "User Name" }
  ```

- **POST** `/login` - Login user
  ```json
  { "email": "user@example.com", "password": "password123" }
  ```

- **POST** `/email/verify` - Verify email with token
  ```json
  { "token": "verification_token_here" }
  ```

- **POST** `/auth/google` - Google OAuth login
  ```json
  { "googleIdToken": "google_token", "name": "User Name" }
  ```

### Profile Management (`/api/profile`)
*Requires authentication*

- **POST** `/update` - Update user profile
  ```json
  { "name": "New Name", "fplTeamID": "12345" }
  ```

- **POST** `/password/change` - Change password
  ```json
  { "currentPassword": "old_pass", "newPassword": "new_pass" }
  ```

### Admin (`/api/admin`)
*Requires authentication and admin status*

- **GET** `/verify` - Check if user is admin

- **POST** `/announcements` - Create announcement
  ```json
  { "title": "Announcement Title", "content": "Announcement content" }
  ```

- **GET** `/announcements` - Get all active announcements

- **PUT** `/announcements/:id` - Update announcement
  ```json
  { "title": "New Title", "content": "New content", "is_active": true }
  ```

- **DELETE** `/announcements/:id` - Deactivate announcement

### FPL Integration (`/api/fpl`)

- **GET** `/bootstrap-static` - Get teams, players, gameweeks, phases

- **GET** `/fixtures` - Get all Premier League fixtures

- **GET** `/fixtures/:gameweek` - Get fixtures for specific gameweek

- **GET** `/league/classic/:leagueId` - Get classic league standings

- **GET** `/league/h2h/:leagueId` - Get H2H league standings

- **GET** `/league/h2h/:leagueId/:gameweek` - Get H2H matches for gameweek

- **GET** `/cache/stats` - Get FPL cache statistics

- **POST** `/cache/clear` - Clear all FPL cache

## Database Schema

### Users Table
- `id` - Primary key
- `email` - Unique email address
- `password_hash` - Bcrypt hashed password
- `name` - User full name
- `fpl_team_id` - Unique FPL team ID
- `is_email_verified` - Email verification status
- `verification_token` - Token for email verification
- `verification_token_expires` - Token expiry timestamp
- `created_at` - Account creation timestamp
- `updated_at` - Last update timestamp
- `deleted_at` - Soft delete timestamp

### Announcements Table
- `id` - Primary key
- `title` - Announcement title
- `content` - Announcement content
- `created_by` - User ID of creator
- `created_at` - Creation timestamp
- `is_active` - Active status

## Caching Strategy

FPL API calls are cached using Node-cache:
- **Bootstrap static**: 6 hours (changes rarely)
- **Fixtures**: 30 minutes (updates frequently)
- **League standings**: 10 minutes
- **H2H matches**: 10 minutes

Clear cache via `POST /api/fpl/cache/clear` endpoint.

## Deployment to Render

### 1. Create Render Web Service

1. Go to [render.com](https://render.com)
2. Create new Web Service
3. Connect your GitHub repository
4. Configure:
   - **Build Command**: `cd server && npm install`
   - **Start Command**: `cd server && npm start`
   - **Node Environment**: Set to `production`

### 2. Set Environment Variables

Add these in Render dashboard:
- `DATABASE_URL` - Copy from NeonDB
- `JWT_SECRET` - Use a strong random string
- `EMAIL_FROM`, `EMAIL_APP_PASSWORD` - Email configuration
- `GOOGLE_CLIENT_ID` - Google OAuth ID
- `FRONTEND_URL` - Your Flutter app URL (or web preview)
- `ADMIN_EMAILS` - Comma-separated admin emails

### 3. Deploy

Push to main branch - Render will automatically deploy.

### 4. Update Frontend

Update the API base URL in your Flutter app to the Render URL:
```
https://your-app.onrender.com/api
```

## Testing

Run tests (when Jest is configured):
```bash
npm test
npm run test:watch
```

## Error Handling

All errors return consistent JSON format:
```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE",
  "statusCode": 400
}
```

Common error codes:
- `VALIDATION_ERROR` - Input validation failed
- `EMAIL_EXISTS` - Email already registered
- `INVALID_CREDENTIALS` - Wrong email/password
- `EMAIL_NOT_VERIFIED` - Email verification required
- `FPL_TEAM_ID_EXISTS` - FPL Team ID already taken
- `INVALID_TOKEN` - JWT token invalid or expired
- `NOT_ADMIN` - Admin access required
- `NOT_FOUND` - Resource not found

## Security Features

- **CORS** - Configurable origin validation
- **Helmet** - Secure HTTP headers
- **JWT** - Secure token-based authentication
- **Bcrypt** - Password hashing with salt
- **Input Validation** - Joi schema validation
- **SQL Injection Prevention** - Parameterized queries
- **Admin Whitelist** - Role-based access control

## Troubleshooting

### Database Connection Issues
- Verify `DATABASE_URL` is correct
- Check NeonDB connection pooling is enabled
- Ensure database tables are initialized with migration script

### Email Verification Not Working
- Verify Gmail app password (not regular password)
- Check email is configured correctly in `.env`
- Check logs for SMTP errors

### FPL API Errors
- FPL API has rate limits - cache helps reduce calls
- Check internet connection
- Verify FPL API is accessible

## License

MIT

## Support

For issues or questions, check the main project repository.
