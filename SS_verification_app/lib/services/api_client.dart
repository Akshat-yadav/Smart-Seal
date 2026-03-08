import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  static const Duration _requestTimeout = Duration(seconds: 12);

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    try {
      final response = await http
          .get(_uri(path), headers: _headers(token: token))
          .timeout(_requestTimeout);
      return _decode(response);
    } on TimeoutException {
      throw Exception(_timeoutMessage(path));
    } on SocketException {
      throw Exception(_networkMessage());
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    String? token,
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: _headers(token: token),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(_requestTimeout);
      return _decode(response);
    } on TimeoutException {
      throw Exception(_timeoutMessage(path));
    } on SocketException {
      throw Exception(_networkMessage());
    }
  }

  Future<Map<String, dynamic>> multipart(
    String path, {
    required Map<String, String> fields,
    required List<int> bytes,
    required String fileName,
    required String fileField,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _uri(path));
      request.headers.addAll({'Authorization': 'Bearer $token'});
      request.fields.addAll(fields);
      request.files.add(
        http.MultipartFile.fromBytes(
          fileField,
          bytes,
          filename: fileName,
          contentType: MediaType('application', 'pdf'),
        ),
      );

      final streamed = await request.send().timeout(_requestTimeout);
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on TimeoutException {
      throw Exception(_timeoutMessage(path));
    } on SocketException {
      throw Exception(_networkMessage());
    }
  }

  Map<String, String> _headers({String? token}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw Exception(body['message'] ?? 'Request failed (${response.statusCode})');
  }

  String _timeoutMessage(String path) {
    return 'Request timed out for $path. Check backend server and base URL.';
  }

  String _networkMessage() {
    return 'Cannot connect to server. Check backend is running and AppConfig.baseUrl is correct.';
  }
}

