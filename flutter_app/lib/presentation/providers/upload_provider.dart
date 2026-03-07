import 'package:certificate_verifier_app/features/certificate/data/models/upload_response.dart';
import 'package:certificate_verifier_app/features/certificate/data/repositories/certificate_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class UploadProvider extends ChangeNotifier {
  UploadProvider(this._repository);

  final CertificateRepository _repository;

  bool _loading = false;
  String? _error;
  UploadResponse? _response;
  PlatformFile? _selectedFile;

  bool get loading => _loading;
  String? get error => _error;
  UploadResponse? get response => _response;
  PlatformFile? get selectedFile => _selectedFile;

  Future<void> pickPdf() async {
    _error = null;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      _selectedFile = result.files.first;
      notifyListeners();
    }
  }

  Future<bool> upload({
    required String token,
    required String studentName,
    required String courseName,
    required String issuerName,
    required String issueDate,
    String? expiryDate,
  }) async {
    if (_selectedFile == null || _selectedFile!.bytes == null) {
      _error = 'Please choose a PDF file first';
      notifyListeners();
      return false;
    }

    _loading = true;
    _error = null;
    _response = null;
    notifyListeners();

    try {
      _response = await _repository.uploadCertificate(
        token: token,
        fileBytes: Uint8List.fromList(_selectedFile!.bytes!),
        fileName: _selectedFile!.name,
        studentName: studentName,
        courseName: courseName,
        issuerName: issuerName,
        issueDate: issueDate,
        expiryDate: expiryDate,
      );

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

  void reset() {
    _selectedFile = null;
    _error = null;
    _response = null;
    notifyListeners();
  }
}