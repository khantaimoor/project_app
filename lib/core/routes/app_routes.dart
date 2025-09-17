import 'package:flutter/material.dart';
import 'package:project_app/features/auth/presentation/screens/login_screen.dart';
import 'package:project_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:project_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:project_app/features/home/presentation/screens/home_screen.dart';
import 'package:project_app/features/home/presentation/screens/add_edit_event_screen.dart';
import 'package:project_app/features/home/presentation/screens/event_detail_screen.dart';
import 'package:project_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:project_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:project_app/features/splash/presentation/screens/onboarding_screen.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String addEvent = '/add-event';
  static const String editEvent = '/edit-event';
  static const String eventDetail = '/event-detail';
  static const String profile = '/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addEvent:
        return MaterialPageRoute(builder: (_) => const AddEditEventScreen());
      case editEvent:
        final event = settings.arguments as CountdownEvent;
        return MaterialPageRoute(
            builder: (_) => AddEditEventScreen(event: event));
      case eventDetail:
        final event = settings.arguments as CountdownEvent;
        return MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event));
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
