import 'package:equatable/equatable.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';

abstract class CountdownState extends Equatable {
  const CountdownState();

  @override
  List<Object?> get props => [];
}

class CountdownInitial extends CountdownState {}

class CountdownLoading extends CountdownState {}

class CountdownLoaded extends CountdownState {
  final List<CountdownEvent> events;

  const CountdownLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class CountdownError extends CountdownState {
  final String message;

  const CountdownError(this.message);

  @override
  List<Object?> get props => [message];
}

class CountdownEventAdded extends CountdownState {}

class CountdownEventUpdated extends CountdownState {}

class CountdownEventDeleted extends CountdownState {}
