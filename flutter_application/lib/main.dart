import 'package:flutter/material.dart';
import 'ResultsPage.dart';
import 'StatisticsPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xDDE5F1F8),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              const HeaderSection(),
              const DateScheduleStub(),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    MenuCard(
                      icon: Icons.calendar_month,
                      label: 'Thời khóa biểu',
                      subLabel: 'Xem lịch học & thi',
                      onTap: () {},
                    ),
                    MenuCard(
                      icon: Icons.track_changes,
                      label: 'Kết quả học tập',
                      subLabel: 'Tra cứu kết quả học tập',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ResultsPage()),
                          ),
                    ),
                    MenuCard(
                      icon: Icons.attach_money,
                      label: 'Học phí',
                      subLabel: 'Kiểm tra thông tin học phí',
                      onTap: () {},
                    ),
                    MenuCard(
                      icon: Icons.auto_stories,
                      label: 'Chương trình đào tạo',
                      subLabel: 'Tra cứu chương trình đào tạo',
                      onTap: () {},
                    ),
                    MenuCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Đánh giá rèn luyện',
                      subLabel: 'Upcoming...',
                      onTap: () {},
                    ),
                    MenuCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Đồ án tốt nghiệp',
                      subLabel: 'Upcoming...',
                      onTap: () {},
                    ),
                    MenuCard(
                      icon: Icons.edit_note,
                      label: 'Thống kê',
                      subLabel: 'Thống kê GPA, tín chỉ tích lũy',
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => StatisticsPage()),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1976D2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 23,
              backgroundImage: AssetImage('assets/images/DUT.png'),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          Stack(
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 28),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(1, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blue, size: 28),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              subLabel,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class DateScheduleStub extends StatelessWidget {
  const DateScheduleStub({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text(
                  'Thứ 2',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Tháng 2',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  '13',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Container(
              height: 110,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 1,
              color: Colors.blue,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ScheduleItem(
                    courseName: 'Điện toán đám mây',
                    time: '7:00 - 9:50',
                    room: 'F109',
                  ),
                  SizedBox(height: 8),
                  ScheduleItem(
                    courseName: 'Điện toán đám mây',
                    time: '7:00 , xuất 2C1, nhóm A',
                    room: 'F109',
                  ),
                  SizedBox(height: 8),
                  ScheduleItem(
                    courseName: 'Điện toán đám mây',
                    time: '',
                    room: '',
                    isPartial: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String courseName;
  final String time;
  final String room;
  final bool isPartial;

  const ScheduleItem({
    super.key,
    required this.courseName,
    required this.time,
    required this.room,
    this.isPartial = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPartial) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          courseName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courseName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        if (room.isNotEmpty)
          Text(
            room,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
