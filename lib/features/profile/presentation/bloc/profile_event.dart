import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class UpdateName extends ProfileEvent {
  final String name;

  const UpdateName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdatePhoto extends ProfileEvent {
  final String? photoUrl;

  const UpdatePhoto(this.photoUrl);

  @override
  List<Object?> get props => [photoUrl];
}

class ToggleTheme extends ProfileEvent {
  final bool isDarkMode;

  const ToggleTheme(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}

class SignOut extends ProfileEvent {}
