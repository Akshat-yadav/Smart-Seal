import 'package:certificate_verifier_app/features/auth/data/models/admin_user.dart';
import 'package:certificate_verifier_app/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository);

  final AuthRepository _authRepository;

  bool _loading = false;
  String? _error;
  String? _token;
  AdminUser? _admin;

  bool get loading => _loading;
  String? get error => _error;
  String? get token => _token;
  AdminUser? get admin => _admin;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final (token, user) = await _authRepository.login(email: email, password: password);
      _token = token;
      _admin = user;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _admin = null;
    _error = null;
    notifyListeners();
  }
}