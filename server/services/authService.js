const bcrypt = require('bcryptjs');
const Admin = require('../models/Admin');
const { signAdminToken } = require('../utils/jwt');

const validatePasswordStrength = (password) => {
  if (!password || password.length < 12) {
    throw new Error('Password must be at least 12 characters long');
  }
  if (!/[A-Z]/.test(password) || !/[a-z]/.test(password) || !/\d/.test(password) || !/[^A-Za-z0-9]/.test(password)) {
    throw new Error('Password must include uppercase, lowercase, number, and special character');
  }
};

const createAdmin = async ({ email, password, name }) => {
  const normalizedEmail = email.toLowerCase().trim();
  validatePasswordStrength(password);

  const existing = await Admin.findOne({ email: normalizedEmail });
  if (existing) {
    throw new Error('Admin already exists');
  }

  const hashed = await bcrypt.hash(password, 12);
  const admin = await Admin.create({
    email: normalizedEmail,
    password: hashed,
    name: name?.trim() || 'System Admin'
  });

  return {
    id: admin._id,
    email: admin.email,
    name: admin.name
  };
};

const loginAdmin = async (email, password) => {
  const admin = await Admin.findOne({ email: email.toLowerCase() });
  if (!admin) {
    throw new Error('Invalid credentials');
  }

  const isMatch = await bcrypt.compare(password, admin.password);
  if (!isMatch) {
    throw new Error('Invalid credentials');
  }

  const token = signAdminToken(admin);

  return {
    token,
    admin: {
      id: admin._id,
      email: admin.email,
      name: admin.name
    }
  };
};

module.exports = { loginAdmin, createAdmin };
