import 'dart:convert';
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

  SubjectResult({
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
    semesterCode: j['semesterCode'] as String,
    subjectCode: (j['subjectCode'] ?? '') as String,
    classCode: (j['classCode'] ?? '') as String,
    credits: (j['credits'] as num?)?.toInt(),
    score10: (j['score10'] as num?)?.toDouble(),
    scoreChar: j['scoreChar'] as String?,
    score4: (j['score4'] as num?)?.toDouble(),
    subjectTitle: j['subjectTitle'] as String?,
  );
}

class Stats {
  final List<String> semesters;
  final List<double> gpaPerSemester;
  final List<int> creditsPerSemester;
  final double? overallGpa10;
  final int totalCredits;

  Stats({
    required this.semesters,
    required this.gpaPerSemester,
    required this.creditsPerSemester,
    required this.overallGpa10,
    required this.totalCredits,
  });

  factory Stats.fromJson(Map<String, dynamic> j) => Stats(
    semesters: (j['semesters'] as List).cast<String>(),
    gpaPerSemester:
        (j['gpaPerSemester'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
    creditsPerSemester:
        (j['creditsPerSemester'] as List)
            .map((e) => (e as num).toInt())
            .toList(),
    overallGpa10:
        j['overall']?['gpa10'] == null
            ? null
            : (j['overall']['gpa10'] as num).toDouble(),
    totalCredits:
        j['overall']?['totalCredits'] == null
            ? 0
            : (j['overall']['totalCredits'] as num).toInt(),
  );
}

class ResultsRepository {
  final String
  baseUrl; // https://asia-southeast1-<PROJECT_ID>.cloudfunctions.net/api
  ResultsRepository(this.baseUrl);

  Future<List<SubjectResult>> fetchResults(String studentId) async {
    final uri = Uri.parse('$baseUrl/results?studentId=$studentId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('API /results failed: ${res.statusCode} ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    final list = (data['results'] as List).cast<Map<String, dynamic>>();
    return list.map((e) => SubjectResult.fromJson(e)).toList();
  }

  Future<Stats> fetchStats(String studentId) async {
    final uri = Uri.parse('$baseUrl/stats?studentId=$studentId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('API /stats failed: ${res.statusCode} ${res.body}');
    }
    return Stats.fromJson(json.decode(res.body));
  }
}
