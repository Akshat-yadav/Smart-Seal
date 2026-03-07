import 'package:certificate_verifier_app/core/network/api_client.dart';
import 'package:certificate_verifier_app/features/certificate/data/models/upload_response.dart';

class CertificateRepository {
  CertificateRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<UploadResponse> uploadCertificate({
    required String token,
    required List<int> fileBytes,
    required String fileName,
    required String studentName,
    required String courseName,
    required String issuerName,
    required String issueDate,
    String? expiryDate,
  }) async {
    final fields = <String, String>{
      'studentName': studentName,
      'courseName': courseName,
      'issuerName': issuerName,
      'issueDate': issueDate,
      if (expiryDate != null && expiryDate.isNotEmpty) 'expiryDate': expiryDate,
    };

    try {
      final response = await _apiClient.multipart(
        '/upload-certificate',
        fields: fields,
        bytes: fileBytes,
        fileName: fileName,
        fileField: 'certificate',
        token: token,
      );
      return UploadResponse.fromJson(response);
    } catch (_) {
      final fallback = await _apiClient.multipart(
        '/admin/upload-certificate',
        fields: fields,
        bytes: fileBytes,
        fileName: fileName,
        fileField: 'certificate',
        token: token,
      );
      return UploadResponse.fromJson(fallback);
    }
  }
}