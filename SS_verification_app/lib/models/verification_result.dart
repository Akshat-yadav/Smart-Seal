class VerificationResult {
  const VerificationResult({
    required this.valid,
    required this.message,
    required this.certificateId,
    required this.studentName,
    required this.courseName,
    required this.issuerName,
    required this.fileHash,
    this.processedCertificateUrl,
    this.qrCodeUrl,
    required this.blockchainEnabled,
    this.blockchainValid,
    this.blockchainTxHash,
    this.blockchainError,
    this.blockchainChainId,
  });

  final bool valid;
  final String message;
  final String certificateId;
  final String studentName;
  final String courseName;
  final String issuerName;
  final String fileHash;
  final String? processedCertificateUrl;
  final String? qrCodeUrl;
  final bool blockchainEnabled;
  final bool? blockchainValid;
  final String? blockchainTxHash;
  final String? blockchainError;
  final String? blockchainChainId;

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final blockchain =
        (data['blockchain'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return VerificationResult(
      valid: json['valid'] == true,
      message: (json['message'] ?? '').toString(),
      certificateId: (data['certificateId'] ?? '').toString(),
      studentName: (data['studentName'] ?? '').toString(),
      courseName: (data['courseName'] ?? '').toString(),
      issuerName: (data['issuerName'] ?? '').toString(),
      fileHash: (data['fileHash'] ?? '').toString(),
      processedCertificateUrl: data['processedCertificateUrl']?.toString(),
      qrCodeUrl: data['qrCodeUrl']?.toString(),
      blockchainEnabled: blockchain['enabled'] == true,
      blockchainValid:
          blockchain.containsKey('isValid') ? blockchain['isValid'] as bool? : null,
      blockchainTxHash: blockchain['txHash']?.toString(),
      blockchainError: blockchain['error']?.toString(),
      blockchainChainId: blockchain['chainId']?.toString(),
    );
  }
}
