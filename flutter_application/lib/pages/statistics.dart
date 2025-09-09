import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../bloc/stats_bloc.dart';
import '../data/stats_repository.dart';
import '../data/api_client.dart';
import '../models/stats_model.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({
    super.key,
    required this.studentId,
    required this.apiBase,
  });

  final String studentId;
  final String apiBase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsBloc>(
      create:
          (_) =>
              StatsBloc(StatsRepository(ApiClient(baseUrl: apiBase)))
                ..add(StatsRequested(studentId: studentId)),
      child: _StatisticsView(studentId: studentId),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView({required this.studentId});
  final String studentId;

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
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          tooltip: null,
          onPressed: () => Navigator.of(context).maybePop(),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              'assets/icons/solar_bell-bold.svg',
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return _ErrorView(
              message: state.error!,
              onRetry:
                  () => context.read<StatsBloc>().add(
                    StatsRequested(studentId: studentId),
                  ),
            );
          }

          final StatsModel data = state.data!;

          final semesters = data.semesters;
          final gpaPerSem = data.gpaPerSemester; // thang 4
          final conductScores = data.conductPerSemester; // ĐRL 0-100
          final credits =
              data.creditsPerSemester.map((e) => e.toDouble()).toList();

          final double? overallGpa4 = data.gpa4 ?? data.gpa10;
          final double totalCredits = data.totalCredits.toDouble();
          final String? warningLevel = data.warningLevel;
          final String? studyStage = data.stage;

          final double creditsYMax = () {
            if (credits.isEmpty) return 10.0;
            final maxVal = credits.reduce(math.max);
            return (((maxVal ~/ 10) + 1) * 10).toDouble();
          }();

          return RefreshIndicator(
            onRefresh:
                () async => context.read<StatsBloc>().add(
                  StatsRefreshed(studentId: studentId),
                ),
            child: ListView(
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

                // GPA từng kỳ
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

                // Điểm rèn luyện
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

                // Số TC đăng ký
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
            ),
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
              getTooltipItems:
                  (touchedSpots) =>
                      touchedSpots
                          .map(
                            (spot) => LineTooltipItem(
                              spot.y.toString(),
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF133D87),
                              ),
                            ),
                          )
                          .toList(),
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
