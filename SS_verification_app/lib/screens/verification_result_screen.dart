import 'package:certificate_verifier_app/providers/verification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VerificationResultScreen extends StatefulWidget {
  const VerificationResultScreen({super.key});

  static const routeName = '/verification-result';

  @override
  State<VerificationResultScreen> createState() => _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Result')),
      body: Consumer<VerificationProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _AnimatedStatusCard(
                  controller: _controller,
                  success: false,
                  title: 'Verification Failed',
                  subtitle: provider.error!,
                ),
              ),
            );
          }

          final result = provider.result;
          if (result == null) {
            return const Center(child: Text('No verification data'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _AnimatedStatusCard(
                  controller: _controller,
                  success: result.valid,
                  title: result.valid ? 'Certificate Verified' : 'Certificate Invalid',
                  subtitle: result.message,
                ),
                const SizedBox(height: 16),
                _info('Certificate ID', result.certificateId),
                _info('Student Name', result.studentName),
                _info('Course Name', result.courseName),
                _info('Issuer Name', result.issuerName),
                _info('SHA256 Hash', result.fileHash),
                if (result.blockchainEnabled) ...[
                  _info(
                    'Blockchain Check',
                    result.blockchainValid == true
                        ? 'Verified on-chain'
                        : (result.blockchainValid == false
                            ? 'Hash not found on-chain'
                            : 'Blockchain check unavailable'),
                  ),
                  if ((result.blockchainTxHash ?? '').isNotEmpty)
                    _info('Blockchain Tx Hash', result.blockchainTxHash!),
                  if ((result.blockchainChainId ?? '').isNotEmpty)
                    _info('Chain ID', result.blockchainChainId!),
                  if ((result.blockchainError ?? '').isNotEmpty)
                    _info('Blockchain Error', result.blockchainError!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _info(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value.isEmpty ? '-' : value),
      ),
    );
  }
}

class _AnimatedStatusCard extends StatelessWidget {
  const _AnimatedStatusCard({
    required this.controller,
    required this.success,
    required this.title,
    required this.subtitle,
  });

  final AnimationController controller;
  final bool success;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final icon = success ? Icons.verified_rounded : Icons.error_rounded;
    final color = success ? Colors.green : Colors.red;

    return ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      child: Card(
        color: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Icon(icon, key: ValueKey(icon), size: 70, color: color),
              ),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
              const SizedBox(height: 6),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
