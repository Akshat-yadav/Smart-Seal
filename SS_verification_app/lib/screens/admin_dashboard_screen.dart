import 'package:certificate_verifier_app/providers/auth_provider.dart';
import 'package:certificate_verifier_app/providers/upload_provider.dart';
import 'package:certificate_verifier_app/screens/home_screen.dart';
import 'package:certificate_verifier_app/screens/upload_certificate_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const routeName = '/admin-dashboard';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.read<UploadProvider>().reset();
              Navigator.pushNamedAndRemoveUntil(context, HomeScreen.routeName, (_) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome, ${auth.admin?.name ?? 'Admin'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, UploadCertificateScreen.routeName),
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Certificate'),
            ),
          ],
        ),
      ),
    );
  }
}
