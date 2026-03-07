const path = require('path');
const multer = require('multer');

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname || '').toLowerCase();
  const isPdfMime = file.mimetype === 'application/pdf';
  const isGenericMimePdf = file.mimetype === 'application/octet-stream' && ext === '.pdf';

  if (!isPdfMime && !isGenericMimePdf) {
    return cb(new Error('Only PDF files are allowed'));
  }

  cb(null, true);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }
});

module.exports = upload;
