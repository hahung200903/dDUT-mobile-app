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

  StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê',),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
        backgroundColor: Color(0xFF1976D2),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF1976D2),
        child: Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GPA + Info
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // GPA box
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
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Số tín chỉ tích lũy: 106'),
                        Text('Mức cảnh báo học tập: Mức 0'),
                        Text('Quá trình: Năm 4'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // GPA chart
            buildChartContainer(
              title: 'GPA',
              spots: [
                FlSpot(0, 3),
                FlSpot(1, 3),
                FlSpot(2, 3.2),
                FlSpot(3, 3),
                FlSpot(4, 2),
                FlSpot(5, 3.5),
                FlSpot(6, 2.8),
                FlSpot(7, 3.9),
              ],
              semesters: semesters,
            ),

            const SizedBox(height: 16),

            // DRL chart
            buildChartContainer(
              title: 'Điểm rèn luyện',
              spots: [
                FlSpot(0, 3),
                FlSpot(1, 3),
                FlSpot(2, 3),
                FlSpot(3, 2.5),
                FlSpot(4, 2),
                FlSpot(5, 3.5),
                FlSpot(6, 4),
                FlSpot(7, 3),
              ],
              semesters: semesters,
            ),

            const SizedBox(height: 16),

            // TC chart
            buildChartContainer(
              title: 'Số TC tích lũy',
              spots: [
                FlSpot(0, 120),
                FlSpot(1, 130),
                FlSpot(2, 125),
                FlSpot(3, 100),
                FlSpot(4, 60),
                FlSpot(5, 40),
                FlSpot(6, 80),
                FlSpot(7, 106),
              ],
              semesters: semesters,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChartContainer({
    required String title,
    required List<FlSpot> spots,
    required List<String> semesters,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade700),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        return Text(
                          (index >= 0 && index < semesters.length)
                              ? semesters[index]
                              : '',
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: Colors.blue,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
