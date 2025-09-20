import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/core/routes/app_routes.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:project_app/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Controllers
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;

  // Animation Controllers
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  late final AnimationController _pulseController;
  late final AnimationController _rotationController;

  // Animations
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  // State variables
  bool _obscurePassword = true;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _canSubmit = false;
  Timer? _debounceTimer;
  String? _currentEmailError;
  String? _currentPasswordError;

  // Constants
  static const Duration _animationDuration = Duration(milliseconds: 800);
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  // Beautiful gradient colors
  static const List<Color> _primaryGradient = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];

  static const List<Color> _secondaryGradient = [
    Color(0xFF4facfe),
    Color(0xFF00f2fe),
  ];

  static const List<Color> _backgroundGradient = [
    Color(0xFF0F0F23),
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F0F23),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _setupAnimations();
    _setupTextListeners();
    _startAnimations();
  }

  void _initializeControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  void _setupAnimations() {
    // Fade animation for overall screen
    _fadeController = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for form elements
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Pulse animation for floating elements
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for background elements
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // Scale animation for buttons
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
  }

  void _setupTextListeners() {
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _startAnimations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _pulseController.stop();
        _rotationController.stop();
        break;
      case AppLifecycleState.resumed:
        if (mounted) {
          _pulseController.repeat();
          _rotationController.repeat();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  // Validation methods
  void _validateEmail() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (!mounted) return;

      final email = _emailController.text.trim();
      String? error;
      bool isValid = false;

      if (email.isEmpty) {
        error = null; // Don't show error for empty field initially
      } else if (!_isValidEmail(email)) {
        error = 'Please enter a valid email address';
      } else {
        isValid = true;
      }

      if (mounted) {
        setState(() {
          _currentEmailError = error;
          _isEmailValid = isValid;
          _updateSubmitButton();
        });
      }
    });
  }

  void _validatePassword() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      if (!mounted) return;

      final password = _passwordController.text;
      String? error;
      bool isValid = false;

      if (password.isEmpty) {
        error = null; // Don't show error for empty field initially
      } else if (password.length < 6) {
        error = 'Password must be at least 6 characters';
      } else if (!_isStrongPassword(password)) {
        error = 'Password should contain letters and numbers';
      } else {
        isValid = true;
      }

      if (mounted) {
        setState(() {
          _currentPasswordError = error;
          _isPasswordValid = isValid;
          _updateSubmitButton();
        });
      }
    });
  }

  void _updateSubmitButton() {
    final canSubmit = _isEmailValid &&
        _isPasswordValid &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;

    if (_canSubmit != canSubmit) {
      setState(() {
        _canSubmit = canSubmit;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _isStrongPassword(String password) {
    return password.length >= 6 &&
        RegExp(r'[a-zA-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  // UI Builder methods
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _backgroundGradient,
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Animated floating circles
              Positioned(
                top: 100.h + math.sin(_rotationAnimation.value) * 20,
                right: 50.w + math.cos(_rotationAnimation.value) * 30,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _primaryGradient[0].withOpacity(0.1),
                        _primaryGradient[1].withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 200.h + math.cos(_rotationAnimation.value) * 25,
                left: 30.w + math.sin(_rotationAnimation.value) * 15,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _secondaryGradient[0].withOpacity(0.1),
                        _secondaryGradient[1].withOpacity(0.05),
                      ],
                    ),
                  ),
                ),
              ),
              // Floating particles
              ...List.generate(12, (index) {
                return Positioned(
                  top: (index * 80.h) %
                      (MediaQuery.of(context).size.height * 0.8),
                  left: (index * 60.w) %
                      (MediaQuery.of(context).size.width * 0.8),
                  child: Transform.translate(
                    offset: Offset(
                      math.sin(_rotationAnimation.value + index) * 10,
                      math.cos(_rotationAnimation.value + index) * 15,
                    ),
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _primaryGradient,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryGradient[0].withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.account_circle_outlined,
              size: 60.sp,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, Colors.white.withOpacity(0.8)],
          ).createShader(bounds),
          child: Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to continue your journey',
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
    bool isValid = false,
    VoidCallback? onSuffixTap,
    IconData? suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: errorText != null
              ? Colors.red.withOpacity(0.5)
              : isValid
                  ? Colors.green.withOpacity(0.5)
                  : Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16.sp,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: isValid
                    ? Colors.green
                    : errorText != null
                        ? Colors.red
                        : _primaryGradient[0],
                size: 22.sp,
              ),
              suffixIcon: suffixIcon != null
                  ? GestureDetector(
                      onTap: onSuffixTap,
                      child: Icon(
                        suffixIcon,
                        color: Colors.white.withOpacity(0.7),
                        size: 22.sp,
                      ),
                    )
                  : isValid
                      ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 22.sp,
                        )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 20.h,
              ),
            ),
            inputFormatters: keyboardType == TextInputType.emailAddress
                ? [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    LengthLimitingTextInputFormatter(254),
                  ]
                : [
                    LengthLimitingTextInputFormatter(128),
                  ],
          ),
          if (errorText != null)
            Padding(
              padding: EdgeInsets.only(left: 20.w, bottom: 8.h),
              child: Text(
                errorText,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(AuthState state) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: 56.h,
        margin: EdgeInsets.symmetric(vertical: 20.h),
        child: ElevatedButton(
          onPressed:
              (_canSubmit && state is! AuthLoading) ? _handleSignIn : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
            elevation: 0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: _canSubmit && state is! AuthLoading
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _primaryGradient,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.3),
                        Colors.grey.withOpacity(0.2),
                      ],
                    ),
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: _canSubmit && state is! AuthLoading
                  ? [
                      BoxShadow(
                        color: _primaryGradient[0].withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Container(
              alignment: Alignment.center,
              child: state is AuthLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => _navigateToForgotPassword(),
        style: TextButton.styleFrom(
          foregroundColor: _secondaryGradient[0],
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 4.h,
          ),
        ),
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () => _navigateToSignUp(),
          style: TextButton.styleFrom(
            foregroundColor: _primaryGradient[0],
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: _primaryGradient,
            ).createShader(bounds),
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafeArea() {
    return Container(
      height: MediaQuery.of(context).padding.bottom + 20.h,
      color: Colors.transparent,
    );
  }

  // Action methods
  void _handleSignIn() async {
    try {
      // Dismiss keyboard
      FocusScope.of(context).unfocus();

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Validate form
      if (!_formKey.currentState!.validate()) {
        _showErrorSnackBar('Please fix the errors before continuing');
        return;
      }

      // Check network connectivity
      if (!await _checkConnectivity()) {
        _showErrorSnackBar(
            'No internet connection. Please check your network.');
        return;
      }

      // Trigger authentication
      if (mounted) {
        context.read<AuthBloc>().add(
              LoginEvent(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            );
      }
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  Future<bool> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return true; // Assume connected if we can't check
    }
  }

  void _navigateToForgotPassword() {
    try {
      HapticFeedback.selectionClick();
      Navigator.pushNamed(context, AppRoutes.forgotPassword);
    } catch (e) {
      _showErrorSnackBar('Navigation error. Please try again.');
    }
  }

  void _navigateToSignUp() {
    try {
      HapticFeedback.selectionClick();
      Navigator.pushNamed(context, AppRoutes.signup);
    } catch (e) {
      _showErrorSnackBar('Navigation error. Please try again.');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _showSuccessSnackBar('Welcome back!');
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthError) {
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: Stack(
              children: [
                // Animated background
                _buildAnimatedBackground(),

                // Main content
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height -
                                MediaQuery.of(context).padding.top,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 60.h),

                                    // Logo
                                    _buildLogo(),

                                    SizedBox(height: 40.h),

                                    // Welcome text
                                    _buildWelcomeText(),

                                    SizedBox(height: 60.h),

                                    // Email field
                                    _buildGlassTextField(
                                      controller: _emailController,
                                      hintText: 'Email Address',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      errorText: _currentEmailError,
                                      isValid: _isEmailValid,
                                    ),

                                    // Password field
                                    _buildGlassTextField(
                                      controller: _passwordController,
                                      hintText: 'Password',
                                      prefixIcon: Icons.lock_outline,
                                      obscureText: _obscurePassword,
                                      errorText: _currentPasswordError,
                                      isValid: _isPasswordValid,
                                      suffixIcon: _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      onSuffixTap: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),

                                    SizedBox(height: 8.h),

                                    // Forgot password link
                                    _buildForgotPasswordLink(),

                                    SizedBox(height: 24.h),

                                    // Sign in button
                                    _buildSignInButton(state),

                                    const Spacer(),

                                    // Sign up link
                                    _buildSignUpLink(),

                                    // Safe area
                                    _buildSafeArea(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
