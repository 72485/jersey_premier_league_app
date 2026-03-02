const express = require('express');
const authController = require('../controllers/authController');

const router = express.Router();

/**
 * POST /api/register
 * Register a new user
 */
router.post('/register', authController.register);

/**
 * POST /api/email/verify
 * Verify user email with token
 */
router.post('/email/verify', authController.verifyEmail);

/**
 * POST /api/login
 * Login with email and password
 */
router.post('/login', authController.login);

/**
 * POST /api/auth/google
 * Login/signup with Google OAuth
 */
router.post('/auth/google', authController.googleAuth);

module.exports = router;
