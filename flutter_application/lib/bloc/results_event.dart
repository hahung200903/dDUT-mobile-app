import 'package:equatable/equatable.dart';

abstract class ResultsEvent extends Equatable {
  const ResultsEvent();
  @override
  List<Object?> get props => [];
}

class LoadResults extends ResultsEvent {
  final String studentId;
  const LoadResults(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class NextSemesterPressed extends ResultsEvent {}

class PreviousSemesterPressed extends ResultsEvent {}
