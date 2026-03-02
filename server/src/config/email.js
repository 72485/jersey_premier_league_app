const nodemailer = require('nodemailer');
require('dotenv').config();

let transporter;

console.log('[EMAIL] Initializing email transporter...');
console.log('[EMAIL] Service:', process.env.EMAIL_SERVICE);
console.log('[EMAIL] From:', process.env.EMAIL_FROM);

// Configure based on email service
if (process.env.EMAIL_SERVICE === 'gmail') {
  console.log('[EMAIL] Setting up Gmail transporter');
  
  transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false, // Use STARTTLS instead of SSL
    auth: {
      user: process.env.EMAIL_FROM,
      pass: process.env.EMAIL_APP_PASSWORD,
    },
    connectionTimeout: 15000,
    socketTimeout: 15000,
    logger: false,
    debug: false,
  });
  
  // Test connection asynchronously (don't block startup)
  setTimeout(() => {
    console.log('[EMAIL] Testing Gmail connection...');
    transporter.verify((error, success) => {
      if (error) {
        console.error('[EMAIL] ❌ Gmail connection test failed:', error.message);
        console.error('[EMAIL] Error code:', error.code);
        console.error('[EMAIL] Response code:', error.responseCode);
      } else if (success) {
        console.log('[EMAIL] ✅ Gmail connection verified and ready');
      }
    });
  }, 2000); // Wait 2 seconds after startup to test
  
} else {
  console.log('[EMAIL] Setting up generic SMTP transporter');
  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: process.env.SMTP_PORT || 587,
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
    console.log(`[EMAIL] === Sending email ===`);
    console.log(`[EMAIL] To: ${to}`);
    console.log(`[EMAIL] Subject: ${subject.substring(0, 50)}...`);
    
    const mailOptions = {
      from: process.env.EMAIL_FROM,
      to,
      subject,
      html,
    };
    
    console.log('[EMAIL] Calling transporter.sendMail()...');
    let timeout = setTimeout(() => {
      console.error('[EMAIL] ⏱️ Email send is taking too long (>25s)');
    }, 25000);
    
    const info = await transporter.sendMail(mailOptions);
    
    clearTimeout(timeout);
    console.log(`[EMAIL] ✅ SUCCESS: Email sent to ${to}`);
    console.log(`[EMAIL] Message ID: ${info.messageId}`);
    return info;
  } catch (error) {
    console.error(`[EMAIL] ❌ FAILED to send email to ${to}`);
    console.error(`[EMAIL] Error name: ${error.name}`);
    console.error(`[EMAIL] Error message: ${error.message}`);
    console.error(`[EMAIL] Error code: ${error.code}`);
    console.error(`[EMAIL] Response code: ${error.responseCode}`);
    if (error.response) {
      console.error(`[EMAIL] SMTP Response: ${error.response}`);
    }
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
  console.log('[EMAIL] sendVerificationEmail called');
  const verificationLink = `${baseUrl}/verify-email?token=${token}`;
  console.log(`[EMAIL] Verification link: ${verificationLink}`);
  
  const html = `
    <h2>Welcome to Jersey Premier League!</h2>
    <p>Please verify your email to activate your account.</p>
    <p>
      <a href="${verificationLink}" style="background-color: #4CAF50; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
        Verify Email
      </a>
    </p>
    <p>Or copy this link: ${verificationLink}</p>
    <p><strong>Verification Token:</strong> ${token}</p>
    <p>This link expires in 6 hours.</p>
  `;

  console.log('[EMAIL] Calling sendEmail for verification...');
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
