class ScoreComponent {
  final String code; // Mã thành phần (ví dụ GK, CK, BT...)
  final String value; // Giá trị điểm (nếu rỗng sẽ là "--/--")

  ScoreComponent({required this.code, required this.value});
}

class ResultModel {
  final String semester; // Kỳ học
  final String studentId; // Mã sinh viên
  final String subjectName; // Tên học phần
  final String classCode; // Mã lớp học phần
  final int? credits; // Số tín chỉ
  final String? scoreChar; // Tổng kết (điểm chữ)
  final double? score10; // Thang 10
  final double? score4; // Thang 4

  /// Công thức điểm thô (ví dụ "[GK]*0.2 + [CK]*0.8")
  final String formula;

  /// Danh sách thành phần điểm động, đúng theo công thức điểm
  final List<ScoreComponent> components;

  ResultModel({
    required this.semester,
    required this.studentId,
    required this.subjectName,
    required this.classCode,
    this.credits,
    this.scoreChar,
    this.score10,
    this.score4,
    this.formula = '',
    this.components = const [],
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }

    // API trả "Chi tiết điểm": mảng string
    // ["Công thức điểm: [GK]*0.3 + [CK]*0.7", "GK: 7.5", "CK: 8.0"]
    final List detailList = (json['Chi tiết điểm'] as List?) ?? const [];

    String formula = '';
    final List<ScoreComponent> comps = [];

    for (final e in detailList) {
      final s = (e ?? '').toString().trim();
      if (s.isEmpty) continue;
      if (s.startsWith('Công thức điểm:')) {
        formula = s.replaceFirst('Công thức điểm:', '').trim();
      } else {
        final int idx = s.indexOf(':');
        if (idx > 0) {
          final code = s.substring(0, idx).trim();
          final value = s.substring(idx + 1).trim();
          comps.add(
            ScoreComponent(code: code, value: value.isEmpty ? '--/--' : value),
          );
        }
      }
    }

    return ResultModel(
      semester: json['Kỳ học']?.toString() ?? '',
      studentId: json['Mã sinh viên']?.toString() ?? '',
      subjectName: json['Tên học phần']?.toString() ?? '',
      classCode: json['Mã lớp học phần']?.toString() ?? '',
      credits: int.tryParse(json['Số tín chỉ']?.toString() ?? ''),
      scoreChar: json['Tổng kết']?.toString(),
      score10: toDouble(json['Thang 10']),
      score4: toDouble(json['Thang 4']),
      formula: formula,
      components: comps,
    );
  }
}
