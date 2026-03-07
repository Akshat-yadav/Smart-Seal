import 'package:certificate_verifier_app/core/utils/qr_parser.dart';
import 'package:certificate_verifier_app/presentation/providers/verification_provider.dart';
import 'package:certificate_verifier_app/presentation/screens/certificate_verified_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/verification_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  static const routeName = '/qr-scanner';

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _processing = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    final certificateId = extractCertificateIdFromQr(raw);
    if (certificateId == null || certificateId.isEmpty) return;

    setState(() => _processing = true);
    final provider = context.read<VerificationProvider>();
    final ok = await provider.verify(certificateId);
    if (!mounted) return;

    if (ok && provider.result?.valid == true) {
      Navigator.pushReplacementNamed(context, CertificateVerifiedScreen.routeName);
    } else {
      Navigator.pushReplacementNamed(context, VerificationResultScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Align QR inside frame to verify certificate'),
                ),
              ),
            ),
          ),
          if (_processing)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Verifying...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}