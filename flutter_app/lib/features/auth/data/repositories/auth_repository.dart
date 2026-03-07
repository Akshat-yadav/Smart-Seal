import 'package:certificate_verifier_app/core/network/api_client.dart';
import 'package:certificate_verifier_app/features/auth/data/models/admin_user.dart';

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<(String token, AdminUser user)> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiClient.post(
      '/admin/login',
      body: {'email': email, 'password': password},
    );

    final data = result['data'] as Map<String, dynamic>;
    final token = (data['token'] ?? '').toString();
    final user = AdminUser.fromJson(data['admin'] as Map<String, dynamic>);
    return (token, user);
  }
}