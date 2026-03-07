const Admin = require('../models/Admin');
const { loginAdmin, createAdmin } = require('../services/authService');
const { uploadCertificate } = require('../services/certificateService');

const adminLogin = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const data = await loginAdmin(email, password);
    return res.json({ success: true, message: 'Login successful', data });
  } catch (error) {
    if (error.message === 'Invalid credentials') {
      return res.status(401).json({ success: false, message: error.message });
    }
    return next(error);
  }
};

const bootstrapAdmin = async (req, res, next) => {
  try {
    if (process.env.ADMIN_BOOTSTRAP_ENABLED !== 'true') {
      return res.status(403).json({ success: false, message: 'Admin bootstrap is disabled' });
    }

    const bootstrapSecret = req.header('x-admin-bootstrap-secret');
    if (!bootstrapSecret || bootstrapSecret !== process.env.ADMIN_BOOTSTRAP_SECRET) {
      return res.status(401).json({ success: false, message: 'Invalid bootstrap secret' });
    }

    const existingCount = await Admin.countDocuments();
    if (existingCount > 0) {
      return res.status(409).json({ success: false, message: 'Bootstrap already completed' });
    }

    const { email, password, name } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const admin = await createAdmin({ email, password, name });
    return res.status(201).json({
      success: true,
      message: 'Initial admin created successfully',
      data: { admin }
    });
  } catch (error) {
    if (error.message === 'Admin already exists') {
      return res.status(409).json({ success: false, message: error.message });
    }
    if (error.message.includes('Password must')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    return next(error);
  }
};

const createAdminByAdmin = async (req, res, next) => {
  try {
    const { email, password, name } = req.body;
    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email and password are required' });
    }

    const admin = await createAdmin({ email, password, name });
    return res.status(201).json({
      success: true,
      message: 'Admin created successfully',
      data: { admin }
    });
  } catch (error) {
    if (error.message === 'Admin already exists') {
      return res.status(409).json({ success: false, message: error.message });
    }
    if (error.message.includes('Password must')) {
      return res.status(400).json({ success: false, message: error.message });
    }
    return next(error);
  }
};

const uploadCertificateHandler = async (req, res, next) => {
  try {
    const { studentName, courseName, issuerName, issueDate } = req.body;
    if (!studentName || !courseName || !issuerName || !issueDate) {
      return res.status(400).json({
        success: false,
        message: 'studentName, courseName, issuerName, issueDate are required'
      });
    }

    const requestBaseUrl = `${req.protocol}://${req.get('host')}`;
    const certificate = await uploadCertificate({
      file: req.file,
      body: req.body,
      adminId: req.admin.id,
      baseUrl: requestBaseUrl
    });

    return res.status(201).json({
      success: true,
      message: 'Certificate uploaded successfully',
      data: {
        certificateId: certificate.certificateId,
        fileHash: certificate.fileHash,
        verificationUrl: certificate.verificationUrl,
        processedCertificateUrl: `/${certificate.processedFilePath.replace(/\\/g, '/')}`,
        qrCodeUrl: `/${certificate.qrCodePath.replace(/\\/g, '/')}`,
        blockchain: {
          enabled: certificate.blockchainEnabled,
          stored: certificate.blockchainStored,
          txHash: certificate.blockchainTxHash || null,
          error: certificate.blockchainError || null
        }
      }
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = { adminLogin, bootstrapAdmin, createAdminByAdmin, uploadCertificateHandler };
