const express = require('express');
const profileController = require('../controllers/profileController');
const authenticateToken = require('../middleware/authenticateToken');

const router = express.Router();

// All profile routes require authentication
router.use(authenticateToken);

/**
 * POST /api/profile/update
 * Update user profile (name and/or FPL Team ID)
 */
router.post('/update', profileController.updateProfile);

/**
 * POST /api/password/change
 * Change user password
 */
router.post('/password/change', profileController.changePassword);

module.exports = router;
