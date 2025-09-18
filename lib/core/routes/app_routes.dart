import 'package:flutter/material.dart';
import 'package:project_app/core/utils/animation_service.dart';
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
    late final Widget page;

    switch (settings.name) {
      case splash:
        page = const SplashScreen();
        break;
      case onboarding:
        page = const OnboardingScreen();
        break;
      case login:
        page = const LoginScreen();
        break;
      case signup:
        page = const SignupScreen();
        break;
      case forgotPassword:
        page = const ForgotPasswordScreen();
        break;
      case home:
        page = const HomeScreen();
        break;
      case addEvent:
        page = const AddEditEventScreen();
        break;
      case editEvent:
        final event = settings.arguments as CountdownEvent;
        page = AddEditEventScreen(event: event);
        break;
      case eventDetail:
        final event = settings.arguments as CountdownEvent;
        page = EventDetailScreen(event: event);
        break;
      case profile:
        page = const ProfileScreen();
        break;
      default:
        page = const Scaffold(
          body: Center(
            child: Text('Route not found'),
          ),
        );
    }

    return AnimationService.createRoute(
      page: page,
      settings: settings,
    );
  }
}
