import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatelessWidget {
  final List<String> semesters = [
    '2021.1',
    '2021.2',
    '2022.1',
    '2022.2',
    '2023.1',
    '2023.2',
    '2024.1',
    '2024.2',
  ];

  final List<FlSpot> gpaData = [
    FlSpot(0, 3),
    FlSpot(1, 3),
    FlSpot(2, 3),
    FlSpot(3, 3),
    FlSpot(4, 2),
    FlSpot(5, 1),
    FlSpot(6, 3.5),
    FlSpot(7, 2),
  ];

  final List<FlSpot> drlData = [
    FlSpot(0, 3),
    FlSpot(1, 3),
    FlSpot(2, 3),
    FlSpot(3, 3),
    FlSpot(4, 2),
    FlSpot(5, 1),
    FlSpot(6, 3.5),
    FlSpot(7, 2),
  ];

  final List<FlSpot> tcData = [
    FlSpot(0, 35),
    FlSpot(1, 70),
    FlSpot(2, 105),
    FlSpot(3, 70),
    FlSpot(4, 35),
    FlSpot(5, 0),
    FlSpot(6, 70),
    FlSpot(7, 105),
  ];

  StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double fabPadding = MediaQuery.of(context).size.width * 0.2;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thống kê', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2),
        onPressed: () {},
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GPAInfoCard(),
            buildChartCard(
              title: 'GPA',
              spots: gpaData,
              semesters: semesters,
              minY: 0,
              maxY: 4,
              interval: 1,
            ),
            const SizedBox(height: 16),
            buildChartCard(
              title: 'Điểm rèn luyện',
              spots: drlData,
              semesters: semesters,
              minY: 0,
              maxY: 4,
              interval: 1,
            ),
            const SizedBox(height: 16),
            buildChartCard(
              title: 'Số TC tích lũy',
              spots: tcData,
              semesters: semesters,
              minY: 0,
              maxY: 140,
              interval: 35,
            ),
            SizedBox(height: fabPadding),
          ],
        ),
      ),
    );
  }

  Widget buildChartCard({
    required String title,
    required List<FlSpot> spots,
    required List<String> semesters,
    required double minY,
    required double maxY,
    required double interval,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 42, 116, 189)),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220, // Fixed height for consistent layout
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 6,
                bottom: 6,
                top: 4,
              ),
              child: LineChart(
                LineChartData(
                  minY: minY,
                  maxY: maxY,
                  clipData:
                      FlClipData.all(), // Prevents tooltip from overflowing
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: interval,
                    verticalInterval: 1,
                    getDrawingHorizontalLine:
                        (value) =>
                            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                    getDrawingVerticalLine:
                        (value) =>
                            FlLine(color: Colors.grey.shade300, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              (index >= 0 && index < semesters.length)
                                  ? semesters[index]
                                  : '',
                              style: const TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        reservedSize: 28,
                        getTitlesWidget:
                            (value, meta) => Text(
                              value.toInt().toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade400),
                      left: BorderSide(color: Colors.grey.shade400),
                      right: BorderSide(color: Colors.grey.shade300),
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (value) => Colors.white,
                      tooltipBorder: BorderSide(color: Colors.grey.shade300),
                      tooltipPadding: const EdgeInsets.all(6),
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems:
                          (touchedSpots) =>
                              touchedSpots
                                  .map(
                                    (spot) => LineTooltipItem(
                                      spot.y.toStringAsFixed(2),
                                      TextStyle(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  )
                                  .toList(),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      color: const Color.fromARGB(255, 19, 61, 135),
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter:
                            (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 3.5,
                              color: Colors.white,
                              strokeWidth: 1.5,
                              strokeColor: const Color.fromARGB(
                                255,
                                19,
                                61,
                                135,
                              ),
                            ),
                      ),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GPAInfoCard extends StatelessWidget {
  const GPAInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '3.12',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Số tín chỉ tích lũy: 106'),
                  Text('Mức cảnh báo học tập: Mức 0'),
                  Text('Quá trình: Năm 4'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
