class StatsModel {
  // Overall
  final double? gpa4; // GPA thang 4
  final double? gpa10; // GPA thang 10
  final int totalCredits; // tổng TC đăng ký
  // final int? passedCredits;
  // final int? failedCredits;
  final String? stage; // Năm học
  final String? warningLevel;

  final List<String> semesters;
  final List<double> gpaPerSemester; // GPA thang 4
  final List<double> conductPerSemester; // ĐRL thang 100
  final List<int> creditsPerSemester;

  /// Breakdown theo kỳ
  final List<SemesterStat> bySemester;

  StatsModel({
    this.gpa4,
    this.gpa10,
    required this.totalCredits,
    // this.passedCredits,
    // this.failedCredits,
    this.stage,
    this.warningLevel,
    this.semesters = const [],
    this.gpaPerSemester = const [],
    this.conductPerSemester = const [],
    this.creditsPerSemester = const [],
    this.bySemester = const [],
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    double? _d(v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    int? _i(v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));
    String? _s(v) => v == null ? null : '$v';

    List<String> _strList(v) =>
        (v is List ? v.map((e) => '$e').toList() : const <String>[]);
    List<double> _doubleList(v) =>
        (v is List)
            ? v
                .map((e) => (e is num ? e.toDouble() : double.tryParse('$e')))
                .whereType<double>()
                .toList()
            : const <double>[];
    List<int> _intList(v) =>
        (v is List)
            ? v
                .map((e) => (e is num ? e.toInt() : int.tryParse('$e')))
                .whereType<int>()
                .toList()
            : const <int>[];

    final semesters = _strList(json['semesters']);
    final gpaPerSem = _doubleList(json['gpaPerSemester']);
    final conductPerSem = _doubleList(json['conductPerSemester']);
    final creditsPerSem = _intList(json['creditsPerSemester']);

    final ov = (json['overall'] as Map?) ?? const {};
    final gpa4 = _d(ov['gpa4']) ?? _d(ov['gpa10']);
    final gpa10 = _d(ov['gpa10']);
    final totalCredits = _i(ov['totalCredits']) ?? 0;
    final stage = _s(ov['stage'] ?? ov['studyStage']);
    final warningLevel = _s(ov['warningLevel']);

    final n = [
      semesters.length,
      gpaPerSem.length,
      creditsPerSem.length,
      conductPerSem.length,
    ].where((x) => x > 0).fold<int>(1 << 30, (a, b) => a < b ? a : b);

    final bySemester = <SemesterStat>[];
    for (var i = 0; i < (n == (1 << 30) ? 0 : n); i++) {
      bySemester.add(
        SemesterStat(
          semester: i < semesters.length ? semesters[i] : null,
          gpa4: i < gpaPerSem.length ? gpaPerSem[i] : null,
          // gpa10: null,
          credits: i < creditsPerSem.length ? creditsPerSem[i] : null,
          conduct: i < conductPerSem.length ? conductPerSem[i] : null,
        ),
      );
    }

    return StatsModel(
      gpa4: gpa4,
      gpa10: gpa10,
      totalCredits: totalCredits,
      // passedCredits: _i(json['passedCredits'] ?? json['TinChiDat']),
      // failedCredits: _i(json['failedCredits'] ?? json['TinChiRot']),
      stage: stage,
      warningLevel: warningLevel,
      semesters: semesters,
      gpaPerSemester: gpaPerSem,
      conductPerSemester: conductPerSem,
      creditsPerSemester: creditsPerSem,
      bySemester: bySemester,
    );
  }
}

class SemesterStat {
  final String? semester;
  final double? gpa10;
  final double? gpa4; // GPA thang 4
  final int? credits; // Tín chỉ
  final double? conduct; // ĐRL 0-100

  SemesterStat({
    this.semester,
    this.gpa10,
    this.gpa4,
    this.credits,
    this.conduct,
  });

  factory SemesterStat.fromJson(Map<String, dynamic> json) {
    double? _d(v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    int? _i(v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));

    return SemesterStat(
      semester: json['semester'] ?? json['HocKy'] ?? json['term'],
      gpa10: _d(json['gpa10'] ?? json['GPA10']),
      gpa4: _d(json['gpa4'] ?? json['GPA4']),
      credits: _i(json['credits'] ?? json['TinChi']),
      conduct: _d(json['conduct'] ?? json['DiemRL']),
    );
  }
}
