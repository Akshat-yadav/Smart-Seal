const crypto = require('crypto');

const generateSHA256 = (buffer) => {
  return crypto.createHash('sha256').update(buffer).digest('hex');
};

module.exports = { generateSHA256 };