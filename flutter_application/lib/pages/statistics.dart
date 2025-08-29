import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({
    super.key,
    required this.studentId,
    required this.apiBase,
  });

  final String studentId;
  final String apiBase;

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final uri = Uri.parse(
      '${widget.apiBase}/stats',
    ).replace(queryParameters: {'studentId': widget.studentId});
    final res = await http.get(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = json.decode(utf8.decode(res.bodyBytes));
      return body is Map<String, dynamic> ? body : {'data': body};
    }
    throw Exception(
      'Failed to fetch stats for ${widget.studentId}: '
      'ClientException: ${res.statusCode} ${res.body}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Học vụ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A74BD),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorView(
              message: 'Lỗi: ${snap.error}',
              onRetry: () => setState(() => _future = _fetchStats()),
            );
          }

          final data = snap.data!;
          final semesters = (data['semesters'] as List).cast<String>();

          // GPA từng kỳ (thang 4)
          final gpaPerSem =
              (data['gpaPerSemester'] as List)
                  .cast<num>()
                  .map((e) => e.toDouble())
                  .toList();

          // Điểm rèn luyện thang 100
          final conductScores =
              ((data['conductPerSemester'] as List?) ?? const [])
                  .cast<num>()
                  .map((e) => e.toDouble())
                  .toList();

          // TC đăng ký từng kỳ
          final credits =
              (data['creditsPerSemester'] as List)
                  .cast<num>()
                  .map((e) => e.toDouble())
                  .toList();

          // Tổng quan
          final overall = (data['overall'] as Map?) ?? const {};
          final double? overallGpa4 =
              (overall['gpa4'] as num?)?.toDouble() ??
              (overall['gpa10'] as num?)?.toDouble();
          final totalCredits =
              (overall['totalCredits'] as num?)?.toDouble() ?? 0;
          final warningLevel = overall['warningLevel'];
          final studyStage =
              (overall['stage'] ?? overall['studyStage'])?.toString();

          // Y-max cho biểu đồ tín chỉ
          double creditsYMax = () {
            if (credits.isEmpty) return 10.0;
            final maxVal = credits.reduce((a, b) => a > b ? a : b);
            final nextTen = ((maxVal ~/ 10) + 1) * 10; // 20 -> 30, 22 -> 30
            return nextTen.toDouble();
          }();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A74BD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: _BigMetricCard(
                              value:
                                  overallGpa4 == null
                                      ? '--'
                                      : overallGpa4.toStringAsFixed(2),
                              label: 'GPA (thang 4)',
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          color: const Color(0xFFFFFFFF),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            child: _InfoSummaryInline(
                              totalCredits: totalCredits,
                              warningLevel: warningLevel?.toString(),
                              studyStage: studyStage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // GPA từng kỳ thang 4
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: _ChartCard(
                  title: 'GPA từng kỳ',
                  child: _LineChart(
                    xLabels: semesters,
                    values: gpaPerSem,
                    minY: 0,
                    maxY: 4,
                    yInterval: 0.5,
                  ),
                ),
              ),

              // Điểm rèn luyện thang 100
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: _ChartCard(
                  title: 'Điểm rèn luyện từng kỳ',
                  child:
                      (conductScores.isNotEmpty)
                          ? _LineChart(
                            xLabels: semesters,
                            values: conductScores,
                            minY: 0,
                            maxY: 100,
                            yInterval: 10,
                          )
                          : const _EmptyChart(),
                ),
              ),

              // Số TC đăng ký từng kỳ
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: _ChartCard(
                  title: 'Số TC đăng ký từng kỳ',
                  child: _LineChart(
                    xLabels: semesters,
                    values: credits,
                    minY: 0,
                    maxY: creditsYMax,
                    yInterval: 5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF2A74BD), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(height: 220, child: child),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({
    required this.xLabels,
    required this.values,
    this.minY,
    this.maxY,
    this.yInterval,
  });

  final List<String> xLabels;
  final List<double> values;
  final double? minY, maxY, yInterval;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return Padding(
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              tooltipBorder: const BorderSide(
                color: Color(0xFF133D87),
                width: 1.5,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots
                    .map(
                      (spot) => LineTooltipItem(
                        spot.y.toString(),
                        const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF133D87),
                        ),
                      ),
                    )
                    .toList();
              },
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: yInterval,
                getTitlesWidget: (v, meta) {
                  final isInt = (v - v.roundToDouble()).abs() < 1e-6;
                  if (!isInt) return const SizedBox.shrink();
                  return Text(
                    v.toInt().toString(),
                    style: const TextStyle(fontSize: 11),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= xLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      xLabels[i],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: const Color(0xFF2A74BD),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigMetricCard extends StatelessWidget {
  const _BigMetricCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2A74BD),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSummaryInline extends StatelessWidget {
  const _InfoSummaryInline({
    required this.totalCredits,
    this.warningLevel,
    this.studyStage,
  });

  final double totalCredits;
  final String? warningLevel;
  final String? studyStage;

  @override
  Widget build(BuildContext context) {
    String stageDisplay = '—';
    if (studyStage != null && studyStage!.trim().isNotEmpty) {
      stageDisplay = 'năm thứ ${studyStage!}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Số tín chỉ tích lũy', totalCredits.toStringAsFixed(0)),
          const SizedBox(height: 6),
          _row('Mức cảnh báo học tập', warningLevel ?? '—'),
          const SizedBox(height: 6),
          _row('Năm học', stageDisplay),
        ],
      ),
    );
  }

  Widget _row(String l, String v) {
    return Text('$l: $v', style: const TextStyle(fontSize: 13));
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Không có dữ liệu',
        style: TextStyle(color: Colors.black.withOpacity(0.6)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lỗi: $message', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
