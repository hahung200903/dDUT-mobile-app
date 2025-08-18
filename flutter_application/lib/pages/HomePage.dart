import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'ResultsPage.dart';
import 'StatisticsPage.dart';

class HomePage extends StatefulWidget {
  final String studentId;
  final String apiBase;

  const HomePage({super.key, required this.studentId, required this.apiBase});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7F1F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              HeaderSection(displayStudentId: widget.studentId),
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
                  childAspectRatio: 0.85,
                  children: [
                    MenuCard(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/solar_calendar-broken.svg',
                      ),
                      label: 'Thời khóa biểu',
                      onTap: () {},
                    ),
                    MenuCard(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/mage_goals.svg',
                      ),
                      label: 'Kết quả học tập',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ResultsPage(
                                  studentId: widget.studentId,
                                  apiBase: widget.apiBase,
                                ),
                          ),
                        );
                      },
                    ),
                    MenuCard(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/tabler_coin.svg',
                      ),
                      label: 'Học phí',
                      onTap: () {},
                    ),
                    MenuCard(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/carbon_book.svg',
                      ),
                      label: 'Chương trình đào tạo',
                      onTap: () {},
                    ),
                    MenuCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Đánh giá rèn luyện',
                      onTap: () {},
                      isDisabled: true,
                    ),
                    MenuCard(
                      icon: Icons.calendar_month_outlined,
                      label: 'Đồ án tốt nghiệp',
                      onTap: () {},
                      isDisabled: true,
                    ),
                    MenuCard(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/uil_chart-line.svg',
                      ),
                      label: 'Thống kê',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => StatisticsPage(
                                  studentId: widget.studentId,
                                  apiBase: widget.apiBase,
                                ),
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
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final String displayStudentId;
  const HeaderSection({super.key, required this.displayStudentId});

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sinh viên',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayStudentId,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
  final IconData? icon;
  final Widget? iconWidget;
  final String label;
  final VoidCallback onTap;
  final String? svgAsset;
  final double? iconSizeOverride;
  final Color? iconColor;
  final bool isDisabled;

  const MenuCard({
    super.key,
    this.icon,
    this.iconWidget,
    required this.label,
    required this.onTap,
    this.svgAsset,
    this.iconSizeOverride,
    this.iconColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isDisabled,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: GestureDetector(
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = constraints.maxWidth;
              final cardHeight = constraints.maxHeight;
              final calculatedSize =
                  (cardWidth < cardHeight ? cardWidth : cardHeight) * 0.31;
              final iconSize = iconSizeOverride ?? calculatedSize;
              final Color resolvedIconColor =
                  iconColor ?? (isDisabled ? Colors.grey : Colors.blue);
              final Color labelColor =
                  isDisabled ? Colors.grey : Colors.black87;

              return Container(
                padding: const EdgeInsets.all(8),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (iconWidget != null)
                      SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: iconWidget,
                        ),
                      )
                    else if (svgAsset != null)
                      SvgPicture.asset(
                        svgAsset!,
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(
                          resolvedIconColor,
                          BlendMode.srcIn,
                        ),
                      )
                    else
                      Icon(
                        icon ?? Icons.image_outlined,
                        color: resolvedIconColor,
                        size: iconSize,
                      ),
                    SizedBox(height: cardHeight * 0.06),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: cardHeight * 0.075,
                        color: labelColor,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
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
        items: [
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
