import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/results_bloc.dart';
import '../bloc/results_event.dart';
import '../bloc/results_state.dart';

import '../data/results_repository.dart';
import 'DetailResults.dart';

class ResultsPage extends StatelessWidget {
  final String studentId;
  final String apiBase;

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
          backgroundColor: const Color(0xFF2A74BD),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        body: BlocBuilder<ResultsBloc, ResultsState>(
          builder: (context, state) {
            if (state is ResultsInitial || state is ResultsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Trạng thái lỗi
            if (state is ResultsError) {
              return _ErrorView(
                message: state.message,
                onRetry:
                    () =>
                        context.read<ResultsBloc>().add(LoadResults(studentId)),
              );
            }

            // Trạng thái loaded
            if (state is ResultsLoaded) {
              final items = state.subjects;
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh:
                      () async => context.read<ResultsBloc>().add(
                        LoadResults(studentId),
                      ),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('Không có dữ liệu')),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh:
                    () async =>
                        context.read<ResultsBloc>().add(LoadResults(studentId)),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final s = items[i];
                    final hasTitle = (s.subjectTitle ?? '').trim().isNotEmpty;

                    return ListTile(
                      title: Text(
                        hasTitle ? s.subjectTitle!.trim() : s.subjectCode,
                      ),
                      subtitle: Text(
                        'Mã HP: ${s.subjectCode} • Lớp: ${s.classCode}',
                      ),
                      trailing: Text(s.scoreChar ?? ''),
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
                ),
              );
            }

            // Fallback an toàn
            return _ErrorView(
              message: 'Lỗi tải dữ liệu',
              onRetry:
                  () => context.read<ResultsBloc>().add(LoadResults(studentId)),
            );
          },
        ),
      ),
    );
  }
}

// Widget lỗi
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lỗi: $message', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
