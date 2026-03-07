const mongoose = require('mongoose');

const certificateSchema = new mongoose.Schema(
  {
    certificateId: { type: String, required: true, unique: true, index: true },
    studentName: { type: String, required: true },
    courseName: { type: String, required: true },
    issuerName: { type: String, required: true },
    issueDate: { type: Date, required: true },
    expiryDate: { type: Date },
    fileHash: { type: String, required: true, index: true },
    originalFilePath: { type: String, required: true },
    processedFilePath: { type: String, required: true },
    qrCodePath: { type: String, required: true },
    verificationUrl: { type: String, required: true },
    blockchainEnabled: { type: Boolean, default: false },
    blockchainStored: { type: Boolean, default: false },
    blockchainTxHash: { type: String },
    blockchainError: { type: String },
    uploadedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'Admin', required: true }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Certificate', certificateSchema);