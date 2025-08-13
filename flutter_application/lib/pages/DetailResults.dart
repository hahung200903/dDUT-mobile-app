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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2), 
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Centered title
                Center(
                  child: Text(
                    subjectTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(76),
                      ),
                      padding: const EdgeInsets.all(2.0),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFECEFF1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Two column row for Mã lớp học phần
                _buildInfoRow('Mã lớp học phần:', subjectCode),
                const SizedBox(height: 8.0),

                // Two column row for Số tín chỉ
                _buildInfoRow('Số tín chỉ:', credits),
                const SizedBox(height: 8.0),

                // Two column row for Công thức điểm
                _buildInfoRow('Công thức điểm:', details),
                const SizedBox(height: 8.0),

                // Score rows
                _buildInfoRow('Bài tập:', '10'),
                const SizedBox(height: 6.0),

                _buildInfoRow('Cuối kỳ:', '10'),
                const SizedBox(height: 6.0),

                _buildInfoRow('Giữa kỳ:', '10'),
                const SizedBox(height: 6.0),

                _buildInfoRow('Quá trình:', '10'),
                const SizedBox(height: 6.0),

                _buildInfoRow('Tổng kết:', '10'),
                const SizedBox(height: 6.0),

                _buildInfoRow('Thang 10:', '10'),
                const SizedBox(height: 6.0),

                _buildInfoRow('Thang 4:', '4'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120.0,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14.0, color: Colors.black87),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
