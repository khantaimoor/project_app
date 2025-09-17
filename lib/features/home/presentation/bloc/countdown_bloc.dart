import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart'
    as model;
import 'package:project_app/features/home/presentation/bloc/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_state.dart';

class CountdownBloc extends Bloc<CountdownEventBase, CountdownState> {
  // Temporary list to store events (will be replaced with Firebase later)
  final List<model.CountdownEvent> _events = [];

  CountdownBloc() : super(CountdownInitial()) {
    on<LoadCountdownEvents>(_onLoadCountdownEvents);
    on<AddCountdownEvent>(_onAddCountdownEvent);
    on<UpdateCountdownEvent>(_onUpdateCountdownEvent);
    on<DeleteCountdownEvent>(_onDeleteCountdownEvent);
    on<ToggleNotification>(_onToggleNotification);
  }

  Future<void> _onLoadCountdownEvents(
    LoadCountdownEvents event,
    Emitter<CountdownState> emit,
  ) async {
    try {
      emit(CountdownLoading());
      // TODO: Replace with Firebase fetch
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      emit(CountdownLoaded(_events));
    } catch (e) {
      emit(CountdownError(e.toString()));
    }
  }

  Future<void> _onAddCountdownEvent(
    AddCountdownEvent event,
    Emitter<CountdownState> emit,
  ) async {
    try {
      emit(CountdownLoading());
      // TODO: Replace with Firebase add
      _events.add(event.event);
      emit(CountdownEventAdded());
      emit(CountdownLoaded(_events));
    } catch (e) {
      emit(CountdownError(e.toString()));
    }
  }

  Future<void> _onUpdateCountdownEvent(
    UpdateCountdownEvent event,
    Emitter<CountdownState> emit,
  ) async {
    try {
      emit(CountdownLoading());
      // TODO: Replace with Firebase update
      final index = _events.indexWhere((e) => e.id == event.event.id);
      if (index != -1) {
        _events[index] = event.event;
        emit(CountdownEventUpdated());
        emit(CountdownLoaded(_events));
      }
    } catch (e) {
      emit(CountdownError(e.toString()));
    }
  }

  Future<void> _onDeleteCountdownEvent(
    DeleteCountdownEvent event,
    Emitter<CountdownState> emit,
  ) async {
    try {
      emit(CountdownLoading());
      // TODO: Replace with Firebase delete
      _events.removeWhere((e) => e.id == event.eventId);
      emit(CountdownEventDeleted());
      emit(CountdownLoaded(_events));
    } catch (e) {
      emit(CountdownError(e.toString()));
    }
  }

  Future<void> _onToggleNotification(
    ToggleNotification event,
    Emitter<CountdownState> emit,
  ) async {
    try {
      emit(CountdownLoading());
      // TODO: Replace with Firebase update
      final index = _events.indexWhere((e) => e.id == event.eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(
          notificationEnabled: event.enabled,
        );
        emit(CountdownEventUpdated());
        emit(CountdownLoaded(_events));
      }
    } catch (e) {
      emit(CountdownError(e.toString()));
    }
  }
}
