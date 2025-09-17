import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String? photoUrl;
  final bool isDarkMode;

  const ProfileLoaded({
    required this.name,
    this.photoUrl,
    required this.isDarkMode,
  });

  ProfileLoaded copyWith({
    String? name,
    String? photoUrl,
    bool? isDarkMode,
  }) {
    return ProfileLoaded(
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [name, photoUrl, isDarkMode];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
