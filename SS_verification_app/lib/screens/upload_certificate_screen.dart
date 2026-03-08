import 'package:certificate_verifier_app/providers/auth_provider.dart';
import 'package:certificate_verifier_app/providers/upload_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UploadCertificateScreen extends StatefulWidget {
  const UploadCertificateScreen({super.key});

  static const routeName = '/upload-certificate';

  @override
  State<UploadCertificateScreen> createState() =>
      _UploadCertificateScreenState();
}

class _UploadCertificateScreenState extends State<UploadCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _issuerNameController = TextEditingController();
  final _issueDateController = TextEditingController();
  final _expiryDateController = TextEditingController();

  DateTime? _issueDate;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _studentNameController.dispose();
    _courseNameController.dispose();
    _issuerNameController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  DateTime _todayDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _dateOnly(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _toBackendIsoUtc(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day).toIso8601String();
  }

  Future<void> _pickIssueDate() async {
    final today = _todayDateOnly();
    final selected = _issueDate ?? today;
    final initial = selected.isAfter(today) ? today : selected;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: today,
    );

    if (picked == null) return;

    setState(() {
      _issueDate = picked;
      _issueDateController.text = _dateOnly(picked);

      if (_expiryDate != null && _expiryDate!.isBefore(picked)) {
        _expiryDate = null;
        _expiryDateController.clear();
      }
    });
  }

  Future<void> _pickExpiryDate() async {
    final base = _issueDate ?? _todayDateOnly();
    final selected = _expiryDate ?? base;
    final initial = selected.isBefore(base) ? base : selected;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: base,
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _expiryDate = picked;
      _expiryDateController.text = _dateOnly(picked);
    });
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;

    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose Issue Date')),
      );
      return;
    }

    final today = _todayDateOnly();
    if (_issueDate!.isAfter(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Issue Date cannot be in the future')),
      );
      return;
    }

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login again')),
      );
      return;
    }

    final provider = context.read<UploadProvider>();
    final ok = await provider.upload(
      token: token,
      studentName: _studentNameController.text.trim(),
      courseName: _courseNameController.text.trim(),
      issuerName: _issuerNameController.text.trim(),
      issueDate: _toBackendIsoUtc(_issueDate!),
      expiryDate: _expiryDate == null ? null : _toBackendIsoUtc(_expiryDate!),
    );

    if (!mounted) return;

    if (ok) {
      _studentNameController.clear();
      _courseNameController.clear();
      _issuerNameController.clear();
      _issueDateController.clear();
      _expiryDateController.clear();
      _issueDate = null;
      _expiryDate = null;
      provider.clearFormAfterSuccess();
      return;
    }

    if (provider.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Certificate')),
      body: Consumer<UploadProvider>(
        builder: (context, upload, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _field(_studentNameController, 'Student Name'),
                      const SizedBox(height: 10),
                      _field(_courseNameController, 'Course Name'),
                      const SizedBox(height: 10),
                      _field(_issuerNameController, 'Issuer Name'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _issueDateController,
                        readOnly: true,
                        onTap: upload.loading ? null : _pickIssueDate,
                        decoration: InputDecoration(
                          labelText: 'Issue Date',
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              _issueDate == null) {
                            return 'Issue Date is required';
                          }
                          if (_issueDate!.isAfter(_todayDateOnly())) {
                            return 'Issue Date cannot be in the future';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _expiryDateController,
                        readOnly: true,
                        onTap: upload.loading ? null : _pickExpiryDate,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date (Optional)',
                          hintText: 'YYYY-MM-DD',
                          suffixIcon: const Icon(Icons.calendar_today_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed:
                            upload.loading ? null : () => upload.pickPdf(),
                        icon: const Icon(Icons.picture_as_pdf_rounded),
                        label: Text(upload.selectedFile?.name ?? 'Choose PDF'),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: upload.loading ? null : _upload,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Upload Certificate'),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: upload.response != null
                            ? _statusCard(
                                key: const ValueKey('success'),
                                success: true,
                                title: 'Upload Successful',
                                message:
                                    'Certificate ID: ${upload.response!.certificateId}',
                              )
                            : (upload.error != null
                                ? _statusCard(
                                    key: const ValueKey('error'),
                                    success: false,
                                    title: 'Upload Failed',
                                    message: upload.error!,
                                  )
                                : const SizedBox.shrink()),
                      ),
                      if (upload.response?.blockchainEnabled == true)
                        _statusCard(
                          key: const ValueKey('chain'),
                          success: upload.response!.blockchainStored,
                          title: upload.response!.blockchainStored
                              ? 'Blockchain Write Successful'
                              : 'Blockchain Write Failed',
                          message: upload.response!.blockchainStored
                              ? 'Tx: ${upload.response!.blockchainTxHash ?? '-'}'
                              : (upload.response!.blockchainError ??
                                  'Unknown error'),
                        ),
                    ],
                  ),
                ),
              ),
              if (upload.loading)
                const ColoredBox(
                  color: Colors.black38,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text('Uploading certificate...',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusCard({
    required Key key,
    required bool success,
    required String title,
    required String message,
  }) {
    final color = success ? Colors.green : Colors.red;
    final icon = success ? Icons.check_circle_rounded : Icons.cancel_rounded;

    return Card(
      key: key,
      color: color.withValues(alpha: 0.1),
      child: ListTile(
        leading: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.7, end: 1),
          duration: const Duration(milliseconds: 350),
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        subtitle: Text(message),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (label.contains('Optional')) return null;
        if (value == null || value.trim().isEmpty) {
          return '$label is required';
        }
        return null;
      },
    );
  }
}
