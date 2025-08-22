part of 'stats_bloc.dart';

class StatsState extends Equatable {
  final bool isLoading;
  final StatsModel? data;
  final String? error;

  const StatsState._({required this.isLoading, this.data, this.error});

  const StatsState.loading() : this._(isLoading: true);
  const StatsState.loaded(StatsModel data)
      : this._(isLoading: false, data: data);
  const StatsState.error(String message)
      : this._(isLoading: false, error: message);

  @override
  List<Object?> get props => [isLoading, data, error];
}
