class UploadResponse {
  const UploadResponse({
    required this.certificateId,
    required this.fileHash,
    required this.verificationUrl,
    required this.processedCertificateUrl,
    required this.qrCodeUrl,
    required this.blockchainEnabled,
    required this.blockchainStored,
    this.blockchainTxHash,
    this.blockchainError,
  });

  final String certificateId;
  final String fileHash;
  final String verificationUrl;
  final String processedCertificateUrl;
  final String qrCodeUrl;
  final bool blockchainEnabled;
  final bool blockchainStored;
  final String? blockchainTxHash;
  final String? blockchainError;

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final blockchain =
        (data['blockchain'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return UploadResponse(
      certificateId: (data['certificateId'] ?? '').toString(),
      fileHash: (data['fileHash'] ?? '').toString(),
      verificationUrl: (data['verificationUrl'] ?? '').toString(),
      processedCertificateUrl: (data['processedCertificateUrl'] ?? '').toString(),
      qrCodeUrl: (data['qrCodeUrl'] ?? '').toString(),
      blockchainEnabled: blockchain['enabled'] == true,
      blockchainStored: blockchain['stored'] == true,
      blockchainTxHash: blockchain['txHash']?.toString(),
      blockchainError: blockchain['error']?.toString(),
    );
  }
}