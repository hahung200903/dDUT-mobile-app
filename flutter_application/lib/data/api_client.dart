import 'dart:convert';
import 'dart:io' show HttpHeaders;
import 'package:http/http.dart' as http;

const String _apiFromEnvironment = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  late final String baseUrl = () {
    if (_apiFromEnvironment.isNotEmpty) return _apiFromEnvironment;
    throw Exception('Missing API_BASE_URL');
  }();

  Map<String, String> _defaultHeaders([Map<String, String>? headers]) => {
    HttpHeaders.acceptHeader: 'application/json',
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    ...?headers,
  };

  Uri _buildUri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  /// GET trả List
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
        final v = body['data'];
        if (v is List) return v;

        for (final entry in body.entries) {
          if (entry.value is List) return entry.value as List;
        }
      }
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

  /// POST JSON
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
