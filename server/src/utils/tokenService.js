const jwt = require('jsonwebtoken');
const crypto = require('crypto');
require('dotenv').config();

/**
 * Generate JWT authentication token
 * @param {number} userId - User ID
 * @param {string} email - User email
 * @returns {string} JWT token
 */
const generateAuthToken = (userId, email) => {
  const payload = {
    id: userId,
    email,
  };

  const options = {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    algorithm: 'HS256',
  };

  return jwt.sign(payload, process.env.JWT_SECRET, options);
};

/**
 * Verify JWT token
 * @param {string} token - JWT token to verify
 * @returns {object} Decoded token payload
 */
const verifyAuthToken = (token) => {
  try {
    return jwt.verify(token, process.env.JWT_SECRET);
  } catch (error) {
    throw new Error(`Token verification failed: ${error.message}`);
  }
};

/**
 * Generate email verification token (6-digit code or random string)
 * @returns {object} { token, expiresAt }
 */
const generateVerificationToken = () => {
  const token = crypto.randomBytes(32).toString('hex');
  const expiresAt = new Date(Date.now() + 6 * 60 * 60 * 1000); // 6 hours from now

  return {
    token,
    expiresAt,
  };
};

/**
 * Generate password reset token
 * @returns {object} { token, expiresAt }
 */
const generatePasswordResetToken = () => {
  const token = crypto.randomBytes(32).toString('hex');
  const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour from now

  return {
    token,
    expiresAt,
  };
};

/**
 * Extract token from Authorization header
 * @param {string} authHeader - Authorization header value
 * @returns {string|null} Token or null
 */
const extractTokenFromHeader = (authHeader) => {
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null;
  }
  return authHeader.slice(7); // Remove 'Bearer ' prefix
};

module.exports = {
  generateAuthToken,
  verifyAuthToken,
  generateVerificationToken,
  generatePasswordResetToken,
  extractTokenFromHeader,
};
