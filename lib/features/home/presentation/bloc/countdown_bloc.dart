import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart'
    as model;
import 'package:project_app/features/home/presentation/bloc/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_state.dart';

class CountdownBloc extends Bloc<CountdownEventBase, CountdownState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CountdownBloc({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(CountdownInitial()) {
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

      final user = _auth.currentUser;
      if (user == null) {
        emit(CountdownError('User not authenticated'));
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .orderBy('date')
          .get();

      final events = snapshot.docs
          .map((doc) => model.CountdownEvent.fromMap(doc.data(), doc.id))
          .toList();

      emit(CountdownLoaded(events));
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

      final user = _auth.currentUser;
      if (user == null) {
        emit(CountdownError('User not authenticated'));
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .add(event.event.toMap());

      emit(CountdownEventAdded());
      add(LoadCountdownEvents());
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

      final user = _auth.currentUser;
      if (user == null) {
        emit(CountdownError('User not authenticated'));
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(event.event.id)
          .update(event.event.toMap());

      emit(CountdownEventUpdated());
      add(LoadCountdownEvents());
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

      final user = _auth.currentUser;
      if (user == null) {
        emit(CountdownError('User not authenticated'));
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(event.eventId)
          .delete();

      emit(CountdownEventDeleted());
      add(LoadCountdownEvents());
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

      final user = _auth.currentUser;
      if (user == null) {
        emit(CountdownError('User not authenticated'));
        return;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('events')
          .doc(event.eventId)
          .update({'notificationEnabled': event.enabled});

      emit(CountdownEventUpdated());
      add(LoadCountdownEvents());
    } catch (e) {
      emit(CountdownError(e.toString()));
    }
  }
}
