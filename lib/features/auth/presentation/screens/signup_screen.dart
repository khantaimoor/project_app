import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/core/routes/app_routes.dart';
import 'package:project_app/core/widgets/custom_button.dart';
import 'package:project_app/core/widgets/custom_text_field.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil if not already done
    ScreenUtil.init(context);

    // Get screen dimensions for better responsiveness
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16.w),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            // Remove app bar to maximize space
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                screenWidth > 600 ? 80.0 : screenWidth * 0.06,
                            vertical: 16.0,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Back button
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      size: screenWidth > 400 ? 24.0 : 20.0,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),

                                // Flexible spacing based on screen size
                                SizedBox(height: screenHeight * 0.02),

                                // Header section
                                Text(
                                  'Create Account',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize:
                                            screenWidth > 400 ? 32.0 : 28.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Start tracking your special moments',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize:
                                            screenWidth > 400 ? 16.0 : 14.0,
                                      ),
                                ),

                                // Adaptive spacing
                                SizedBox(
                                    height: isKeyboardVisible ? 24.0 : 48.0),

                                // Form fields
                                CustomTextField(
                                  hintText: 'Email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    // Improved email validation
                                    final emailRegExp = RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegExp.hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),

                                CustomTextField(
                                  hintText: 'Password',
                                  controller: _passwordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.next,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 8) {
                                      return 'Password must be at least 8 characters';
                                    }
                                    // Enhanced password validation
                                    if (!RegExp(
                                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                                        .hasMatch(value)) {
                                      return 'Password must contain uppercase, lowercase, and number';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),

                                CustomTextField(
                                  hintText: 'Confirm Password',
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (_) {
                                    if (_formKey.currentState!.validate()) {
                                      _handleSignup(context);
                                    }
                                  },
                                ),

                                // Adaptive spacing
                                SizedBox(
                                    height: isKeyboardVisible ? 24.h : 32.h),

                                // Sign up button
                                SizedBox(
                                  width: double.infinity,
                                  child: CustomButton(
                                    text: 'Sign Up',
                                    onPressed: () => _handleSignup(context),
                                    isLoading: state is AuthLoading,
                                  ),
                                ),

                                // Spacer to push content to bottom when needed
                                if (!isKeyboardVisible) const Spacer(),

                                // Sign in link
                                SizedBox(
                                    height: isKeyboardVisible ? 16.h : 24.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Already have an account? ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 14.sp,
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Sign In',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.sp,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Bottom padding for safe area
                                SizedBox(height: 16.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSignup(BuildContext context) {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            SignupEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }
}
