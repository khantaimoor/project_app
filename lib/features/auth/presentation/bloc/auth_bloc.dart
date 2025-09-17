import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      // TODO: Implement Firebase authentication
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignup(
    SignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      // TODO: Implement Firebase authentication
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      // TODO: Implement Firebase password reset
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay
      emit(ForgotPasswordSuccess());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      // TODO: Implement Firebase logout
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
