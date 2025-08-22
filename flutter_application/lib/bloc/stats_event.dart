part of 'stats_bloc.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent({this.studentId});
  final String? studentId;

  @override
  List<Object?> get props => [studentId];
}

class StatsRequested extends StatsEvent {
  const StatsRequested({String? studentId}) : super(studentId: studentId);
}

class StatsRefreshed extends StatsEvent {
  const StatsRefreshed({String? studentId}) : super(studentId: studentId);
}
