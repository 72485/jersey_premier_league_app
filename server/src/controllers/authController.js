const User = require('../models/User');
const { generateAuthToken, generateVerificationToken } = require('../utils/tokenService');
const { sendVerificationEmail } = require('../config/email');
const { validateRegister, validateLogin, validateGoogleAuth, validateVerificationToken } = require('../utils/validators');
require('dotenv').config();

/**
 * User registration
 */
const register = async (req, res, next) => {
  try {
    const { error, value } = validateRegister(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    const { email, password, name } = value;

    // Check if email already exists
    const existingUser = await User.findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({
        success: false,
        error: 'Email already exists',
        code: 'EMAIL_EXISTS',
      });
    }

    // Hash password
    const passwordHash = await User.hashPassword(password);

    // Create user
    const newUser = await User.createUser(email, passwordHash, name);

    // Generate verification token
    const { token, expiresAt } = generateVerificationToken();
    await User.setVerificationToken(newUser.id, token, expiresAt);

    // Send verification email
    try {
      const verificationUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}`;
      await sendVerificationEmail(email, token, verificationUrl);
    } catch (emailError) {
      console.error('Failed to send verification email:', emailError);
      // Don't fail the registration if email fails, user can request it later
    }

    return res.status(201).json({
      success: true,
      message: 'User registered successfully. Please check your email to verify your account.',
      data: {
        id: newUser.id,
        email: newUser.email,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Email verification
 */
const verifyEmail = async (req, res, next) => {
  try {
    const { error, value } = validateVerificationToken(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    const { token } = value;

    // Find user by token
    const user = await User.findUserByVerificationToken(token);
    if (!user) {
      return res.status(400).json({
        success: false,
        error: 'Invalid or expired verification token',
        code: 'INVALID_TOKEN',
      });
    }

    // Check if token is expired
    if (new Date(user.verification_token_expires) < new Date()) {
      return res.status(400).json({
        success: false,
        error: 'Verification token has expired',
        code: 'TOKEN_EXPIRED',
      });
    }

    // Verify email
    const verifiedUser = await User.verifyUserEmail(user.id);

    return res.json({
      success: true,
      message: 'Email verified successfully',
      data: User.formatUserResponse(verifiedUser),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * User login
 */
const login = async (req, res, next) => {
  try {
    const { error, value } = validateLogin(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    const { email, password } = value;

    // Find user
    const user = await User.findUserByEmail(email);
    if (!user) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      });
    }

    // Compare passwords
    const isPasswordValid = await User.comparePassword(password, user.password_hash);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        error: 'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
      });
    }

    // Check if email is verified
    if (!user.is_email_verified) {
      return res.status(403).json({
        success: false,
        error: 'Email not verified. Please check your email for verification link.',
        code: 'EMAIL_NOT_VERIFIED',
      });
    }

    // Generate token
    const token = generateAuthToken(user.id, user.email);

    return res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: User.formatUserResponse(user),
        token,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Google OAuth login/signup
 */
const googleAuth = async (req, res, next) => {
  try {
    const { error, value } = validateGoogleAuth(req.body);
    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details[0].message,
        code: 'VALIDATION_ERROR',
      });
    }

    const { googleIdToken, name } = value;

    // TODO: Verify Google ID token (requires google-auth-library)
    // For now, we'll assume it's valid and extract email from payload
    // In production, use: const ticket = await client.verifyIdToken(...)
    // and extract payload from ticket

    // This is a placeholder - implement actual Google token verification
    let email;
    try {
      const payload = JSON.parse(Buffer.from(googleIdToken.split('.')[1], 'base64').toString());
      email = payload.email;
    } catch (decodeError) {
      return res.status(400).json({
        success: false,
        error: 'Invalid Google token format',
        code: 'INVALID_TOKEN',
      });
    }

    // Check if user exists
    let user = await User.findUserByEmail(email);

    if (!user) {
      // Create new user
      const passwordHash = await User.hashPassword(Math.random().toString(36)); // Random password for OAuth users
      user = await User.createUser(email, passwordHash, name || email.split('@')[0]);

      // Verify email automatically for Google OAuth users
      user = await User.verifyUserEmail(user.id);
    }

    // Generate token
    const token = generateAuthToken(user.id, user.email);

    return res.json({
      success: true,
      message: 'Authentication successful',
      data: {
        user: User.formatUserResponse(user),
        token,
        isNewUser: !user.updated_at || user.created_at === user.updated_at,
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  verifyEmail,
  login,
  googleAuth,
};
