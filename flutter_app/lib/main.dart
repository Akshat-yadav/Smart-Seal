import 'package:certificate_verifier_app/core/config/app_config.dart';
import 'package:certificate_verifier_app/core/network/api_client.dart';
import 'package:certificate_verifier_app/features/auth/data/repositories/auth_repository.dart';
import 'package:certificate_verifier_app/features/certificate/data/repositories/certificate_repository.dart';
import 'package:certificate_verifier_app/features/verification/data/repositories/verification_repository.dart';
import 'package:certificate_verifier_app/presentation/providers/auth_provider.dart';
import 'package:certificate_verifier_app/presentation/providers/upload_provider.dart';
import 'package:certificate_verifier_app/presentation/providers/verification_provider.dart';
import 'package:certificate_verifier_app/presentation/screens/admin_dashboard_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/admin_login_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/certificate_verified_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/home_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/qr_scanner_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/upload_certificate_screen.dart';
import 'package:certificate_verifier_app/presentation/screens/verification_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  final apiClient = ApiClient(baseUrl: AppConfig.baseUrl);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthRepository(apiClient))),
        ChangeNotifierProvider(
          create: (_) => VerificationProvider(VerificationRepository(apiClient)),
        ),
        ChangeNotifierProvider(
          create: (_) => UploadProvider(CertificateRepository(apiClient)),
        ),
      ],
      child: const CertificateApp(),
    ),
  );
}

class CertificateApp extends StatelessWidget {
  const CertificateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Certificate Verifier',
      theme: ThemeData(
        colorScheme: scheme,
        useMaterial3: true,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      initialRoute: HomeScreen.routeName,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        QrScannerScreen.routeName: (_) => const QrScannerScreen(),
        CertificateVerifiedScreen.routeName: (_) => const CertificateVerifiedScreen(),
        VerificationResultScreen.routeName: (_) => const VerificationResultScreen(),
        AdminLoginScreen.routeName: (_) => const AdminLoginScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        UploadCertificateScreen.routeName: (_) => const UploadCertificateScreen(),
      },
    );
  }
}