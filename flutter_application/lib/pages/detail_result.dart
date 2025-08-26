import 'package:flutter/material.dart';

class DetailResults extends StatelessWidget {
  final String subjectCode; // Mã lớp học phần
  final String subjectTitle; // Tên học phần
  final String credits; // Số tín chỉ

  final List<String>? detailsList;

  final String? congThucDiem;
  final String? diemBT;
  final String? diemGK;
  final String? diemCK;
  final String? diemQT;

  final String? tongKet; // điểm chữ (vd: "A", "B+")
  final String? thang10; // "8.00"
  final String? thang4; // "3.20"

  const DetailResults({
    super.key,
    required this.subjectCode,
    required this.subjectTitle,
    required this.credits,
    this.detailsList,
    this.congThucDiem,
    this.diemBT,
    this.diemGK,
    this.diemCK,
    this.diemQT,
    this.tongKet,
    this.thang10,
    this.thang4,
  });

  static const _placeholder = '--/--';

  @override
  Widget build(BuildContext context) {
    final parsed = _parseDetails(detailsList);

    final ct = _firstNonEmpty([congThucDiem, parsed['CongThucDiem']]);
    final bt = _firstNonEmpty([diemBT, parsed['BT']]);
    final gk = _firstNonEmpty([diemGK, parsed['GK']]);
    final ck = _firstNonEmpty([diemCK, parsed['CK']]);
    final qt = _firstNonEmpty([diemQT, parsed['QT']]);

    final tk = _firstNonEmpty([tongKet]);
    final t10 = _firstNonEmpty([thang10]);
    final t4 = _firstNonEmpty([thang4]);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
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
                Center(
                  child: Text(
                    subjectTitle,
                    textAlign: TextAlign.center,
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

          // Body
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
                _buildInfoRow('Mã lớp học phần:', subjectCode),
                const SizedBox(height: 8.0),

                _buildInfoRow('Số tín chỉ:', credits),
                const SizedBox(height: 8.0),

                _buildInfoRow('Công thức điểm:', _displayOrPlaceholder(ct)),
                const SizedBox(height: 8.0),

                _buildInfoRow('Bài tập:', _displayOrPlaceholder(bt)),
                const SizedBox(height: 6.0),

                _buildInfoRow('Cuối kỳ:', _displayOrPlaceholder(ck)),
                const SizedBox(height: 6.0),

                _buildInfoRow('Giữa kỳ:', _displayOrPlaceholder(gk)),
                const SizedBox(height: 6.0),

                _buildInfoRow('Quá trình:', _displayOrPlaceholder(qt)),
                const SizedBox(height: 6.0),

                _buildInfoRow('Tổng kết:', _displayOrPlaceholder(tk)),
                const SizedBox(height: 6.0),

                _buildInfoRow('Thang 10:', _displayOrPlaceholder(t10)),
                const SizedBox(height: 6.0),

                _buildInfoRow('Thang 4:', _displayOrPlaceholder(t4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Parse mảng "Chi tiết điểm" từ API để rút ra:
  /// - "CongThucDiem": chuỗi công thức
  /// - BT/GK/CK/QT: các điểm thành phần
  Map<String, String> _parseDetails(List<String>? list) {
    final out = <String, String>{};
    if (list == null || list.isEmpty) return out;

    for (final raw in list) {
      final s = raw.trim();
      if (s.isEmpty) continue;

      // Công thức điểm: "Công thức điểm: [GK]*0.2 + [BT]*0.2 + [CK]*0.6"
      if (s.toLowerCase().startsWith('công thức điểm')) {
        final idx = s.indexOf(':');
        out['CongThucDiem'] = idx >= 0 ? s.substring(idx + 1).trim() : s;
        continue;
      }

      // Chuỗi dạng "GK: 8.0", "BT: 7.5", "CK: 6.0", "QT: 9"
      final kv = s.split(':');
      if (kv.isNotEmpty) {
        final key = kv.first.trim().toUpperCase();
        final value = kv.length >= 2 ? kv.sublist(1).join(':').trim() : '';
        if (key == 'BT' || key == 'GK' || key == 'CK' || key == 'QT') {
          out[key] = value;
        }
      }
    }
    return out;
  }

  static String _firstNonEmpty(List<String?> items) {
    for (final v in items) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static String _displayOrPlaceholder(String s) =>
      (s.isEmpty || s == 'null') ? _placeholder : s;

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140.0,
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
