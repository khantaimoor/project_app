import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';

class CountdownCard extends StatelessWidget {
  final CountdownEvent event;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onNotificationToggle;

  const CountdownCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onDelete,
    this.onNotificationToggle,
  });

  String _getTimeLeft() {
    final now = DateTime.now();
    final difference = event.date.difference(now);

    if (difference.isNegative) {
      return 'Event has passed';
    }

    final days = difference.inDays;
    if (days > 0) {
      return '$days ${days == 1 ? 'day' : 'days'} left';
    }

    final hours = difference.inHours;
    if (hours > 0) {
      return '$hours ${hours == 1 ? 'hour' : 'hours'} left';
    }

    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} left';
  }

  Map<String, String> _getTimeComponents() {
    final now = DateTime.now();
    final difference = event.date.difference(now);

    if (difference.isNegative) {
      return {
        'days': '0',
        'hours': '00',
        'minutes': '00',
        'seconds': '00',
      };
    }

    final days = difference.inDays;
    final hours = difference.inHours.remainder(24);
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    return {
      'days': days.toString(),
      'hours': hours.toString().padLeft(2, '0'),
      'minutes': minutes.toString().padLeft(2, '0'),
      'seconds': seconds.toString().padLeft(2, '0'),
    };
  }

  Widget _buildTimeComponent(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeComponents = _getTimeComponents();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E2E),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 160.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.greenAccent.withOpacity(0.2),
                          const Color(0xFF2E2E2E),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 16.h,
                          left: 16.w,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  event.icon,
                                  style: TextStyle(fontSize: 24.sp),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                event.name,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 16.h,
                          right: 16.w,
                          child: Row(
                            children: [
                              if (onNotificationToggle != null)
                                IconButton(
                                  icon: Icon(
                                    event.notificationEnabled
                                        ? Icons.notifications_active
                                        : Icons.notifications_off,
                                    color: event.notificationEnabled
                                        ? Colors.greenAccent
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    onNotificationToggle
                                        ?.call(!event.notificationEnabled);
                                  },
                                ),
                              if (onDelete != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: onDelete,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTimeComponent(
                          timeComponents['days']!,
                          'Days',
                        ),
                        _buildTimeComponent(
                          timeComponents['hours']!,
                          'Hours',
                        ),
                        _buildTimeComponent(
                          timeComponents['minutes']!,
                          'Minutes',
                        ),
                        _buildTimeComponent(
                          timeComponents['seconds']!,
                          'Seconds',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
