import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCalendarPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime>? highlightedDates;

  const CustomCalendarPicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
    this.highlightedDates,
  });

  @override
  State<CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<CustomCalendarPicker> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _selectedDate = widget.initialDate;
    _pageController = PageController(
      initialPage: _monthDifference(widget.firstDate, _currentMonth),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _monthDifference(DateTime from, DateTime to) {
    return (to.year - from.year) * 12 + to.month - from.month;
  }

  bool _isHighlighted(DateTime date) {
    return widget.highlightedDates?.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        SizedBox(height: 16.h),
        _buildCalendarGrid(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
        ValueListenableBuilder<DateTime>(
          valueListenable: _currentMonthNotifier,
          builder: (context, date, _) {
            return Text(
              '${_getMonthName(date.month)} ${date.year}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return SizedBox(
      height: 300.h,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          final newDate = DateTime(
            widget.firstDate.year,
            widget.firstDate.month + index,
          );
          _currentMonthNotifier.value = newDate;
        },
        itemBuilder: (context, index) {
          final month = DateTime(
            widget.firstDate.year,
            widget.firstDate.month + index,
          );
          return _buildMonth(month);
        },
      ),
    );
  }

  Widget _buildMonth(DateTime month) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 7 * 6,
      itemBuilder: (context, index) {
        if (index < 7) {
          return Center(
            child: Text(
              _getDayName(index),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey,
              ),
            ),
          );
        }

        final day = index - 7;
        final date = DateTime(month.year, month.month, 1);
        final firstDayOffset = date.weekday - 1;
        final adjustedDay = day - firstDayOffset + 1;
        final currentDate = DateTime(month.year, month.month, adjustedDay);

        if (adjustedDay < 1 ||
            currentDate.month != month.month ||
            currentDate.isAfter(widget.lastDate) ||
            currentDate.isBefore(widget.firstDate)) {
          return const SizedBox.shrink();
        }

        final isSelected = currentDate.year == _selectedDate.year &&
            currentDate.month == _selectedDate.month &&
            currentDate.day == _selectedDate.day;

        final isHighlighted = _isHighlighted(currentDate);

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = currentDate;
            });
            widget.onDateSelected(currentDate);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : isHighlighted
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                adjustedDay.toString(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: isSelected || isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Colors.white
                      : isHighlighted
                          ? Theme.of(context).primaryColor
                          : null,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  final _currentMonthNotifier = ValueNotifier<DateTime>(DateTime.now());

  String _getMonthName(int month) {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ][month - 1];
  }

  String _getDayName(int day) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day];
  }
}
