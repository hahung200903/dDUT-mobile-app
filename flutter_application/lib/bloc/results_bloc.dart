import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/results_repository.dart';

abstract class ResultsEvent extends Equatable {
  const ResultsEvent();
  @override
  List<Object?> get props => [];
}

class LoadResults extends ResultsEvent {
  final String studentId;
  const LoadResults(this.studentId);
}

class NextSemesterPressed extends ResultsEvent {}

class PreviousSemesterPressed extends ResultsEvent {}

abstract class ResultsState extends Equatable {
  const ResultsState();
  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {}

class ResultsLoading extends ResultsState {}

class ResultsLoaded extends ResultsState {
  final int currentSemester; // 1 hoặc 2
  final int startYear; // 2021, 2022, ...
  final List<SubjectResult> subjects;
  const ResultsLoaded({
    required this.currentSemester,
    required this.startYear,
    required this.subjects,
  });
  ResultsLoaded copyWith({
    int? currentSemester,
    int? startYear,
    List<SubjectResult>? subjects,
  }) => ResultsLoaded(
    currentSemester: currentSemester ?? this.currentSemester,
    startYear: startYear ?? this.startYear,
    subjects: subjects ?? this.subjects,
  );
}

class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  final ResultsRepository repo;
  ResultsBloc(this.repo) : super(ResultsInitial()) {
    on<LoadResults>(_onLoad);
    on<NextSemesterPressed>(_onNextSemester);
    on<PreviousSemesterPressed>(_onPreviousSemester);
  }

  Future<void> _onLoad(LoadResults event, Emitter<ResultsState> emit) async {
    emit(ResultsLoading());
    final data = await repo.fetchResults(event.studentId);
    // Tự tính currentSemester & startYear theo IdCode đầu tiên (vd: "2023.2")
    int curSem = 1;
    int startYear = DateTime.now().year;
    if (data.isNotEmpty) {
      final firstSem = data.first.semesterCode; // "2023.2"
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
