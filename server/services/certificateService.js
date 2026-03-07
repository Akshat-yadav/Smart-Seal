const path = require('path');
const QRCode = require('qrcode');

const Certificate = require('../models/Certificate');
const { generateCertificateId } = require('../utils/certificateId');
const { generateSHA256 } = require('../utils/hash');
const { embedQrIntoPdf, saveBufferToFile } = require('./pdfService');
const { storeHashOnChain, verifyHashOnChain } = require('./blockchainService');

const sanitizeBaseUrl = (baseUrl) => baseUrl?.trim().replace(/\/$/, '');

const uploadCertificate = async ({ file, body, adminId, baseUrl }) => {
  if (!file) {
    throw new Error('Certificate PDF is required');
  }

  const certificateId = generateCertificateId();
  const fileHash = generateSHA256(file.buffer);
  const resolvedBaseUrl = sanitizeBaseUrl(baseUrl) || sanitizeBaseUrl(process.env.BASE_URL) || 'http://localhost:5000';
  const verificationUrl = `${resolvedBaseUrl}/verify/${certificateId}`;

  const qrPayload = JSON.stringify({
    certificateId,
    fileHash,
    verify: verificationUrl
  });

  const qrPngBuffer = await QRCode.toBuffer(qrPayload, {
    type: 'png',
    width: 300,
    margin: 1
  });

  const processedPdfBuffer = await embedQrIntoPdf(file.buffer, qrPngBuffer);

  const originalName = `${certificateId}-original.pdf`;
  const processedName = `${certificateId}-verified.pdf`;
  const qrName = `${certificateId}.png`;

  const originalFilePath = path.join('uploads', 'original', originalName);
  const processedFilePath = path.join('uploads', 'processed', processedName);
  const qrCodePath = path.join('uploads', 'qr', qrName);

  await saveBufferToFile(path.join(__dirname, '..', originalFilePath), file.buffer);
  await saveBufferToFile(path.join(__dirname, '..', processedFilePath), processedPdfBuffer);
  await saveBufferToFile(path.join(__dirname, '..', qrCodePath), qrPngBuffer);

  const chainResult = await storeHashOnChain(fileHash);
  const blockchainRequired = process.env.BLOCKCHAIN_REQUIRED === 'true';
  if (blockchainRequired && chainResult.enabled && !chainResult.stored) {
    throw new Error(`Blockchain write failed: ${chainResult.error || 'Unknown error'}`);
  }

  const certificate = await Certificate.create({
    certificateId,
    studentName: body.studentName,
    courseName: body.courseName,
    issuerName: body.issuerName,
    issueDate: body.issueDate,
    expiryDate: body.expiryDate || null,
    fileHash,
    originalFilePath,
    processedFilePath,
    qrCodePath,
    verificationUrl,
    blockchainEnabled: chainResult.enabled,
    blockchainStored: chainResult.stored,
    blockchainTxHash: chainResult.txHash,
    blockchainError: chainResult.error,
    uploadedBy: adminId
  });

  return certificate;
};

const verifyCertificateById = async (certificateId) => {
  const certificate = await Certificate.findOne({ certificateId }).lean();
  if (!certificate) {
    return null;
  }

  const chainVerification = await verifyHashOnChain(certificate.fileHash);

  return {
    certificateId: certificate.certificateId,
    studentName: certificate.studentName,
    courseName: certificate.courseName,
    issuerName: certificate.issuerName,
    issueDate: certificate.issueDate,
    expiryDate: certificate.expiryDate,
    fileHash: certificate.fileHash,
    verificationUrl: certificate.verificationUrl,
    processedCertificateUrl: `/${certificate.processedFilePath.replace(/\\/g, '/')}`,
    qrCodeUrl: `/${certificate.qrCodePath.replace(/\\/g, '/')}`,
    uploadedAt: certificate.createdAt,
    blockchain: {
      enabled: chainVerification.enabled,
      storedAtUpload: certificate.blockchainStored,
      txHash: certificate.blockchainTxHash || null,
      isValid: chainVerification.isValid,
      error: chainVerification.error || certificate.blockchainError || null,
      chainId: chainVerification.chainId || null
    }
  };
};

module.exports = { uploadCertificate, verifyCertificateById };
