import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class SubjectResult {
  final String semesterCode;
  final String subjectCode;
  final String classCode;
  final int? credits;
  final double? score10;
  final String? scoreChar;
  final double? score4;
  final String? subjectTitle;

  const SubjectResult({
    required this.semesterCode,
    required this.subjectCode,
    required this.classCode,
    this.credits,
    this.score10,
    this.scoreChar,
    this.score4,
    this.subjectTitle,
  });

  factory SubjectResult.fromJson(Map<String, dynamic> j) => SubjectResult(
        semesterCode: (j['semesterCode'] ?? '') as String,
        subjectCode: (j['subjectCode'] ?? '') as String,
        classCode: (j['classCode'] ?? '') as String,
        credits: (j['credits'] as num?)?.toInt(),
        score10: (j['score10'] as num?)?.toDouble(),
        scoreChar: j['scoreChar'] as String?,
        score4: (j['score4'] as num?)?.toDouble(),
        subjectTitle: j['subjectTitle'] as String?,
      );
}

/// Repository ONLY for /results
/// baseUrl phải là endpoint của Cloud Functions (đã có /api ở cuối),
/// ví dụ:
///   - Emulator (web):  http://127.0.0.1:5001/<projectId>/asia-southeast1/api
///   - Emulator (android): http://10.0.2.2:5001/<projectId>/asia-southeast1/api
///   - Production: https://asia-southeast1-<projectId>.cloudfunctions.net/api
class ResultsRepository {
  final String baseUrl;
  final http.Client _client;

  ResultsRepository(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  Map<String, String> get _headers => const {
        HttpHeaders.acceptHeader: 'application/json',
      };

  Uri _u(String path, [Map<String, String?> q = const {}]) {
    final base = Uri.parse(baseUrl);

    // join base + path safely (avoid double slashes)
    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final joined = '${base.origin}$basePath${path.startsWith('/') ? path : '/$path'}';

    // build query without null/empty values
    final qp = <String, String>{};
    q.forEach((k, v) {
      if (v != null && v.isNotEmpty) qp[k] = v;
    });

    return Uri.parse(joined).replace(queryParameters: qp);
  }

  // Helpers parse an toàn kiểu số/chuỗi
  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse('$v');
  }

  String _toStr(dynamic v) => v?.toString() ?? '';

  /// Chuẩn hoá một item từ payload (VN/EN) về schema SubjectResult
  Map<String, dynamic> _normalizeItem(Map raw) {
    // Ưu tiên key EN nếu có, fallback sang key VN được SQL alias:
    // "Kỳ học", "Mã lớp học phần", "Số tín chỉ", "Thang 10", "Thang 4", "Tổng kết", "Tên học phần"
    final semesterCode = raw['semesterCode'] ?? raw['Kỳ học'];
    final classCode = raw['classCode'] ?? raw['Mã lớp học phần'];
    final credits = raw['credits'] ?? raw['Số tín chỉ'];
    final score10 = raw['score10'] ?? raw['Thang 10'];
    final score4 = raw['score4'] ?? raw['Thang 4'];
    final scoreChar = raw['scoreChar'] ?? raw['Tổng kết'];
    final subjectTitle = raw['subjectTitle'] ?? raw['Tên học phần'];

    // subjectCode không có trong SELECT, để rỗng
    return {
      'semesterCode': _toStr(semesterCode),
      'subjectCode': _toStr(raw['subjectCode']), // có thể rỗng
      'classCode': _toStr(classCode),
      'credits': _toInt(credits),
      'score10': _toDouble(score10),
      'score4': _toDouble(score4),
      'scoreChar': scoreChar == null ? null : _toStr(scoreChar),
      'subjectTitle': subjectTitle == null ? null : _toStr(subjectTitle),
    };
  }

  /// Fetch results for a student
  /// Hỗ trợ nhiều dạng response:
  ///   - { "Kết quả học tập": [...] } (Cloud Functions của bạn)  ← recommended
  ///   - { "results": [...] }, { "data": [...] }, hoặc `[...]` ở root
  Future<List<SubjectResult>> fetchResults(String studentId) async {
    final uri = _u('/results', {'studentId': studentId});

    final res = await _client
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 20),
            onTimeout: () => http.Response('Request timeout', 408));

    if (res.statusCode != 200) {
      throw HttpException('GET $uri failed [${res.statusCode}]: ${res.body}');
    }

    final decoded = json.decode(utf8.decode(res.bodyBytes));

    List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      list = (decoded['Kết quả học tập'] as List?) ??
          (decoded['results'] as List?) ??
          (decoded['data'] as List?) ??
          const [];
    } else {
      list = const [];
    }

    return list
        .whereType<Map>()
        .map((e) => _normalizeItem(e))
        .map((m) => SubjectResult.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
