const { customAlphabet } = require('nanoid');

const alphaNum = customAlphabet('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', 8);

const generateCertificateId = () => {
  return `CERT-${Date.now()}-${alphaNum()}`;
};

module.exports = { generateCertificateId };