import 'package:certificate_verifier_app/models/verification_result.dart';
import 'package:certificate_verifier_app/services/verification_repository.dart';
import 'package:flutter/foundation.dart';

class VerificationProvider extends ChangeNotifier {
  VerificationProvider(this._repository);

  final VerificationRepository _repository;

  bool _loading = false;
  String? _error;
  VerificationResult? _result;

  bool get loading => _loading;
  String? get error => _error;
  VerificationResult? get result => _result;

  Future<bool> verify(String certificateId) async {
    _loading = true;
    _error = null;
    _result = null;
    notifyListeners();

    try {
      _result = await _repository.verifyCertificate(certificateId);
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

  void clear() {
    _error = null;
    _result = null;
    notifyListeners();
  }
}
