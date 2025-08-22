class ResultModel {
  final String? subjectCode;
  final String? subjectName;
  final int? credits;
  final String? semester; // kì học
  final int? attempt;
  final double? score10; // thang 10
  final double? score4; // thang 4
  final String? letter; // điểm chữ A B C D F
  final bool? passed;

  ResultModel({
    this.subjectCode,
    this.subjectName,
    this.credits,
    this.semester,
    this.attempt,
    this.score10,
    this.score4,
    this.letter,
    this.passed,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    bool? toBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      final s = v.toString().toLowerCase();
      return s == 'true' || s == '1' || s == 'y';
    }

    return ResultModel(
      subjectCode: json['subjectCode'] ?? json['MaMH'] ?? json['code'],
      subjectName: json['subjectName'] ?? json['TenMH'] ?? json['name'],
      credits: toInt(json['credits'] ?? json['SoTinChi']),
      semester: json['semester'] ?? json['HocKy'] ?? json['term'],
      attempt: toInt(json['attempt'] ?? json['LanThi']),
      score10: toDouble(json['score10'] ?? json['Diem10'] ?? json['score']),
      score4: toDouble(json['score4'] ?? json['Diem4']),
      letter: json['letter'] ?? json['DiemChu'],
      passed: toBool(json['passed'] ?? json['Dat']),
    );
  }
}
