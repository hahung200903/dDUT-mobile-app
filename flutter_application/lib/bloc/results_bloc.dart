import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ResultsEvent extends Equatable {
  const ResultsEvent();

  @override
  List<Object?> get props => [];
}

class LoadResults extends ResultsEvent {
  const LoadResults();
}

class NextSemesterPressed extends ResultsEvent {
  const NextSemesterPressed();
}

class PreviousSemesterPressed extends ResultsEvent {
  const PreviousSemesterPressed();
}

// States
abstract class ResultsState extends Equatable {
  const ResultsState();

  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {
  const ResultsInitial();
}

class ResultsLoading extends ResultsState {
  const ResultsLoading();
}

class ResultsLoaded extends ResultsState {
  final int currentSemester;
  final int startYear;
  final List<Map<String, String>> subjects;

  const ResultsLoaded({
    required this.currentSemester,
    required this.startYear,
    required this.subjects,
  });

  String get semesterText => 'HỌC KÌ $currentSemester, $startYear-${startYear + 1}';

  ResultsLoaded copyWith({
    int? currentSemester,
    int? startYear,
    List<Map<String, String>>? subjects,
  }) {
    return ResultsLoaded(
      currentSemester: currentSemester ?? this.currentSemester,
      startYear: startYear ?? this.startYear,
      subjects: subjects ?? this.subjects,
    );
  }

  @override
  List<Object?> get props => [currentSemester, startYear, subjects];
}

class ResultsError extends ResultsState {
  final String message;
  const ResultsError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ResultsBloc extends Bloc<ResultsEvent, ResultsState> {
  ResultsBloc() : super(const ResultsInitial()) {
    on<LoadResults>(_onLoadResults);
    on<NextSemesterPressed>(_onNextSemester);
    on<PreviousSemesterPressed>(_onPreviousSemester);
  }

  List<Map<String, String>> _initialSubjects() {
    return const [
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
      {
        'code': '1020373.2420.21.11',
        'title': 'Xử lý ảnh',
        'credits': '3',
      },
    ];
  }

  Future<void> _onLoadResults(
    LoadResults event,
    Emitter<ResultsState> emit,
  ) async {
    emit(const ResultsLoading());
    // Simulate a short load; replace with real API later
    await Future<void>.delayed(const Duration(milliseconds: 200));
    emit(
      ResultsLoaded(
        currentSemester: 1,
        startYear: 2024,
        subjects: _initialSubjects(),
      ),
    );
  }

  void _onNextSemester(
    NextSemesterPressed event,
    Emitter<ResultsState> emit,
  ) {
    final current = state;
    if (current is ResultsLoaded) {
      final bool wasSemesterOne = current.currentSemester == 1;
      final int nextSemester = wasSemesterOne ? 2 : 1;
      final int nextYear = current.startYear + (wasSemesterOne ? 0 : 1);
      emit(current.copyWith(currentSemester: nextSemester, startYear: nextYear));
    }
  }

  void _onPreviousSemester(
    PreviousSemesterPressed event,
    Emitter<ResultsState> emit,
  ) {
    final current = state;
    if (current is ResultsLoaded) {
      final bool wasSemesterTwo = current.currentSemester == 2;
      final int prevSemester = wasSemesterTwo ? 1 : 2;
      final int prevYear = current.startYear - (wasSemesterTwo ? 0 : 1);
      emit(current.copyWith(currentSemester: prevSemester, startYear: prevYear));
    }
  }
} 