import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:project_app/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileLocalDataSource localDataSource;

  ProfileBloc({required this.localDataSource}) : super(ProfileLoading()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateName>(_onUpdateName);
    on<UpdatePhoto>(_onUpdatePhoto);
    on<ToggleTheme>(_onToggleTheme);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onLoadProfile(
      LoadProfile event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());

      final name = localDataSource.getName() ?? 'User';
      final photoUrl = localDataSource.getPhotoUrl();
      final isDarkMode = localDataSource.getIsDarkMode();

      emit(ProfileLoaded(
        name: name,
        photoUrl: photoUrl,
        isDarkMode: isDarkMode,
      ));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> _onUpdateName(
      UpdateName event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());

      await localDataSource.saveName(event.name);

      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(currentState.copyWith(name: event.name));
      }
    } catch (e) {
      emit(ProfileError('Failed to update name: $e'));
    }
  }

  Future<void> _onUpdatePhoto(
      UpdatePhoto event, Emitter<ProfileState> emit) async {
    try {
      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(ProfileLoading());

        await localDataSource.savePhotoUrl(event.photoUrl);
        emit(currentState.copyWith(photoUrl: event.photoUrl));
      }
    } catch (e) {
      emit(ProfileError('Failed to update photo: $e'));
    }
  }

  Future<void> _onToggleTheme(
      ToggleTheme event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());

      await localDataSource.saveIsDarkMode(event.isDarkMode);

      if (state is ProfileLoaded) {
        final currentState = state as ProfileLoaded;
        emit(currentState.copyWith(isDarkMode: event.isDarkMode));
      }
    } catch (e) {
      emit(ProfileError('Failed to toggle theme: $e'));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());

      // TODO: Implement Firebase sign out when Firebase is configured
      await localDataSource.clear();

      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError('Failed to sign out: $e'));
    }
  }
}
