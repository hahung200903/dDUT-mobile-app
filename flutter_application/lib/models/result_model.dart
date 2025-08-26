class ResultModel {
  final String semester; // Kỳ học
  final String studentId; // Mã sinh viên
  final String subjectName; // Tên học phần
  final String classCode; // Mã lớp học phần
  final int? credits; // Số tín chỉ
  final String? formula; // Công thức điểm
  final String? scoreChar; // Tổng kết (điểm chữ)
  final double? score10; // Thang 10
  final double? score4; // Thang 4

  // Nếu bạn muốn hiển thị chi tiết điểm trong DetailResults
  // thì có thể giữ thêm mảng này, mặc định rỗng
  final List<String> detailLines;

  ResultModel({
    required this.semester,
    required this.studentId,
    required this.subjectName,
    required this.classCode,
    this.credits,
    this.formula,
    this.scoreChar,
    this.score10,
    this.score4,
    this.detailLines = const [],
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      final s = v.toString().replaceAll(',', '.');
      return double.tryParse(s);
    }

    return ResultModel(
      semester: json['Kỳ học']?.toString() ?? '',
      studentId: json['Mã sinh viên']?.toString() ?? '',
      subjectName: json['Tên học phần']?.toString() ?? '',
      classCode: json['Mã lớp học phần']?.toString() ?? '',
      credits: int.tryParse(json['Số tín chỉ']?.toString() ?? ''),
      formula: json['Công thức điểm']?.toString(),
      scoreChar: json['Tổng kết']?.toString(),
      score10: toDouble(json['Thang 10']),
      score4: toDouble(json['Thang 4']),
      // nếu API trả thêm "Chi tiết điểm"
      detailLines:
          (json['Chi tiết điểm'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}
