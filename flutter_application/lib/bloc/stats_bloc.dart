import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/stats_repository.dart';
import '../models/stats_model.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc(this._repo) : super(const StatsState.loading()) {
    on<StatsRequested>(_onRequested);
    on<StatsRefreshed>(_onRequested);
  }

  final StatsRepository _repo;

  Future<void> _onRequested(StatsEvent event, Emitter<StatsState> emit) async {
    emit(const StatsState.loading());
    try {
      final stats = await _repo.fetchStats(studentId: event.studentId ?? '');
      emit(StatsState.loaded(stats));
    } catch (e) {
      emit(StatsState.error(e.toString()));
    }
  }
}
