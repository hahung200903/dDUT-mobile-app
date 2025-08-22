import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/results_bloc.dart';
import '../data/results_repository.dart';
import 'DetailResults.dart';

class ResultsPage extends StatelessWidget {
  final String studentId;
  final String
  apiBase; // https://asia-southeast1-<PROJECT_ID>.cloudfunctions.net/api
  const ResultsPage({
    super.key,
    required this.studentId,
    required this.apiBase,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              ResultsBloc(ResultsRepository(apiBase))
                ..add(LoadResults(studentId)),
      child: Scaffold(
        backgroundColor: const Color(0xFFE7F1F9),
        appBar: AppBar(
            title: const Text('Kết quả học tập'),
            centerTitle: true,
            backgroundColor: Color(0xFF2A74BD),
            iconTheme: const IconThemeData(color: Colors.white),
            titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18)),
        body: BlocBuilder<ResultsBloc, ResultsState>(
          builder: (context, state) {
            if (state is ResultsLoading || state is ResultsInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ResultsLoaded) {
              final items = state.subjects;
              if (items.isEmpty) {
                return const Center(child: Text('Không có dữ liệu'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final s = items[i];
                  return ListTile(
                    title: Text(
                      s.subjectTitle?.isNotEmpty == true
                          ? s.subjectTitle!
                          : s.subjectCode,
                    ),
                    subtitle: Text(
                      'Mã HP: ${s.subjectCode} • Lớp: ${s.classCode}',
                    ),
                    onTap: () {
                      final details = [
                        'Kỳ: ${s.semesterCode}',
                        'Điểm 10: ${s.score10?.toStringAsFixed(2) ?? '-'}',
                        'Điểm 4: ${s.score4?.toStringAsFixed(2) ?? '-'}',
                        'Điểm chữ: ${s.scoreChar ?? '-'}',
                      ].join('\n');

                      showDialog(
                        context: context,
                        builder:
                            (_) => DetailResults(
                              subjectCode: s.subjectCode,
                              subjectTitle: s.subjectTitle ?? 'N/A',
                              credits: '${s.credits ?? '-'}',
                              details: details,
                            ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Lỗi tải dữ liệu'));
          },
        ),
      ),
    );
  }
}
