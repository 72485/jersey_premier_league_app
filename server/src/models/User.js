const db = require('../config/database');
const bcrypt = require('bcryptjs');

/**
 * User model - Database operations
 */

/**
 * Create a new user
 */
const createUser = async (email, passwordHash, name) => {
  const query = `
    INSERT INTO users (email, password_hash, name, is_email_verified, created_at)
    VALUES ($1, $2, $3, false, NOW())
    RETURNING id, email, name, is_email_verified
  `;
  const result = await db.query(query, [email, passwordHash, name]);
  return result.rows[0];
};

/**
 * Find user by email
 */
const findUserByEmail = async (email) => {
  const query = `
    SELECT id, email, password_hash, name, fpl_team_id, is_email_verified, created_at, updated_at
    FROM users
    WHERE email = $1 AND deleted_at IS NULL
  `;
  const result = await db.query(query, [email]);
  return result.rows[0];
};

/**
 * Find user by ID
 */
const findUserById = async (id) => {
  const query = `
    SELECT id, email, password_hash, name, fpl_team_id, is_email_verified, created_at, updated_at
    FROM users
    WHERE id = $1 AND deleted_at IS NULL
  `;
  const result = await db.query(query, [id]);
  return result.rows[0];
};

/**
 * Find user by verification token
 */
const findUserByVerificationToken = async (token) => {
  const query = `
    SELECT id, email, verification_token, verification_token_expires, is_email_verified
    FROM users
    WHERE verification_token = $1 AND deleted_at IS NULL
  `;
  const result = await db.query(query, [token]);
  return result.rows[0];
};

/**
 * Update user email verification status
 */
const verifyUserEmail = async (userId) => {
  const query = `
    UPDATE users
    SET is_email_verified = true, verification_token = NULL, verification_token_expires = NULL, updated_at = NOW()
    WHERE id = $1
    RETURNING id, email, name, fpl_team_id, is_email_verified
  `;
  const result = await db.query(query, [userId]);
  return result.rows[0];
};

/**
 * Set verification token for user
 */
const setVerificationToken = async (userId, token, expiresAt) => {
  const query = `
    UPDATE users
    SET verification_token = $1, verification_token_expires = $2, updated_at = NOW()
    WHERE id = $3
    RETURNING id, email
  `;
  const result = await db.query(query, [token, expiresAt, userId]);
  return result.rows[0];
};

/**
 * Check if FPL Team ID is already taken
 */
const isFplTeamIdTaken = async (fplTeamId, excludeUserId = null) => {
  let query = 'SELECT id FROM users WHERE fpl_team_id = $1 AND deleted_at IS NULL';
  const params = [fplTeamId];

  if (excludeUserId) {
    query += ' AND id != $2';
    params.push(excludeUserId);
  }

  const result = await db.query(query, params);
  return result.rows.length > 0;
};

/**
 * Update user profile
 */
const updateUserProfile = async (userId, updates) => {
  const allowedFields = ['name', 'fpl_team_id'];
  const setClauses = [];
  const params = [];
  let paramIndex = 1;

  for (const [key, value] of Object.entries(updates)) {
    if (allowedFields.includes(key) && value !== undefined) {
      setClauses.push(`${key} = $${paramIndex}`);
      params.push(value);
      paramIndex += 1;
    }
  }

  if (setClauses.length === 0) {
    throw new Error('No valid fields to update');
  }

  setClauses.push('updated_at = NOW()');
  params.push(userId);

  const query = `
    UPDATE users
    SET ${setClauses.join(', ')}
    WHERE id = $${paramIndex}
    RETURNING id, email, name, fpl_team_id, is_email_verified
  `;

  const result = await db.query(query, params);
  return result.rows[0];
};

/**
 * Update user password
 */
const updateUserPassword = async (userId, newPasswordHash) => {
  const query = `
    UPDATE users
    SET password_hash = $1, updated_at = NOW()
    WHERE id = $2
    RETURNING id, email, name
  `;
  const result = await db.query(query, [newPasswordHash, userId]);
  return result.rows[0];
};

/**
 * Hash password with bcrypt
 */
const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(10);
  return bcrypt.hash(password, salt);
};

/**
 * Compare password with hash
 */
const comparePassword = async (password, hash) => {
  return bcrypt.compare(password, hash);
};

/**
 * Get user without sensitive data (for API response)
 */
const formatUserResponse = (user) => {
  if (!user) return null;
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    fpl_team_id: user.fpl_team_id || 0, // 🐛 FIX: Coalesce null fpl_team_id to 0
    is_email_verified: user.is_email_verified,
  };
};

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
  findUserByVerificationToken,
  verifyUserEmail,
  setVerificationToken,
  isFplTeamIdTaken,
  updateUserProfile,
  updateUserPassword,
  hashPassword,
  comparePassword,
  formatUserResponse,
};
