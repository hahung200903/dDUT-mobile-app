import 'package:flutter/material.dart';

class DetailResults extends StatelessWidget {
  final String subjectCode; // Mã lớp học phần
  final String subjectTitle; // Tên học phần
  final String credits; // Số tín chỉ

  /// Danh sách chi tiết dạng chuỗi từ API:
  /// ["Công thức điểm: [GK]*0.20+[BT]*0.20+[CK]*0.60", "GK: 7.5", "BT: 8.0", "CK: 6.0"]
  final List<String>? detailsList;

  /// Các field cũ vẫn giữ để tương thích, nhưng sẽ được dùng như "fallback"
  /// nếu detailsList không có giá trị tương ứng.
  final String? congThucDiem;
  final String? diemBT;
  final String? diemGK;
  final String? diemCK;
  final String? diemQT;

  final String? tongKet; // điểm chữ
  final String? thang10; // "8.0"
  final String? thang4; // "3.0"

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

    // Fallback: nếu payload cũ có những giá trị lẻ (BT/GK/CK/QT) thì ghép vào
    _mergeLegacyFallback(parsed, {
      'BT': diemBT,
      'GK': diemGK,
      'CK': diemCK,
      'QT': diemQT,
    });
    parsed.formula = _firstNonEmpty([parsed.formula, congThucDiem]);

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
                _kv('Mã lớp học phần', subjectCode),
                const SizedBox(height: 8.0),

                _kv('Số tín chỉ', credits),
                const SizedBox(height: 8.0),

                _kv('Công thức điểm', _displayOrPlaceholder(parsed.formula)),
                const SizedBox(height: 8.0),

                // CÁC THÀNH PHẦN ĐỘNG THEO CÔNG THỨC
                ...parsed.components.map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: _kv(
                      _labelFor(e.key),
                      _displayOrPlaceholder(e.value),
                    ),
                  ),
                ),

                const Divider(height: 24),

                _kv('Tổng kết', _displayOrPlaceholder(tk)),
                const SizedBox(height: 6.0),

                _kv('Thang 4', _displayOrPlaceholder(t4)),
                const SizedBox(height: 6.0),

                _kv('Thang 10', _displayOrPlaceholder(t10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Kết quả phân tích `detailsList`
  /// - [formula]: chuỗi công thức (nếu có)
  /// - [components]: danh sách (giữ nguyên thứ tự xuất hiện) các cặp "MÃ" -> "điểm"
  _ParsedDetails _parseDetails(List<String>? list) {
    final comps = <MapEntry<String, String>>[];
    String formula = '';

    if (list != null && list.isNotEmpty) {
      for (final raw in list) {
        final s = raw.trim();
        if (s.isEmpty) continue;

        // Công thức điểm
        final lower = s.toLowerCase();
        if (lower.startsWith('công thức điểm')) {
          final idx = s.indexOf(':');
          formula = (idx >= 0 ? s.substring(idx + 1) : s).trim();
          continue;
        }

        // Các dòng "MÃ: value" bất kỳ (GK, BT, CK, QT, CC, DA, TH, LT, ...).
        final idx = s.indexOf(':');
        if (idx > 0) {
          final code = s.substring(0, idx).trim();
          final value = s.substring(idx + 1).trim();
          comps.add(MapEntry(code, value));
        }
      }
    }

    return _ParsedDetails(formula: formula, components: comps);
  }

  /// Ghép các giá trị lẻ kiểu cũ (BT/GK/CK/QT) vào list động nếu detailsList thiếu.
  void _mergeLegacyFallback(
    _ParsedDetails parsed,
    Map<String, String?> legacy,
  ) {
    // set hiện có để tránh thêm trùng
    final existingKeys =
        parsed.components.map((e) => e.key.toUpperCase()).toSet();
    legacy.forEach((k, v) {
      final val = _firstNonEmpty([v]);
      if (val.isNotEmpty && !existingKeys.contains(k.toUpperCase())) {
        parsed.components.add(MapEntry(k, val));
      }
    });
  }

  static String _firstNonEmpty(List<String?> items) {
    for (final v in items) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static String _displayOrPlaceholder(String s) =>
      (s.isEmpty || s == 'null') ? _placeholder : s;

  Widget _kv(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140.0,
          child: Text(
            '$label:',
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

  /// Đổi nhãn thân thiện hơn cho một số mã thành phần phổ biến.
  String _labelFor(String code) {
    switch (code.toUpperCase()) {
      case 'GK':
        return 'Giữa kỳ';
      case 'CK':
        return 'Cuối kỳ';
      case 'BT':
        return 'Bài tập';
      case 'QT':
        return 'Quá trình';
      case 'CC':
        return 'Chuyên cần';
      case 'DA':
        return 'Đồ án';
      case 'TH':
        return 'Thực hành';
      case 'LT':
        return 'Lý thuyết';
      case 'KT':
        return 'Kiểm tra';
      case 'HD':
        return 'Hướng dẫn';
      case 'BV':
        return 'Bảo vệ';
      case 'DG':
        return 'Đánh giá';
      default:
        // không biết mã -> trả nguyên mã
        return code;
    }
  }
}

/// Struct nhỏ giữ kết quả parse
class _ParsedDetails {
  String formula;
  final List<MapEntry<String, String>> components;

  _ParsedDetails({required this.formula, required this.components});
}
