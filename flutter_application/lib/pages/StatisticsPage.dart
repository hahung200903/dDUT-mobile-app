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
      headers: {
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
      backgroundColor: const Color(0xFFE7F1F9),
      appBar: AppBar(
        title: const Text('Thống kê'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A74BD),
        foregroundColor: Colors.white,
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
              onRetry: () {
                setState(() => _future = _fetchStats());
              },
            );
          }

          final data = snap.data!;
          final semesters = (data['semesters'] as List).cast<String>();
          final gpa10 =
              (data['gpaPerSemester'] as List)
                  .cast<num>()
                  .map((e) => e.toDouble())
                  .toList();
          final credits =
              (data['creditsPerSemester'] as List)
                  .cast<num>()
                  .map((e) => e.toDouble())
                  .toList();
          final overall = (data['overall'] as Map?) ?? const {};
          final overallGpa10 = (overall['gpa10'] as num?)?.toDouble();
          final totalCredits =
              (overall['totalCredits'] as num?)?.toDouble() ?? 0;

          return ListView(
            children: [
              _InfoTile(
                title: 'GPA tích lũy (thang 10)',
                subtitle: 'Tổng tín chỉ: ${totalCredits.toStringAsFixed(0)}',
                trailing: Text(
                  overallGpa10 == null ? '--' : overallGpa10.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              // GPA theo kỳ
              _SectionTile(
                title: 'GPA theo kỳ',
                child: _LineChart(
                  xLabels: semesters,
                  values: gpa10,
                  minY: 0,
                  maxY: 10,
                  yInterval: 1,
                ),
              ),

              // Tín chỉ theo kỳ
              _SectionTile(
                title: 'Tín chỉ theo kỳ',
                child: _LineChart(
                  xLabels: semesters,
                  values: credits,
                  minY: 0,
                  // maxY để auto
                  yInterval: 5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1F9),
        border: Border(
          bottom: BorderSide(color: Colors.black.withOpacity(0.05)),
          top: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Section có tiêu đề giống 1 “item header” + body là chart
class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header
        Container(
          width: double.infinity,
          color: const Color(0xFFEAF1F7),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        // body
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 16),
          child: Material(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            color: Colors.white,
            child: SizedBox(height: 220, child: child),
          ),
        ),
      ],
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
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: yInterval,
                getTitlesWidget:
                    (v, meta) => Text(
                      v.toInt().toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= xLabels.length)
                    return const SizedBox.shrink();
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
              dotData: FlDotData(show: true),
            ),
          ],
        ),
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
