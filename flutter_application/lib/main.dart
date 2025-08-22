import 'package:flutter/material.dart';
import 'pages/HomePage.dart';

const String ApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://127.0.0.1:8080/api',
);

/// Mã sinh viên mặc định (có thể thay đổi khi đăng nhập)
const String DefaultStudentId = '101240447';

// http://127.0.0.1:8080/api/results?studentId=101240447
// http://127.0.0.1:8080/api/stats?studentId=101240447

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dDUT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2A74BD),
      ),
      home: const HomePage(studentId: DefaultStudentId, apiBase: ApiBase),
    );
  }
}
