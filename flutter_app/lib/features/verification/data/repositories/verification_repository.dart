import 'package:certificate_verifier_app/core/network/api_client.dart';
import 'package:certificate_verifier_app/features/verification/data/models/verification_result.dart';

class VerificationRepository {
  VerificationRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<VerificationResult> verifyCertificate(String certificateId) async {
    final response = await _apiClient.get('/verify/$certificateId');
    return VerificationResult.fromJson(response);
  }
}