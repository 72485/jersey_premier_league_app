const express = require('express');
const adminController = require('../controllers/adminController');
const authenticateToken = require('../middleware/authenticateToken');
const adminCheck = require('../middleware/adminCheck');

const router = express.Router();

// All admin routes require authentication and admin status
router.use(authenticateToken);
router.use(adminCheck);

/**
 * GET /api/admin/verify
 * Check if user is admin
 */
router.get('/verify', adminController.verifyAdmin);

/**
 * POST /api/admin/announcements
 * Create a new announcement
 */
router.post('/announcements', adminController.createAnnouncement);

/**
 * GET /api/admin/announcements
 * Get all active announcements
 */
router.get('/announcements', adminController.getAnnouncements);

/**
 * PUT /api/admin/announcements/:id
 * Update an announcement
 */
router.put('/announcements/:id', adminController.updateAnnouncement);

/**
 * DELETE /api/admin/announcements/:id
 * Deactivate an announcement
 */
router.delete('/announcements/:id', adminController.deleteAnnouncement);

module.exports = router;
