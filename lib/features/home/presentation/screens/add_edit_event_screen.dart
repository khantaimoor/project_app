import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_app/core/widgets/custom_button.dart';
import 'package:project_app/core/widgets/custom_text_field.dart';
import 'package:project_app/features/home/domain/models/countdown_event.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_bloc.dart';
import 'package:project_app/features/home/presentation/bloc/countdown_event.dart';

class AddEditEventScreen extends StatefulWidget {
  final CountdownEvent? event;

  const AddEditEventScreen({
    super.key,
    this.event,
  });

  @override
  State<AddEditEventScreen> createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedIcon = '🎉';
  bool _notificationEnabled = false;

  final List<String> _icons = ['🎉', '🎂', '✈️', '💍', '🎓', '🏆', '🎄', '💼'];

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
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
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate() || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
        ),
      );
      return;
    }

    final DateTime eventDateTime = _selectedTime != null
        ? DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );

    final event = CountdownEvent(
      id: widget.event?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      date: eventDateTime,
      time: _selectedTime != null ? eventDateTime : null,
      icon: _selectedIcon,
      notificationEnabled: _notificationEnabled,
    );

    if (widget.event != null) {
      context.read<CountdownBloc>().add(UpdateCountdownEvent(event));
    } else {
      context.read<CountdownBloc>().add(AddCountdownEvent(event));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event != null ? 'Edit Event' : 'Add Event'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  hintText: 'Event Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an event name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24.h),
                Text(
                  'Select Icon',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(8.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8.w,
                      crossAxisSpacing: 8.w,
                    ),
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIcon = icon;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedIcon == icon
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1)
                                : null,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: _selectedIcon == icon
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: TextStyle(fontSize: 24.sp),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                ListTile(
                  title: const Text('Event Date'),
                  subtitle: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select date',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  title: const Text('Event Time (Optional)'),
                  subtitle: Text(
                    _selectedTime != null
                        ? _selectedTime!.format(context)
                        : 'Select time',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: _selectTime,
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: 24.h),
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Get reminded about this event'),
                  value: _notificationEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationEnabled = value;
                    });
                  },
                  tileColor: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: 32.h),
                CustomButton(
                  text: widget.event != null ? 'Update Event' : 'Add Event',
                  onPressed: _saveEvent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
