import 'package:flutter/material.dart';
import 'pages/home.dart';

const String ApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://xemdiem.dut.udn.vn/api',
);

/// Mã sinh viên thay đổi khi đăng nhập
const String DefaultStudentId = '102210088';

// https://xemdiem.dut.udn.vn/api/results?studentId=102210088
// https://xemdiem.dut.udn.vn/api/stats?studentId=102210088

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
