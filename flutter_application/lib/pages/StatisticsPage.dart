import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/results_repository.dart';

class StatisticsPage extends StatefulWidget {
  final String studentId;
  final String apiBase;
  const StatisticsPage({
    super.key,
    required this.studentId,
    required this.apiBase,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late final ResultsRepository repo;
  Future<Stats>? f;

  @override
  void initState() {
    super.initState();
    repo = ResultsRepository(widget.apiBase);
    f = repo.fetchStats(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F1F9),
      appBar: AppBar(
          title: const Text('Thống kê'),
          backgroundColor: Color(0xFF2A74BD),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18)),
      body: FutureBuilder<Stats>(
        future: f,
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
            return const Center(child: CircularProgressIndicator());
          }
          final s = snap.data!;
          final spots = <FlSpot>[];
          for (var i = 0; i < s.gpaPerSemester.length; i++) {
            spots.add(FlSpot(i.toDouble(), s.gpaPerSemester[i]));
          }
          final minY = (spots
                      .map((e) => e.y)
                      .fold<double>(10, (m, v) => v < m ? v : m) -
                  0.5)
              .clamp(0, 10);
          final maxY = (spots
                      .map((e) => e.y)
                      .fold<double>(0, (m, v) => v > m ? v : m) +
                  0.5)
              .clamp(0, 10);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'GPA tích luỹ: ${s.overallGpa10?.toStringAsFixed(2) ?? '-'}',
                ),
                Text('Tổng tín chỉ tích luỹ: ${s.totalCredits}'),
                const SizedBox(height: 12),
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: minY.toDouble(),
                      maxY: maxY.toDouble(),
                      lineBarsData: [
                        LineChartBarData(spots: spots, isCurved: true),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (i < 0 || i >= s.semesters.length) {
                                return const SizedBox.shrink();
                              }
                              return Transform.rotate(
                                angle: -0.6,
                                child: Text(
                                  s.semesters[i],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
