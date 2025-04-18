import 'package:flutter/material.dart';
import 'ResultsPage.dart';
import 'StatisticsPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xDDE5F1F8),
      body: SafeArea(
        child: Column(
          children: [
            // Updated Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar (logo)
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/school_logo.png'),
                  ),
                  const SizedBox(width: 12),
                  // Name and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Phan Trần Nhật Hạ',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '102210159',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell with badge
                  Stack(
                    children: [
                      const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 28,
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '7',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(12),
                children: [
                  MenuCard(
                    icon: Icons.calendar_today,
                    label: 'Thời khóa biểu',
                    subLabel: 'Xem lịch học & thi',
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.check_circle_outline,
                    label: 'Kết quả học tập',
                    subLabel: 'Tra cứu kết quả học tập',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ResultsPage()),
                      );
                    },
                  ),
                  MenuCard(
                    icon: Icons.attach_money,
                    label: 'Học phí',
                    subLabel: 'Kiểm tra thông tin học phí',
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.menu_book,
                    label: 'Chương trình đào tạo',
                    subLabel: 'Tra cứu chương trình đào tạo',
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.event_note,
                    label: 'Đánh giá rèn luyện',
                    subLabel: 'Upcoming...',
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.assignment,
                    label: 'Đồ án tốt nghiệp',
                    subLabel: 'Upcoming...',
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.bar_chart,
                    label: 'Thống kê',
                    subLabel: 'Thống kê GPA, tín chỉ tích lũy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(subLabel, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
