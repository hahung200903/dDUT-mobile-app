import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/results_repository.dart';
import 'results_event.dart';
import 'results_state.dart';

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final ResultsRepository repo;

  ResultsBloc(this.repo) : super(ResultsInitial()) {
    on<LoadResults>(_onLoad);
    on<NextSemesterPressed>(_onNextSemester);
    on<PreviousSemesterPressed>(_onPreviousSemester);
  }

  Future<void> _onLoad(LoadResults event, Emitter<ResultsState> emit) async {
    try {
      emit(ResultsLoading());
      final data = await repo.fetchResults(event.studentId);

      // Lấy currentSemester & startYear từ mã học kỳ đầu tiên, ví dụ: "2021.1"
      int curSem = 1;
      int startYear = DateTime.now().year;
      if (data.isNotEmpty) {
        final firstSem = data.first.semesterCode; // "2021.1"
        final parts = firstSem.split('.');
        if (parts.length == 2) {
          startYear = int.tryParse(parts[0]) ?? startYear;
          curSem = int.tryParse(parts[1]) ?? 1;
        }
      }

      emit(
        ResultsLoaded(
          currentSemester: curSem,
          startYear: startYear,
          subjects: data,
        ),
      );
    } catch (e) {
      emit(ResultsError(e.toString()));
    }
  }

  void _onNextSemester(NextSemesterPressed event, Emitter<ResultsState> emit) {
    final s = state;
    if (s is ResultsLoaded) {
      final wasSemesterOne = s.currentSemester == 1;
      final nextSemester = wasSemesterOne ? 2 : 1;
      final nextYear = s.startYear + (wasSemesterOne ? 0 : 1);
      emit(s.copyWith(currentSemester: nextSemester, startYear: nextYear));
    }
  }

  void _onPreviousSemester(
    PreviousSemesterPressed event,
    Emitter<ResultsState> emit,
  ) {
    final s = state;
    if (s is ResultsLoaded) {
      final wasSemesterTwo = s.currentSemester == 2;
      final prevSemester = wasSemesterTwo ? 1 : 2;
      final prevYear = s.startYear - (wasSemesterTwo ? 0 : 1);
      emit(s.copyWith(currentSemester: prevSemester, startYear: prevYear));
    }
  }
}
