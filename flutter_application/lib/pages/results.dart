import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/results_bloc.dart';
import '../bloc/results_event.dart';
import '../bloc/results_state.dart';

import '../data/results_repository.dart';
import 'detail_result.dart';

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Kết quả học tập'),
          centerTitle: true,
          backgroundColor: const Color(0xFF2A74BD),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.notifications_none, color: Colors.white),
            ),
          ],
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
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Icon(Icons.chevron_left, color: Colors.black54),
                            Text(
                              'HỌC KÌ 1, 2024-2025',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: Colors.black54),
                          ],
                        ),
                      );
                    }

                    final s = items[index - 1];
                    final hasTitle = (s.subjectTitle ?? '').trim().isNotEmpty;
                    final subjectTitleText =
                        hasTitle ? s.subjectTitle!.trim() : s.subjectCode;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 6.0,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          final details = [
                            'Kỳ: ${s.semesterCode}',
                            'Điểm 10: ${s.score10?.toStringAsFixed(2) ?? '-'}',
                            'Điểm 4: ${s.score4?.toStringAsFixed(2) ?? '-'}',
                            'Điểm chữ: ${s.scoreChar ?? '-'}',
                          ].join('\n');

                          showDialog(
                            context: context,
                            builder: (_) => DetailResults(
                              subjectCode: s.subjectCode,
                              subjectTitle: subjectTitleText,
                              credits: '${s.credits ?? '-'}',
                              details: details,
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.classCode,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subjectTitleText,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF2A74BD),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Số TC: ${s.credits ?? '-'}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  s.scoreChar ?? '--/--',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
