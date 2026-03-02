const User = require('../models/User');
const { validateProfileUpdate, validatePasswordChange } = require('../utils/validators');

/**
 * Update user profile (name and/or FPL Team ID)
 */
const updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { error, value } = validateProfileUpdate(req.body);

    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    // If FPL Team ID is provided, check uniqueness
    if (value.fplTeamID) {
      const isTaken = await User.isFplTeamIdTaken(value.fplTeamID, userId);
      if (isTaken) {
        return res.status(409).json({
          success: false,
          error: 'FPL Team ID already in use',
          code: 'FPL_TEAM_ID_EXISTS',
        });
      }
    }

    // Prepare update object with proper field names
    const updates = {};
    if (value.name !== undefined) updates.name = value.name;
    if (value.fplTeamID !== undefined) updates.fpl_team_id = value.fplTeamID;

    // Update user
    const updatedUser = await User.updateUserProfile(userId, updates);

    return res.json({
      success: true,
      message: 'Profile updated successfully',
      data: User.formatUserResponse(updatedUser),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Change user password
 */
const changePassword = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const { error, value } = validatePasswordChange(req.body);

    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    const { currentPassword, newPassword } = value;

    // Get user with password hash
    const user = await User.findUserById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        error: 'User not found',
        code: 'USER_NOT_FOUND',
      });
    }

    // Verify current password
    const isPasswordValid = await User.comparePassword(currentPassword, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: 'Current password is incorrect',
        code: 'INVALID_PASSWORD',
      });
    }

    // Hash new password
    const newPasswordHash = await User.hashPassword(newPassword);

    // Update password
    const updatedUser = await User.updateUserPassword(userId, newPasswordHash);

    return res.json({
      success: true,
      message: 'Password changed successfully',
      data: {
        id: updatedUser.id,
        email: updatedUser.email,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  updateProfile,
  changePassword,
};
