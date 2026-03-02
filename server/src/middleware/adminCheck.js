require('dotenv').config();

/**
 * Middleware to check if user is admin
 * Requires authenticateToken middleware to run first
 */
const adminCheck = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({
      success: false,
      error: 'User not authenticated',
      code: 'NOT_AUTHENTICATED',
    });
  }

  const adminEmails = (process.env.ADMIN_EMAILS || '').split(',').map((email) => email.trim());

  if (!adminEmails.includes(req.user.email)) {
    return res.status(403).json({
      success: false,
      error: 'Admin access required',
      code: 'NOT_ADMIN',
    });
  }

  next();
};

module.exports = adminCheck;
