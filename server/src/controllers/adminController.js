const Announcement = require('../models/Announcement');
const User = require('../models/User');
const { validateAnnouncement } = require('../utils/validators');

/**
 * Check if user is admin
 */
const verifyAdmin = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const email = req.user.email;

    const adminEmails = (process.env.ADMIN_EMAILS || '').split(',').map((e) => e.trim());
    const isAdmin = adminEmails.includes(email);

    return res.json({
      success: true,
      data: {
        isAdmin,
        email,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Create announcement
 */
const createAnnouncement = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { error, value } = validateAnnouncement(req.body);

    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    const { title, content } = value;

    const announcement = await Announcement.createAnnouncement(title, content, userId);

    return res.status(201).json({
      success: true,
      message: 'Announcement created successfully',
      data: announcement,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all active announcements
 */
const getAnnouncements = async (req, res, next) => {
  try {
    const announcements = await Announcement.getActiveAnnouncements();

    return res.json({
      success: true,
      data: announcements,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update announcement
 */
const updateAnnouncement = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, content, is_active } = req.body;

    // Verify announcement exists
    const announcement = await Announcement.getAnnouncementById(id);
    if (!announcement) {
      return res.status(404).json({
        success: false,
        error: 'Announcement not found',
        code: 'NOT_FOUND',
      });
    }

    // Prepare updates
    const updates = {};
    if (title !== undefined) updates.title = title;
    if (content !== undefined) updates.content = content;
    if (is_active !== undefined) updates.is_active = is_active;

    if (Object.keys(updates).length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No fields to update',
        code: 'NO_FIELDS',
      });
    }

    const updated = await Announcement.updateAnnouncement(id, updates);

    return res.json({
      success: true,
      message: 'Announcement updated successfully',
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Deactivate announcement
 */
const deleteAnnouncement = async (req, res, next) => {
  try {
    const { id } = req.params;

    // Verify announcement exists
    const announcement = await Announcement.getAnnouncementById(id);
    if (!announcement) {
      return res.status(404).json({
        success: false,
        error: 'Announcement not found',
        code: 'NOT_FOUND',
      });
    }

    const updated = await Announcement.deactivateAnnouncement(id);

    return res.json({
      success: true,
      message: 'Announcement deleted successfully',
      data: updated,
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  verifyAdmin,
  createAnnouncement,
  getAnnouncements,
  updateAnnouncement,
  deleteAnnouncement,
};
