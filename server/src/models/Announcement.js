const db = require('../config/database');

/**
 * Announcement model - Database operations
 */

/**
 * Create a new announcement
 */
const createAnnouncement = async (title, content, createdBy) => {
  const query = `
    INSERT INTO announcements (title, content, created_by, created_at, is_active)
    VALUES ($1, $2, $3, NOW(), true)
    RETURNING id, title, content, created_by, created_at, is_active
  `;
  const result = await db.query(query, [title, content, createdBy]);
  return result.rows[0];
};

/**
 * Get all active announcements
 */
const getActiveAnnouncements = async () => {
  const query = `
    SELECT id, title, content, created_by, created_at, is_active
    FROM announcements
    WHERE is_active = true
    ORDER BY created_at DESC
  `;
  const result = await db.query(query);
  return result.rows;
};

/**
 * Get announcement by ID
 */
const getAnnouncementById = async (id) => {
  const query = `
    SELECT id, title, content, created_by, created_at, is_active
    FROM announcements
    WHERE id = $1
  `;
  const result = await db.query(query, [id]);
  return result.rows[0];
};

/**
 * Update announcement
 */
const updateAnnouncement = async (id, updates) => {
  const allowedFields = ['title', 'content', 'is_active'];
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

  params.push(id);

  const query = `
    UPDATE announcements
    SET ${setClauses.join(', ')}
    WHERE id = $${paramIndex}
    RETURNING id, title, content, created_by, created_at, is_active
  `;

  const result = await db.query(query, params);
  return result.rows[0];
};

/**
 * Soft delete announcement (set is_active to false)
 */
const deactivateAnnouncement = async (id) => {
  const query = `
    UPDATE announcements
    SET is_active = false
    WHERE id = $1
    RETURNING id, title, content, created_by, created_at, is_active
  `;
  const result = await db.query(query, [id]);
  return result.rows[0];
};

/**
 * Hard delete announcement (only for cleanup)
 */
const deleteAnnouncementPermanently = async (id) => {
  const query = 'DELETE FROM announcements WHERE id = $1';
  await db.query(query, [id]);
};

module.exports = {
  createAnnouncement,
  getActiveAnnouncements,
  getAnnouncementById,
  updateAnnouncement,
  deactivateAnnouncement,
  deleteAnnouncementPermanently,
};
