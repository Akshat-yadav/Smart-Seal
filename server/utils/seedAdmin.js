const Admin = require('../models/Admin');
const { createAdmin } = require('../services/authService');

const seedAdmin = async () => {
  const allowSeed = process.env.ALLOW_INSECURE_ADMIN_SEED === 'true';
  if (!allowSeed) {
    return;
  }

  const email = process.env.ADMIN_EMAIL;
  const password = process.env.ADMIN_PASSWORD;

  if (!email || !password) {
    console.warn('ALLOW_INSECURE_ADMIN_SEED=true but ADMIN_EMAIL / ADMIN_PASSWORD not set; skipping seed');
    return;
  }

  const existing = await Admin.findOne({ email: email.toLowerCase() });
  if (existing) {
    return;
  }

  await createAdmin({ email, password, name: 'Default Admin' });
  console.warn('Insecure admin seed executed. Disable ALLOW_INSECURE_ADMIN_SEED for production.');
};

module.exports = seedAdmin;
