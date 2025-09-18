import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';

class EventDetailScreen extends StatefulWidget {
  final CountdownEvent event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _slideController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  Duration _timeLeft = Duration.zero;
  bool _isEventPassed = false;

  // Beautiful gradient combinations
  static const List<List<Color>> _gradientCombinations = [
    [Color(0xFF667eea), Color(0xFF764ba2)],
    [Color(0xFFf093fb), Color(0xFFf5576c)],
    [Color(0xFF4facfe), Color(0xFF00f2fe)],
    [Color(0xFF43e97b), Color(0xFF38f9d7)],
    [Color(0xFFfa709a), Color(0xFFfee140)],
    [Color(0xFF6a11cb), Color(0xFF2575fc)],
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _updateTimeLeft();
    _startTimer();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _colorAnimation = ColorTween(
      begin: _gradientCombinations[0][0],
      end: _gradientCombinations[0][1],
    ).animate(_pulseController);

    // Start animations
    _scaleController.forward();
    _slideController.forward();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.event.date.difference(now);
    setState(() {
      _timeLeft = difference;
      _isEventPassed = difference.isNegative;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F0F23),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0F0F23),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
              transform: GradientRotation(_rotationAnimation.value),
            ),
          ),
          child: Stack(
            children: [
              // Animated circles
              Positioned(
                top: 100.h,
                right: -50.w,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 200.w,
                    height: 200.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _gradientCombinations[0][0].withOpacity(0.1),
                          _gradientCombinations[0][1].withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 150.h,
                left: -80.w,
                child: Transform.rotate(
                  angle: -_rotationAnimation.value,
                  child: Container(
                    width: 150.w,
                    height: 150.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _gradientCombinations[1][0].withOpacity(0.1),
                          _gradientCombinations[1][1].withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Floating particles
              ...List.generate(15, (index) {
                return Positioned(
                  top: (index * 50.h) % (MediaQuery.of(context).size.height),
                  left: (index * 80.w) % (MediaQuery.of(context).size.width),
                  child: Transform.translate(
                    offset: Offset(
                      math.sin(_rotationAnimation.value + index) * 20,
                      math.cos(_rotationAnimation.value + index) * 30,
                    ),
                    child: Container(
                      width: 4.w,
                      height: 4.w,
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

  Widget _buildGlassAppBar() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGlassButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  widget.event.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildGlassButton(
                    icon: Icons.edit_outlined,
                    onTap: _editEvent,
                  ),
                  SizedBox(width: 8.w),
                  _buildGlassButton(
                    icon: Icons.share_outlined,
                    onTap: _shareEvent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (color ?? Colors.white).withOpacity(0.2),
              (color ?? Colors.white).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (color ?? Colors.white).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: color ?? Colors.white,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildFloatingEventIcon() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 160.w,
              height: 160.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isEventPassed
                      ? [Colors.green, Colors.greenAccent]
                      : _gradientCombinations[0],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isEventPassed
                            ? Colors.green
                            : _gradientCombinations[0][0])
                        .withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating border effect
                  AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: Container(
                          width: 170.w,
                          height: 170.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Event icon
                  Text(
                    widget.event.icon,
                    style: TextStyle(fontSize: 70.sp),
                  ),
                  // Status indicator
                  if (_isEventPassed)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.celebration,
                          size: 20.sp,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventTitle() {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          Text(
            widget.event.name,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownDisplay() {
    final days = _timeLeft.inDays.abs();
    final hours = (_timeLeft.inHours % 24).abs();
    final minutes = (_timeLeft.inMinutes % 60).abs();
    final seconds = (_timeLeft.inSeconds % 60).abs();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: EdgeInsets.all(24.w),
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            if (!_isEventPassed) ...[
              Text(
                'Time Remaining',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeUnit(days.toString().padLeft(2, '0'), 'Days',
                      _gradientCombinations[0]),
                  _buildTimeUnit(hours.toString().padLeft(2, '0'), 'Hours',
                      _gradientCombinations[1]),
                  _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'Minutes',
                      _gradientCombinations[2]),
                  _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'Seconds',
                      _gradientCombinations[3]),
                ],
              ),
            ] else ...[
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 40.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Event Has Arrived!',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Time to celebrate! 🎉',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String unit, List<Color> gradient) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: unit == 'Seconds' ? _pulseAnimation.value * 0.95 + 0.05 : 1.0,
          child: Column(
            children: [
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.notifications_outlined,
                label: 'Remind Me',
                gradient: _gradientCombinations[4],
                onTap: _setReminder,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.calendar_today_outlined,
                label: 'Add to Calendar',
                gradient: _gradientCombinations[5],
                onTap: _addToCalendar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient.map((c) => c.withOpacity(0.8)).toList(),
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventStats() {
    final totalDays = widget.event.date.difference(DateTime.now()).inDays.abs();
    final daysPassed =
        _isEventPassed ? totalDays : (totalDays - _timeLeft.inDays);
    final progress =
        _isEventPassed ? 1.0 : (daysPassed / totalDays).clamp(0.0, 1.0);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        padding: EdgeInsets.all(20.w),
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
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _gradientCombinations[0][0],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isEventPassed
                          ? [Colors.green, Colors.greenAccent]
                          : _gradientCombinations[0],
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('Days Total', totalDays.toString()),
                _buildStatItem('Days Passed', daysPassed.toString()),
                _buildStatItem('Days Left',
                    _isEventPassed ? '0' : _timeLeft.inDays.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 30.h,
      right: 24.w,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value * 0.95 + 0.05,
            child: GestureDetector(
              onTap: _shareEvent,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradientCombinations[0],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _gradientCombinations[0][0].withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Action methods
  void _shareEvent() {
    final days = _timeLeft.inDays.abs();
    final hours = (_timeLeft.inHours % 24).abs();
    final minutes = (_timeLeft.inMinutes % 60).abs();

    final String message = _isEventPassed
        ? '''
🎉 Event Update!

"${widget.event.name}" has arrived! 

Time to celebrate! ${widget.event.icon}

#CountdownComplete #Celebration
'''
        : '''
⏰ Countdown Alert!

Event: ${widget.event.name}
${widget.event.icon}

Time Left: ${days}d ${hours}h ${minutes}m

Mark your calendars! Can't wait to celebrate together! 🎈

#Countdown #Event #${widget.event.name.replaceAll(' ', '')}
''';

    // In a real app, you would use Share.share(message) here
    _showSnackBar('Event shared successfully!');
  }

  void _editEvent() {
    _showSnackBar('Edit functionality would navigate to edit screen');
    // Navigator.pushNamed(context, '/edit-event', arguments: widget.event);
  }

  void _setReminder() {
    _showSnackBar('Reminder set for this event!');
    // Implement notification reminder logic
  }

  void _addToCalendar() {
    _showSnackBar('Event added to calendar!');
    // Implement calendar integration
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: _gradientCombinations[0][0],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Glass app bar
                _buildGlassAppBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),

                        // Floating event icon
                        _buildFloatingEventIcon(),

                        SizedBox(height: 32.h),

                        // Event title and date
                        _buildEventTitle(),

                        SizedBox(height: 40.h),

                        // Countdown display
                        _buildCountdownDisplay(),

                        SizedBox(height: 32.h),

                        // Event progress stats
                        _buildEventStats(),

                        SizedBox(height: 32.h),

                        // Action buttons
                        _buildActionButtons(),

                        SizedBox(height: 100.h), // Extra space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating action button
          _buildFloatingActionButton(),
        ],
      ),
    );
  }
}
