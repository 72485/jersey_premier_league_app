# Jersey Premier League Backend - Setup Guide

A complete step-by-step guide to set up, configure, and deploy the backend.

## Phase 1: Local Development Setup

### Step 1: Install Dependencies

```bash
cd server
npm install
```

This will install all required packages:
- **express** - Web framework
- **pg** - PostgreSQL client
- **bcryptjs** - Password hashing
- **jsonwebtoken** - JWT token generation
- **nodemailer** - Email sending
- **axios** - HTTP client for FPL API
- **helmet** - Security middleware
- **cors** - Cross-origin requests
- **joi** - Input validation
- **node-cache** - In-memory caching
- **dotenv** - Environment variable management
- **nodemon** - Auto-reload for development

### Step 2: Configure Database (NeonDB)

1. **Create NeonDB Account**
   - Go to [neon.tech](https://neon.tech)
   - Sign up and create a new project
   - Select PostgreSQL version (latest)

2. **Get Connection String**
   - In Neon dashboard, click "Connection string"
   - Copy the PostgreSQL connection URL
   - Format: `postgresql://user:password@host:port/database`

3. **Create .env File**
   ```bash
   cp .env.example .env
   ```

4. **Update .env with Database**
   ```
   DATABASE_URL=postgresql://your_user:your_pass@host:5432/your_db
   DATABASE_POOL_SIZE=20
   ```

### Step 3: Initialize Database Schema

Run the migration script to create all tables:

**Option A: Using psql command**
```bash
psql $DATABASE_URL < migrations/init.sql
```

**Option B: Using DataGrip or pgAdmin**
- Copy contents of `migrations/init.sql`
- Execute in your database admin tool

**Verify** - Check that these tables exist:
- `users`
- `announcements`
- `admin_whitelist`
- `fpl_cache`

### Step 4: Configure Email

**For Gmail:**

1. **Enable 2-Factor Authentication** on your Google account
2. **Generate App Password**:
   - Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
   - Select "Mail" and "Windows Computer" (or your device)
   - Google will generate a 16-character password
   - Copy this password

3. **Update .env**:
   ```
   EMAIL_SERVICE=gmail
   EMAIL_FROM=your-email@gmail.com
   EMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx
   ```

**For Other Email Providers:**
- Update `EMAIL_SERVICE` in `.env`
- Configure SMTP settings if needed

### Step 5: Configure JWT

Generate a strong secret key (use an online generator or Node):

```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

Update .env:
```
JWT_SECRET=your_generated_secret_here
JWT_EXPIRES_IN=7d
```

### Step 6: Configure Google OAuth (Optional)

1. **Create Google Cloud Project**
   - Go to [console.cloud.google.com](https://console.cloud.google.com)
   - Create new project
   - Enable "Google+ API"

2. **Create OAuth 2.0 Credentials**
   - Go to Credentials
   - Create OAuth 2.0 Client ID
   - Select "Web application"
   - Add authorized JavaScript origins and redirect URIs

3. **Add to .env**:
   ```
   GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
   ```

### Step 7: Configure Frontend URL

Update .env with your frontend URL (for email verification links):
```
FRONTEND_URL=http://localhost:3000
# or for Flutter app
FRONTEND_URL=http://localhost:5000
```

### Step 8: Set Admin Emails

Update .env with your admin email addresses:
```
ADMIN_EMAILS=your-email@gmail.com,admin2@example.com
```

### Step 9: Run Server Locally

**Development mode (with auto-reload):**
```bash
npm run dev
```

**Expected output:**
```
Jersey Premier League API Server running on port 5000
Environment: development
Database pool connection established
```

**Test the server:**
```bash
curl http://localhost:5000/health
```

Expected response:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## Phase 2: Testing Locally

### Test Registration

```bash
curl -X POST http://localhost:5000/api/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

**Expected response** (201):
```json
{
  "success": true,
  "message": "User registered successfully. Please check your email to verify your account.",
  "data": {
    "id": 1,
    "email": "test@example.com"
  }
}
```

### Test Login

```bash
curl -X POST http://localhost:5000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

**Expected response** (200):
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "email": "test@example.com",
      "name": "Test User",
      "fpl_team_id": null,
      "is_email_verified": true
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Test FPL API Integration

```bash
curl http://localhost:5000/api/fpl/bootstrap-static
```

This should return FPL bootstrap data (cache will work if called multiple times).

## Phase 3: Deployment to Render

### Step 1: Prepare GitHub Repository

1. **Ensure your repo has**:
   - `server/package.json`
   - `server/src/server.js`
   - `server/.env.example` (without secrets)
   - `server/.gitignore` (excludes `.env`)

2. **Commit and push**:
   ```bash
   git add server/
   git commit -m "Add Node.js backend for Jersey Premier League"
   git push origin main
   ```

### Step 2: Create Render Web Service

1. **Go to [render.com](https://render.com)**
   - Sign up or log in
   - Click "New +" → "Web Service"

2. **Connect Repository**
   - Select your GitHub repository
   - Choose branch: `main`
   - Confirm

3. **Configure Service**
   - **Name**: `jpl-backend` (or similar)
   - **Environment**: `Node`
   - **Build Command**: `cd server && npm install`
   - **Start Command**: `cd server && npm start`
   - **Node Environment**: `production`

4. **Add Environment Variables**
   Click "Advanced" → "Add Environment Variable" for each:

   ```
   DATABASE_URL=postgresql://...       (from NeonDB)
   JWT_SECRET=your_secret_here          (generate new for production)
   EMAIL_FROM=your-email@gmail.com      (your email)
   EMAIL_APP_PASSWORD=xxxx xxxx xxxx xxxx (app password)
   GOOGLE_CLIENT_ID=your_client_id      (if using OAuth)
   FRONTEND_URL=https://your-app.com    (your Flutter app URL)
   ADMIN_EMAILS=email1@gmail.com,email2@gmail.com
   NODE_ENV=production
   PORT=5000
   ```

5. **Click "Create Web Service"**
   - Render will start building and deploying
   - Wait for deployment to complete (usually 2-3 minutes)

### Step 3: Verify Deployment

Once deployed, you'll see a URL like: `https://jpl-backend.onrender.com`

**Test the endpoint:**
```bash
curl https://jpl-backend.onrender.com/health
```

### Step 4: Update Frontend

Update your Flutter app's API base URL to point to Render:

In `lib/services/auth_service.dart`:
```dart
const String apiBaseUrl = 'https://jpl-backend.onrender.com/api';
```

## Phase 4: Post-Deployment

### Monitor Logs

In Render dashboard:
- Click your service
- Go to "Logs"
- Watch for errors and issues

### Auto-Restart on Failure

Render automatically restarts failed services. No action needed.

### Update Database

If you need to run migrations later:
1. Update `server/migrations/init.sql`
2. Push to GitHub
3. Run migration manually using psql or database client
   ```bash
   psql $DATABASE_URL < migrations/init.sql
   ```

### Add Email Domain to Allowlist (Optional)

If email isn't working in production:
1. Check Gmail's "Less secure apps" settings
2. Or use environment-specific email settings

## Troubleshooting

### Database Connection Fails

**Error**: `connect ECONNREFUSED`

**Solution**:
1. Verify `DATABASE_URL` is correct
2. Check NeonDB password doesn't have special characters (URL encode if needed)
3. Ensure Render IP is whitelisted in NeonDB

### Email Not Sending

**Error**: `Invalid login`

**Solution**:
1. Verify you're using Gmail app password (not regular password)
2. Verify `EMAIL_FROM` email address matches the account
3. Check "Display unlocked captcha" on Google account

### FPL API Returns 429 (Rate Limited)

**Solution**: The caching helps reduce calls. Rate limit resets hourly.

### Stuck on Building

**Solution**:
1. Check build logs in Render
2. Verify `package.json` has no circular dependencies
3. Try redeploying

## Next Steps

1. **Test all endpoints** with updated Flutter app
2. **Set up monitoring** - Render provides logs
3. **Configure custom domain** - Optional, through Render
4. **Set up backups** - Enable NeonDB backups
5. **Monitor logs regularly** - Check for unusual errors

## Support

For issues:
1. Check Render logs
2. Check NeonDB connection status
3. Verify all environment variables
4. Review application logs

Good luck! 🚀
