const express = require('express');

const { uploadCertificateHandler } = require('../controllers/adminController');
const authMiddleware = require('../utils/authMiddleware');
const upload = require('../utils/multerConfig');

const router = express.Router();

router.post('/upload-certificate', authMiddleware, upload.single('certificate'), uploadCertificateHandler);

module.exports = router;