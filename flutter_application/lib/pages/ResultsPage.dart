import 'package:flutter/material.dart';
import 'DetailResults.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Results Page',
      theme: ThemeData(primaryColor: Colors.white),
      home: ResultsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  int currentSemester = 1;
  int startYear = 2024;

  void nextSemester() {
    setState(() {
      if (currentSemester == 1) {
        currentSemester = 2;
      } else {
        currentSemester = 1;
        startYear += 1;
      }
    });
  }

  void previousSemester() {
    setState(() {
      if (currentSemester == 2) {
        currentSemester = 1;
      } else {
        currentSemester = 2;
        startYear -= 1;
      }
    });
  }

  String get semesterText =>
      'HỌC KÌ $currentSemester, $startYear-${startYear + 1}';

  final List<Map<String, String>> subjects = [
    {
      'code': '1024010.2420.21.11',
      'title': 'Khai phá dữ liệu web',
      'credits': '3',
    },
    {
      'code': '1023960.2420.21.11',
      'title': 'Khoa học dữ liệu nâng cao',
      'credits': '3',
    },
    {
      'code': '1024000.2420.21.11',
      'title': 'Mô hình hoá hình học',
      'credits': '3',
    },
    {
      'code': '1024020.2420.21.11A',
      'title': 'PBL 7: Dự án chuyên ngành 2',
      'credits': '3',
    },
    {
      'code': '1024000.2420.21.11',
      'title': 'Trí tuệ nhân tạo nâng cao',
      'credits': '3',
    },
    {'code': '1020373.2420.21.11', 'title': 'Xử lý ảnh', 'credits': '3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kết quả học tập',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: Color(0xFF1976D2),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Semester Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: previousSemester,
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  Text(
                    semesterText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: nextSemester,
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Subject List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return SubjectTile(
                    code: subject['code']!,
                    title: subject['title']!,
                    credits: subject['credits']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF1976D2),
        onPressed: () {},
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.menu, color: Colors.white),
      ),
    );
  }
}

class SubjectTile extends StatelessWidget {
  final String code;
  final String title;
  final String credits;

  const SubjectTile({
    required this.code,
    required this.title,
    required this.credits,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return DetailResults(
              subjectCode: code,
              subjectTitle: title,
              credits: credits,
              details: '[GK]*0.20 + [BT]*0.20 + [CK]*0.60',
            );
          },
        );
      },
      child: Card(
        elevation: 0,
        color: Color(0xFFF5F5F5),
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: TextStyle(fontSize: 13, color: Colors.grey[800]),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Text(
                    '--/--',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Số TC: $credits',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
