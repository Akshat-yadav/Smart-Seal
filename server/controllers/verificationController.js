const { verifyCertificateById } = require('../services/certificateService');

const verifyCertificate = async (req, res, next) => {
  try {
    const { certificateId } = req.params;
    const certificate = await verifyCertificateById(certificateId);

    if (!certificate) {
      return res.status(404).json({
        success: false,
        valid: false,
        message: 'Certificate not found'
      });
    }

    const blockchainInvalid =
      certificate.blockchain.enabled === true && certificate.blockchain.isValid === false;
    const blockchainErrored =
      certificate.blockchain.enabled === true &&
      certificate.blockchain.isValid === null &&
      Boolean(certificate.blockchain.error);

    const valid = !blockchainInvalid && !blockchainErrored;

    return res.json({
      success: true,
      valid,
      message: valid
        ? 'Certificate is valid'
        : (blockchainInvalid
            ? 'Certificate hash was not found on blockchain'
            : 'Certificate verification failed on blockchain'),
      data: certificate
    });
  } catch (error) {
    return next(error);
  }
};

module.exports = { verifyCertificate };