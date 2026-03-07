const express = require('express');

const {
  adminLogin,
  bootstrapAdmin,
  createAdminByAdmin,
  uploadCertificateHandler
} = require('../controllers/adminController');
const authMiddleware = require('../utils/authMiddleware');
const upload = require('../utils/multerConfig');

const router = express.Router();

router.post('/login', adminLogin);
router.post('/bootstrap', bootstrapAdmin);
router.post('/create', authMiddleware, createAdminByAdmin);
router.post('/upload-certificate', authMiddleware, upload.single('certificate'), uploadCertificateHandler);

module.exports = router;
