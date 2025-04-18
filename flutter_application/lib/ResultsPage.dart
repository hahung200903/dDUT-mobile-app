import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Results Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ResultsPage(),
    );
  }
}

class DetailResults extends StatelessWidget {
  final String subjectCode;
  final String subjectTitle;
  final String credits;
  final String details;

  const DetailResults({
    super.key,
    required this.subjectCode,
    required this.subjectTitle,
    required this.credits,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(subjectTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mã môn học: $subjectCode'),
          SizedBox(height: 8),
          Text('Số tín chỉ: $credits'),
          SizedBox(height: 8),
          Text('Chi tiết: $details'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Đóng'),
        ),
      ],
    );
  }
}

class KetQuaHocTap extends StatelessWidget {
  const KetQuaHocTap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kết quả học tập',
          style: TextStyle(color: Colors.white), // White title
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // White icon
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color(0xFF1976D2),
        elevation: 0,
      ),
      body: Center(child: Text('Kết quả học tập content here')),
    );
  }
}

class ResultsPage extends StatelessWidget {
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

  ResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả học tập', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF1976D2),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              color: Color(0xFF1976D2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HỌC KÌ 1, 2024-2025',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),

            // Subject List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(12),
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

class SubjectTile extends StatelessWidget {
  final String code;
  final String title;
  final String credits;

  const SubjectTile({
    required this.code,
    required this.title,
    required this.credits,
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
              details: '[GK]*0.20+[BT]*0.20+[CK]*0.60',
            );
          },
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Số TC: $credits',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
