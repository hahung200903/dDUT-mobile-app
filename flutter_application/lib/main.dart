import 'package:flutter/material.dart';
import 'pages/home.dart';

const String ApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://171.244.142.248/ddut/api',
  // defaultValue: 'http://127.0.0.1:8080/api',
);

/// Mã sinh viên thay đổi khi đăng nhập
const String DefaultStudentId = '102210087';

// http://171.244.142.248/ddut/api/results?studentId=102210087
// http://171.244.142.248/ddut/api/stats?studentId=102210087

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
