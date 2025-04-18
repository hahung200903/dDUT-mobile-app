import 'package:flutter/material.dart';

class DetailResults extends StatelessWidget {
  final String subjectCode;
  final String subjectTitle;
  final String credits;
  final String details;

  const DetailResults({
    super.key,
    required this.subjectCode,
    required this.subjectTitle,
    required this.credits,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(subjectTitle),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text('Mã lớp học phần: $subjectCode'),
            Text('Số tín chỉ: $credits'),
            SizedBox(height: 10),
            Text('Công thức điểm:'),
            Text(details),
            SizedBox(height: 10),
            Text('Bài tập: --/--'),
            Text('Cuối kỳ: --/--'),
            Text('Giữa kỳ: --/--'),
            Text('Quá trình: --/--'),
            Text('Tổng kết: --/--'),
            Text('Thang 10: --/--'),
            Text('Thang 4: --/--'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Đóng'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}