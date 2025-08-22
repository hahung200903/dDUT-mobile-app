class StatsModel {
  final double? gpa10; // thang 10
  final double? gpa4; // thang 4
  final int? totalCredits;
  final int? passedCredits;
  final int? failedCredits;

  /// Breakdown per semester
  final List<SemesterStat> bySemester;

  StatsModel({
    this.gpa10,
    this.gpa4,
    this.totalCredits,
    this.passedCredits,
    this.failedCredits,
    this.bySemester = const [],
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    double? _d(v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    int? _i(v) =>
        v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));

    final list = <SemesterStat>[];
    final raw = json['bySemester'] ?? json['semesters'] ?? json['data'];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(SemesterStat.fromJson(e));
        }
      }
    }

    return StatsModel(
      gpa10: _d(json['gpa10'] ?? json['GPA10']),
      gpa4: _d(json['gpa4'] ?? json['GPA4']),
      totalCredits: _i(json['totalCredits'] ?? json['TongTinChi']),
      passedCredits: _i(json['passedCredits'] ?? json['TinChiDat']),
      failedCredits: _i(json['failedCredits'] ?? json['TinChiRot']),
      bySemester: list,
    );
  }
}

class SemesterStat {
  final String? semester;
  final double? gpa10;
  final double? gpa4;
  final int? credits;

  SemesterStat({this.semester, this.gpa10, this.gpa4, this.credits});

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
    );
  }
}
