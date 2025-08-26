import 'package:equatable/equatable.dart';
import '../../data/results_repository.dart';

abstract class ResultsState extends Equatable {
  const ResultsState();
  @override
  List<Object?> get props => [];
}

class ResultsInitial extends ResultsState {}

class ResultsLoading extends ResultsState {}

class ResultsLoaded extends ResultsState {
  final int currentSemester; // năm 1,2, ...
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
