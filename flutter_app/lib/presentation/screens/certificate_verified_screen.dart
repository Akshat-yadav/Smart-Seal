import 'package:certificate_verifier_app/presentation/providers/verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CertificateVerifiedScreen extends StatefulWidget {
  const CertificateVerifiedScreen({super.key});

  static const routeName = '/certificate-verified';

  @override
  State<CertificateVerifiedScreen> createState() => _CertificateVerifiedScreenState();
}

class _CertificateVerifiedScreenState extends State<CertificateVerifiedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 850),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = context.watch<VerificationProvider>().result;

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Certificate Verified')),
        body: const Center(child: Text('No certificate selected.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Verified')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green.withValues(alpha: 0.15),
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.green, size: 72),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Certificate is Authentic',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _row('Certificate ID', result.certificateId),
                      _row('Student', result.studentName),
                      _row('Course', result.courseName),
                      _row('Issuer', result.issuerName),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}