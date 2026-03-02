/**
 * Error handler middleware
 * Should be added as the last middleware
 */
const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  // Handle validation errors
  if (err.name === 'ValidationError' || err.isJoi) {
    return res.status(400).json({
      success: false,
      error: err.details ? err.details[0].message : err.message,
      code: 'VALIDATION_ERROR',
      statusCode: 400,
    });
  }

  // Handle database errors
  if (err.code && err.code.startsWith('23')) { // PostgreSQL constraint violation
    return res.status(409).json({
      success: false,
      error: 'Unique constraint violation',
      code: 'CONSTRAINT_VIOLATION',
      statusCode: 409,
    });
  }

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      error: 'Invalid token',
      code: 'INVALID_TOKEN',
      statusCode: 401,
    });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      error: 'Token expired',
      code: 'TOKEN_EXPIRED',
      statusCode: 401,
    });
  }

  // Default error
  const statusCode = err.statusCode || 500;
  const code = err.code || 'INTERNAL_SERVER_ERROR';

  return res.status(statusCode).json({
    success: false,
    error: err.message || 'An unexpected error occurred',
    code,
    statusCode,
  });
};

module.exports = errorHandler;
