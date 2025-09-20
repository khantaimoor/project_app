import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_bloc.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_state.dart';

class AddEditEventScreen extends StatefulWidget {
  final CountdownEvent? event;

  const AddEditEventScreen({
    super.key,
    this.event,
  });

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedIcon = '🎉';
  bool _notificationEnabled = false;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _iconCategories = [
    {
      'category': 'Celebration',
      'icons': [
        {
          'emoji': '🎉',
          'gradient': [Color(0xFF667eea), Color(0xFF764ba2)]
        },
        {
          'emoji': '🎂',
          'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)]
        },
        {
          'emoji': '🎄',
          'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)]
        },
        {
          'emoji': '🎁',
          'gradient': [Color(0xFFfa709a), Color(0xFFfee140)]
        },
      ]
    },
    {
      'category': 'Travel & Adventure',
      'icons': [
        {
          'emoji': '✈️',
          'gradient': [Color(0xFF43e97b), Color(0xFF38f9d7)]
        },
        {
          'emoji': '🏖️',
          'gradient': [Color(0xFF667eea), Color(0xFF764ba2)]
        },
        {
          'emoji': '🗻',
          'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)]
        },
        {
          'emoji': '🚗',
          'gradient': [Color(0xFF4facfe), Color(0xFF00f2fe)]
        },
      ]
    },
    {
      'category': 'Milestones',
      'icons': [
        {
          'emoji': '💍',
          'gradient': [Color(0xFFfa709a), Color(0xFFfee140)]
        },
        {
          'emoji': '🎓',
          'gradient': [Color(0xFF43e97b), Color(0xFF38f9d7)]
        },
        {
          'emoji': '🏆',
          'gradient': [Color(0xFF667eea), Color(0xFF764ba2)]
        },
        {
          'emoji': '💼',
          'gradient': [Color(0xFFf093fb), Color(0xFFf5576c)]
        },
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupAnimations();
  }

  void _initializeData() {
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _selectedDate = widget.event!.date;
      _selectedTime = widget.event!.time != null
          ? TimeOfDay.fromDateTime(widget.event!.time!)
          : null;
      _selectedIcon = widget.event!.icon;
      _notificationEnabled = widget.event!.notificationEnabled;
    }
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
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
              Text(
                widget.event != null ? 'Edit Event' : 'Create Event',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  if (widget.event != null) ...[
                    _buildGlassButton(
                      icon: Icons.delete_outline,
                      onTap: _deleteEvent,
                      color: Colors.red.withOpacity(0.8),
                    ),
                    SizedBox(width: 8.w),
                  ],
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

  Widget _buildFloatingIconSelector() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: _showIconSelector,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    _selectedIcon,
                    style: TextStyle(fontSize: 60.sp),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 28.w,
                      height: 28.w,
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
                        Icons.edit,
                        size: 16.sp,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
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
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
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
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Date',
                    value: _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                    onTap: _selectDate,
                    gradient: const [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDateTimeCard(
                    icon: Icons.access_time_outlined,
                    title: 'Time',
                    value: _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select Time',
                    onTap: _selectTime,
                    gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    required List<Color> gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient.map((c) => c.withOpacity(0.2)).toList(),
          ),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: gradient.first.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required List<Color> gradient,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
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
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      margin: EdgeInsets.symmetric(vertical: 20.h),
      child: ElevatedButton(
        onPressed: _saveEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
            ),
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.event != null ? Icons.update : Icons.add,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.event != null ? 'Update Event' : 'Create Event',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Methods for functionality
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _showIconSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildIconSelectorModal(),
    );
  }

  Widget _buildIconSelectorModal() {
    return Container(
      height: 600.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F0F23),
            Color(0xFF1A1A2E),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Text(
            'Choose Icon',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: _iconCategories.length,
              itemBuilder: (context, index) {
                final category = _iconCategories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['category'],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: category['icons'].length,
                      itemBuilder: (context, iconIndex) {
                        final iconData = category['icons'][iconIndex];
                        final isSelected = _selectedIcon == iconData['emoji'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = iconData['emoji'];
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isSelected
                                    ? iconData['gradient']
                                    : [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.2),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                iconData['emoji'],
                                style: TextStyle(fontSize: 32.sp),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveEvent() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter an event name', isError: true);
      return;
    }

    if (_selectedDate == null) {
      _showSnackBar('Please select a date', isError: true);
      return;
    }

    final DateTime eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime?.hour ?? 0,
      _selectedTime?.minute ?? 0,
    );

    final event = CountdownEvent(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      date: eventDateTime,
      time: eventDateTime,
      icon: _selectedIcon,
      notificationEnabled: _notificationEnabled,
    );

    if (widget.event != null) {
      context.read<CountdownBloc>().add(UpdateCountdownEvent(event));
    } else {
      context.read<CountdownBloc>().add(AddCountdownEvent(event));
    }
  }

  void _deleteEvent() {
    if (widget.event != null) {
      showDialog(
        context: context,
        builder: (context) => _buildDeleteDialog(),
      );
    }
  }

  Widget _buildDeleteDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.redAccent],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 30.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Delete Event',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Are you sure you want to delete this event? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context
                          .read<CountdownBloc>()
                          .add(DeleteCountdownEvent(widget.event!.id));
                      Navigator.pop(context);
                      Navigator.pop(context);
                      _showSnackBar('Event deleted successfully!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareEvent() {
    if (_nameController.text.trim().isNotEmpty && _selectedDate != null) {
      // In a real app, you would use the share_plus package here
      _showSnackBar('Share functionality would be implemented here');
    } else {
      _showSnackBar('Please fill in event details first', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CountdownBloc(),
      child: BlocListener<CountdownBloc, CountdownState>(
        listener: (context, state) {
          if (state is CountdownEventAdded) {
            _showSnackBar('Event created successfully!');
            Navigator.pop(context);
          } else if (state is CountdownEventUpdated) {
            _showSnackBar('Event updated successfully!');
            Navigator.pop(context);
          } else if (state is CountdownError) {
            _showSnackBar('Error: ${state.message}', isError: true);
          }
        },
        child: Scaffold(
          body: Stack(
            children: [
              _buildGradientBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _buildCustomAppBar(),
                    Expanded(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(height: 40.h),
                                _buildFloatingIconSelector(),
                                SizedBox(height: 32.h),
                                _buildGlassTextField(
                                  controller: _nameController,
                                  label: 'Event Name',
                                  hint: 'Enter your event name...',
                                ),
                                _buildDateTimeSection(),
                                _buildGlassTextField(
                                  controller: _notesController,
                                  label: 'Notes',
                                  hint: 'Add notes about your event...',
                                  maxLines: 3,
                                ),
                                _buildFeatureCard(
                                  icon: Icons.notifications_outlined,
                                  title: 'Notifications',
                                  subtitle: _notificationEnabled
                                      ? 'You\'ll receive reminders'
                                      : 'Enable to get reminders',
                                  onTap: () {
                                    setState(() {
                                      _notificationEnabled =
                                          !_notificationEnabled;
                                    });
                                  },
                                  gradient: const [
                                    Color(0xFF43e97b),
                                    Color(0xFF38f9d7)
                                  ],
                                  trailing: Switch(
                                    value: _notificationEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _notificationEnabled = value;
                                      });
                                    },
                                    activeColor: const Color(0xFF43e97b),
                                    activeTrackColor: const Color(0xFF43e97b)
                                        .withOpacity(0.3),
                                    inactiveThumbColor:
                                        Colors.white.withOpacity(0.5),
                                    inactiveTrackColor:
                                        Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                _buildFeatureCard(
                                  icon: Icons.palette_outlined,
                                  title: 'Theme & Background',
                                  subtitle: 'Customize your event appearance',
                                  onTap: () {
                                    _showSnackBar(
                                        'Theme customization coming soon!');
                                  },
                                  gradient: const [
                                    Color(0xFFfa709a),
                                    Color(0xFFfee140)
                                  ],
                                ),
                                _buildFeatureCard(
                                  icon: Icons.group_outlined,
                                  title: 'Invite Friends',
                                  subtitle: 'Share with friends and family',
                                  onTap: _shareEvent,
                                  gradient: const [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2)
                                  ],
                                ),
                                _buildSaveButton(),
                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
