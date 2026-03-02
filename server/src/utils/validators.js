const Joi = require('joi');

/**
 * Validate email format
 */
const validateEmail = (email) => {
  const schema = Joi.string().email().required();
  return schema.validate(email);
};

/**
 * Validate password strength (minimum 6 characters)
 */
const validatePassword = (password) => {
  const schema = Joi.string().min(6).required();
  return schema.validate(password);
};

/**
 * Validate user registration input
 */
const validateRegister = (data) => {
  const schema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().min(6).required(),
    name: Joi.string().trim().min(1).required(),
  });
  return schema.validate(data);
};

/**
 * Validate login input
 */
const validateLogin = (data) => {
  const schema = Joi.object({
    email: Joi.string().email().required(),
    password: Joi.string().required(),
  });
  return schema.validate(data);
};

/**
 * Validate Google OAuth input
 */
const validateGoogleAuth = (data) => {
  const schema = Joi.object({
    googleIdToken: Joi.string().required(),
    name: Joi.string().trim(),
  });
  return schema.validate(data);
};

/**
 * Validate profile update
 */
const validateProfileUpdate = (data) => {
  const schema = Joi.object({
    name: Joi.string().trim().min(1),
    fplTeamID: Joi.string().trim(),
  }).min(1); // At least one field must be provided
  return schema.validate(data);
};

/**
 * Validate password change
 */
const validatePasswordChange = (data) => {
  const schema = Joi.object({
    currentPassword: Joi.string().required(),
    newPassword: Joi.string().min(6).required(),
  });
  return schema.validate(data);
};

/**
 * Validate announcement creation
 */
const validateAnnouncement = (data) => {
  const schema = Joi.object({
    title: Joi.string().trim().min(1).required(),
    content: Joi.string().trim().min(1).required(),
  });
  return schema.validate(data);
};

/**
 * Validate email verification token
 */
const validateVerificationToken = (data) => {
  const schema = Joi.object({
    token: Joi.string().required(),
  });
  return schema.validate(data);
};

module.exports = {
  validateEmail,
  validatePassword,
  validateRegister,
  validateLogin,
  validateGoogleAuth,
  validateProfileUpdate,
  validatePasswordChange,
  validateAnnouncement,
  validateVerificationToken,
};
