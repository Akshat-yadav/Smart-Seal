import 'dart:convert';

String? extractCertificateIdFromQr(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic> && decoded['certificateId'] is String) {
      return decoded['certificateId'] as String;
    }
  } catch (_) {
    // Not JSON payload; treat as raw certificate id.
  }

  if (raw.trim().isEmpty) return null;
  if (raw.contains('/verify/')) {
    final parts = raw.split('/verify/');
    if (parts.length > 1 && parts.last.trim().isNotEmpty) {
      return parts.last.trim();
    }
  }

  return raw.trim();
}