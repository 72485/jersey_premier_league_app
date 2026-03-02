const nodemailer = require('nodemailer');
require('dotenv').config();

let transporter;

// Configure based on email service
if (process.env.EMAIL_SERVICE === 'gmail') {
  console.log('[EMAIL] Configuring Gmail transporter');
  console.log('[EMAIL] Email From:', process.env.EMAIL_FROM);
  console.log('[EMAIL] Email Password Set:', !!process.env.EMAIL_APP_PASSWORD);
  
  transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_FROM,
      pass: process.env.EMAIL_APP_PASSWORD,
    },
  });
} else {
  console.log('[EMAIL] Configuring generic SMTP transporter');
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT,
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },
  });
}

/**
 * Send email
 * @param {string} to - Recipient email
 * @param {string} subject - Email subject
 * @param {string} html - HTML email body
 */
const sendEmail = async (to, subject, html) => {
  try {
    console.log(`[EMAIL] === Starting email send ===`);
    console.log(`[EMAIL] To: ${to}`);
    console.log(`[EMAIL] Subject: ${subject}`);
    console.log(`[EMAIL] From: ${process.env.EMAIL_FROM || 'NOT SET'}`);
    console.log(`[EMAIL] Service: ${process.env.EMAIL_SERVICE || 'NOT SET'}`);
    
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to,
      subject,
      html,
    };
    
    console.log('[EMAIL] Calling transporter.sendMail...');
    const info = await Promise.race([
      transporter.sendMail(mailOptions),
      new Promise((_, reject) => 
        setTimeout(() => reject(new Error('Email send timeout after 10 seconds')), 10000)
      )
    ]);
    
    console.log(`[EMAIL] ✅ SUCCESS: Email sent to ${to}`);
    console.log(`[EMAIL] Message ID: ${info.messageId}`);
    console.log(`[EMAIL] Response: ${info.response}`);
    return info;
  } catch (error) {
    console.error(`[EMAIL] ❌ FAILED to send email to ${to}`);
    console.error(`[EMAIL] Error name: ${error.name}`);
    console.error(`[EMAIL] Error message: ${error.message}`);
    console.error(`[EMAIL] Error code: ${error.code}`);
    console.error(`[EMAIL] Full error:`, error);
    throw error;
  }
};

/**
 * Send email verification link
 * @param {string} email - User email
 * @param {string} token - Verification token
 * @param {string} baseUrl - Frontend base URL
 */
const sendVerificationEmail = async (email, token, baseUrl) => {
  const verificationLink = `${baseUrl}/verify-email?token=${token}`;
  const html = `
    <h2>Welcome to Jersey Premier League!</h2>
    <p>Please verify your email to activate your account.</p>
    <p>
      <a href="${verificationLink}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
        Verify Email
      </a>
    </p>
    <p>Or copy this link: ${verificationLink}</p>
    <p>This link expires in 6 hours.</p>
  `;

  return sendEmail(email, 'Verify your Jersey Premier League account', html);
};

/**
 * Send password reset email (future)
 */
const sendPasswordResetEmail = async (email, token, baseUrl) => {
  const resetLink = `${baseUrl}/reset-password?token=${token}`;
  const html = `
    <h2>Password Reset Request</h2>
    <p>We received a request to reset your password.</p>
    <p>
      <a href="${resetLink}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
        Reset Password
      </a>
    </p>
    <p>This link expires in 1 hour.</p>
    <p>If you didn't request this, you can ignore this email.</p>
  `;

  return sendEmail(email, 'Reset your Jersey Premier League password', html);
};

module.exports = {
  sendEmail,
  sendVerificationEmail,
  sendPasswordResetEmail,
  transporter,
};
