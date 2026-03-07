import 'package:certificate_verifier_app/presentation/providers/verification_provider.dart';
import 'package:certificate_verifier_app/presentation/screens/admin_login_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/certificate_verified_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/qr_scanner_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/verification_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _verifyManual(BuildContext context) async {
    final certId = _manualController.text.trim();
    if (certId.isEmpty) return;

    final provider = context.read<VerificationProvider>();
    final ok = await provider.verify(certId);
    if (!context.mounted) return;

    if (ok && provider.result?.valid == true) {
      Navigator.pushNamed(context, CertificateVerifiedScreen.routeName);
      return;
    }

    Navigator.pushNamed(context, VerificationResultScreen.routeName);
    if (!ok && provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerificationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate Verifier')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.surface, theme.colorScheme.surfaceContainerLowest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Public Verification', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Scan QR or enter certificate ID to validate authenticity.', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, QrScannerScreen.routeName),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan QR Code'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _manualController,
                  decoration: const InputDecoration(labelText: 'Certificate ID'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: provider.loading ? null : () => _verifyManual(context),
                  icon: provider.loading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: const Text('Verify Certificate'),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, AdminLoginScreen.routeName),
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Admin Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}