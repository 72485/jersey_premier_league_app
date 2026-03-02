const { verifyAuthToken, extractTokenFromHeader } = require('../utils/tokenService');

/**
 * Middleware to authenticate JWT token
 */
const authenticateToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    const token = extractTokenFromHeader(authHeader);

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'No token provided',
        code: 'NO_TOKEN',
      });
    }

    const decoded = verifyAuthToken(token);
    req.user = decoded; // Attach user data to request
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      error: 'Invalid or expired token',
      code: 'INVALID_TOKEN',
    });
  }
};

module.exports = authenticateToken;
