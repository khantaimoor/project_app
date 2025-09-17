import 'package:equatable/equatable.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart'
    as model;

abstract class CountdownEventBase extends Equatable {
  const CountdownEventBase();

  @override
  List<Object?> get props => [];
}

class LoadCountdownEvents extends CountdownEventBase {}

class AddCountdownEvent extends CountdownEventBase {
  final model.CountdownEvent event;

  const AddCountdownEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateCountdownEvent extends CountdownEventBase {
  final model.CountdownEvent event;

  const UpdateCountdownEvent(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteCountdownEvent extends CountdownEventBase {
  final String eventId;

  const DeleteCountdownEvent(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class ToggleNotification extends CountdownEventBase {
  final String eventId;
  final bool enabled;

  const ToggleNotification({
    required this.eventId,
    required this.enabled,
  });

  @override
  List<Object?> get props => [eventId, enabled];
}
