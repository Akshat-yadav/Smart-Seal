const jwt = require('jsonwebtoken');

const signAdminToken = (admin) => {
  return jwt.sign(
    { id: admin._id, email: admin.email },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
  );
};

const verifyToken = (token) => jwt.verify(token, process.env.JWT_SECRET);

module.exports = { signAdminToken, verifyToken };