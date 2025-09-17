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

  double _getProgress() {
    final now = DateTime.now();
    final difference = event.date.difference(now);

    if (difference.isNegative) return 1.0;

    const maxDays = 365.0; // Max days to show progress
    return 1 - (difference.inDays / maxDays).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: LinearProgressIndicator(
                  value: _getProgress(),
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        event.icon,
                        style: TextStyle(fontSize: 24.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _getTimeLeft(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (onNotificationToggle != null) ...[
                    IconButton(
                      icon: Icon(
                        event.notificationEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: event.notificationEnabled
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                      onPressed: () {
                        onNotificationToggle?.call(!event.notificationEnabled);
                      },
                    ),
                  ],
                  if (onDelete != null) ...[
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: onDelete,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
