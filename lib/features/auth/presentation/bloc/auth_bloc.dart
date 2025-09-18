// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final Connectivity _connectivity;

  StreamSubscription<User?>? _authStateSub;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  AuthBloc({
    FirebaseAuth? firebaseAuth,
    Connectivity? connectivity,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _connectivity = connectivity ?? Connectivity(),
        super(AuthInitial()) {
    // Event handlers
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<LogoutEvent>(_onLogout);

    // Listen to Firebase auth state changes and update bloc state accordingly.
    _authStateSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        // If your AuthState has a specific AuthAuthenticated, you can emit that.
        // For compatibility with your existing states we emit AuthSuccess here.
        add(_AuthStateChangedEvent(user));
      } else {
        add(_AuthStateChangedEvent(null));
      }
    });

    // Listen to connectivity changes (optional: you can emit custom states on connectivity)
  

    // Internal event handlers for auth state change and connectivity events:
    on<_AuthStateChangedEvent>(_onAuthStateChanged);
  }

  // Expose auth state stream for direct listening (UI can use this too)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Simple getter for current user
  User? get currentUser => _auth.currentUser;

  // --- Event handlers ---

  Future<void> _onAuthStateChanged(
    _AuthStateChangedEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user != null) {
      // Emit success with optional user info (your AuthSuccess may not carry payload — adapt if needed)
      emit(
          AuthSuccess()); // or AuthAuthenticated(event.user) if you have that state
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      // Check connectivity before network call
      final hasConnection = await _hasNetworkConnection();
      if (!hasConnection) {
        emit(AuthError('No internet. Please check your connection.'));
        return;
      }

      // Try sign in
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password,
        );

        if (credential.user != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthError('Login failed. Please try again.'));
        }
      } on FirebaseAuthException catch (e) {
        // If user-not-found: create the account automatically (as you requested)
        if (e.code == 'user-not-found') {
          try {
            final newUser = await _auth.createUserWithEmailAndPassword(
              email: event.email.trim(),
              password: event.password,
            );
            if (newUser.user != null) {
              emit(AuthSuccess());
            } else {
              emit(AuthError('Could not create account. Try again later.'));
            }
          } on FirebaseAuthException catch (createError) {
            emit(AuthError(_mapFirebaseAuthException(createError)));
          } catch (createGeneric) {
            emit(AuthError('Unexpected error while creating account.'));
          }
        } else {
          emit(AuthError(_mapFirebaseAuthException(e)));
        }
      } catch (e) {
        emit(AuthError('Unexpected error during sign-in.'));
      }
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

      final hasConnection = await _hasNetworkConnection();
      if (!hasConnection) {
        emit(AuthError('No internet. Please check your connection.'));
        return;
      }

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: event.email.trim(),
          password: event.password,
        );

        if (userCredential.user != null) {
          emit(AuthSuccess());
        } else {
          emit(AuthError('Signup failed. Please try again.'));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapFirebaseAuthException(e)));
      } catch (e) {
        emit(AuthError('Unexpected error during signup.'));
      }
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

      final hasConnection = await _hasNetworkConnection();
      if (!hasConnection) {
        emit(AuthError('No internet. Please check your connection.'));
        return;
      }

      try {
        await _auth.sendPasswordResetEmail(email: event.email.trim());
        emit(ForgotPasswordSuccess());
      } on FirebaseAuthException catch (e) {
        emit(AuthError(_mapFirebaseAuthException(e)));
      } catch (e) {
        emit(AuthError('Unexpected error during password reset.'));
      }
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
      await signOut(); // uses the helper below
      emit(AuthInitial());
    } catch (e) {
      emit(AuthError('Failed to sign out.'));
    }
  }

  // Public signOut future (you asked for future function with async/await)
  Future<void> signOut() async {
    // Check connection (signOut may not require network in many cases but we keep it robust)
    try {
      await _auth.signOut();
    } catch (_) {
      // ignore or rethrow if you want to handle
      rethrow;
    }
  }

  // --- Helpers ---

  // Check connectivity quickly. This function uses connectivity_plus to detect
  // network interface; it does not strictly guarantee reachability to Firebase,
  // but it is sufficient for typical UX "check your connection" messaging.
  Future<bool> _hasNetworkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Contact support.';
      case 'weak-password':
        return 'The password is too weak.';
      default:
        return e.message ?? 'Authentication error: ${e.code}';
    }
  }

  @override
  Future<void> close() {
    _authStateSub?.cancel();
    _connectivitySub?.cancel();
    return super.close();
  }
}

/// Internal event used to respond to Firebase auth changes.
class _AuthStateChangedEvent extends AuthEvent {
  final User? user;
  _AuthStateChangedEvent(this.user);
}
