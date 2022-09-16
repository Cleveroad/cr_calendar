import 'package:cr_calendar/cr_calendar.dart';
import 'package:cr_calendar_example/res/colors.dart';
import 'package:cr_calendar_example/utills/constants.dart';
import 'package:cr_calendar_example/utills/extensions.dart';
import 'package:cr_calendar_example/widgets/date_picker_title_widget.dart';
import 'package:cr_calendar_example/widgets/picker_day_item_widget.dart';
import 'package:cr_calendar_example/widgets/week_days_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Pop up dialog for event creation.
class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({super.key});

  @override
  _CreateEventDialogState createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  int _selectedColorIndex = 0;
  final _eventNameController = TextEditingController();

  String _rangeButtonText = 'Select date';

  DateTime? _beginDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.7,
          maxWidth: size.width * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Dialog title.
                const Text(
                  'Event creating',
                  style: TextStyle(
                    color: violet,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                /// Event name input field.
                TextField(
                  cursorColor: violet,
                  style: const TextStyle(color: violet, fontSize: 16),
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: violet.withOpacity(1)),
                    ),
                    hintText: 'Enter the event name',
                    hintStyle:
                        TextStyle(color: violet.withOpacity(0.6), fontSize: 16),
                  ),
                  controller: _eventNameController,
                ),
                const SizedBox(height: 24),

                /// Color selection section.
                const Text(
                  'Select event color',
                  style: TextStyle(
                    fontSize: 16,
                    color: violet,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),

                /// Color selection raw.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...List.generate(
                        eventColors.length,
                        (index) => GestureDetector(
                          onTap: () {
                            _selectColor(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Container(
                              foregroundDecoration: BoxDecoration(
                                border: index == _selectedColorIndex
                                    ? Border.all(
                                        color: Colors.black.withOpacity(0.3),
                                        width: 2)
                                    : null,
                                shape: BoxShape.circle,
                                color: eventColors[index],
                              ),
                              width: 32,
                              height: 32,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                /// Date selection button.
                TextButton(
                  onPressed: _showRangePicker,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: violet,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _rangeButtonText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: violet,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    /// Cancel button.
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 16),

                    /// OK button.
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _validateEventData() ? _onEventCreation : null,
                        child: const Text('OK'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Select color on tap.
  void _selectColor(int index) {
    setState(() {
      _selectedColorIndex = index;
    });
  }

  /// Set range picker button text.
  void _setRangeData(DateTime? begin, DateTime? end) {
    if (begin == null || end == null) {
      return;
    }
    setState(() {
      _beginDate = begin;
      _endDate = end;
      _rangeButtonText = _parseDateRange(begin, end);
    });
  }

  /// Parse selected date to readable format.
  String _parseDateRange(DateTime begin, DateTime end) {
    if (begin.isAtSameMomentAs(end)) {
      return begin.format(kDateRangeFormat);
    } else {
      return '${begin.format(kDateRangeFormat)} - ${end.format(kDateRangeFormat)}';
    }
  }

  /// Validate event info for enabling "OK" button.
  bool _validateEventData() {
    return _eventNameController.text.isNotEmpty &&
        _beginDate != null &&
        _endDate != null;
  }

  /// Close dialog and pass [CalendarEventModel] as arguments.
  void _onEventCreation() {
    final beginDate = _beginDate;
    final endDate = _endDate;
    if (beginDate == null || endDate == null) {
      return;
    }
    Navigator.of(context).pop(
      CalendarEventModel(
        name: _eventNameController.text,
        begin: beginDate,
        end: endDate,
        eventColor: eventColors[_selectedColorIndex],
      ),
    );
  }

  /// Show calendar in pop up dialog for selecting date range for calendar event.
  void _showRangePicker() {
    FocusScope.of(context).unfocus();
    showCrDatePicker(
      context,
      properties: DatePickerProperties(
        onDateRangeSelected: _setRangeData,
        dayItemBuilder: (properties) =>
            PickerDayItemWidget(properties: properties),
        weekDaysBuilder: (day) => WeekDaysWidget(day: day),
        initialPickerDate: _beginDate ?? DateTime.now(),
        pickerTitleBuilder: (date) => DatePickerTitle(date: date),
        yearPickerItemBuilder: (year, isPicked) => Container(
          height: 24,
          width: 54,
          decoration: BoxDecoration(
            color: isPicked ? violet : Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Center(
            child: Text(year.toString(),
                style: TextStyle(
                    color: isPicked ? Colors.white : violet, fontSize: 16)),
          ),
        ),
        controlBarTitleBuilder: (date) => Text(
          DateFormat(kAppBarDateFormat).format(date),
          style: const TextStyle(
            fontSize: 16,
            color: violet,
            fontWeight: FontWeight.normal,
          ),
        ),
        okButtonBuilder: (onPress) => ElevatedButton(
          onPressed: () => onPress?.call(),
          child: const Text('OK'),
        ),
        cancelButtonBuilder: (onPress) => OutlinedButton(
          onPressed: () => onPress?.call(),
          child: const Text('CANCEL'),
        ),
      ),
    );
  }
}
