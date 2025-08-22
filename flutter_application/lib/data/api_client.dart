import 'dart:convert';
import 'dart:io' show HttpHeaders;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

const String _apiFromEnvironment = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);
const bool _useEmulator =
    bool.hasEnvironment('USE_EMULATOR') && bool.fromEnvironment('USE_EMULATOR');

/// Deployed region (khớp backend):
const String kRegion = 'asia-southeast1';

/// Build base URL cho Functions Emulator:
///   http://<host>:5001/<projectId>/<region>/api
/// Web/desktop dùng 127.0.0.1; Android emulator dùng 10.0.2.2
String _emulatorBase(String projectId) {
  final host = kIsWeb ? '127.0.0.1' : '10.0.2.2';
  return 'http://$host:5001/$projectId/$kRegion/api';
}

class ApiClient {
  ApiClient({required this.projectId, http.Client? httpClient})
    : _client = httpClient ?? http.Client();

  final String projectId;
  final http.Client _client;

  /// Base URL quyết định theo dart-define -> emulator -> production
  late final String baseUrl = () {
    if (_apiFromEnvironment.isNotEmpty) return _apiFromEnvironment;
    if (_useEmulator) return _emulatorBase(projectId);
    return 'https://$kRegion-$projectId.cloudfunctions.net/api';
  }();

  Map<String, String> _defaultHeaders([Map<String, String>? headers]) => {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    ...?headers,
  };

  Uri _buildUri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  /// GET trả List (tự động bóc field List trong object – ví dụ "Kết quả học tập": [...])
  Future<List<dynamic>> getList(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, query);
    final res = await _client.get(uri, headers: _defaultHeaders(headers));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(utf8.decode(res.bodyBytes));
      if (body is List) return body;

      if (body is Map) {
        // Ưu tiên field 'data', nếu không có thì lấy field đầu tiên là List
        final v = body['data'];
        if (v is List) return v;

        for (final entry in body.entries) {
          if (entry.value is List) return entry.value as List;
        }
      }
      // fallback: bọc body vào List
      return [body];
    }

    throw Exception('GET $uri failed: ${res.statusCode} ${res.body}');
  }

  /// GET trả Map
  Future<Map<String, dynamic>> getObject(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, query);
    final res = await _client.get(uri, headers: _defaultHeaders(headers));

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(utf8.decode(res.bodyBytes));
      return body is Map<String, dynamic> ? body : {'data': body};
    }

    throw Exception('GET $uri failed: ${res.statusCode} ${res.body}');
  }

  /// POST JSON (nếu cần thêm về sau)
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = _buildUri(path, query);
    final res = await _client.post(
      uri,
      headers: _defaultHeaders(headers),
      body: body == null ? null : jsonEncode(body),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(utf8.decode(res.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }

    throw Exception('POST $uri failed: ${res.statusCode} ${res.body}');
  }

  void close() => _client.close();
}
