import 'package:flutter/material.dart';
import 'DetailResults.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/results_bloc.dart';

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

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});

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
        child: BlocBuilder<ResultsBloc, ResultsState>(
          builder: (context, state) {
            if (state is ResultsLoading || state is ResultsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ResultsLoaded) {
              return Column(
                children: [
                  // Semester Header
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.read<ResultsBloc>().add(const PreviousSemesterPressed()),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        Text(
                          state.semesterText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.read<ResultsBloc>().add(const NextSemesterPressed()),
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
                      itemCount: state.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = state.subjects[index];
                        return SubjectTile(
                          code: subject['code']!,
                          title: subject['title']!,
                          credits: subject['credits']!,
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            if (state is ResultsError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
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
