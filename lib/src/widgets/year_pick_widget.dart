import 'package:cr_calendar/cr_calendar.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Year picker widget.
///
/// Displays list of years 3 per list item by default. Used in [CrDatePickerDialog].
class YearPickerWidget extends StatefulWidget {
  /// Default constructor.
  const YearPickerWidget({
    required this.initialYear,
    this.yearsPerLine = 3,
    this.minYear = 1900,
    this.maxYear = 2100,
    this.onYearTap,
    this.yearPickerItemBuilder,
    this.yearItemHeight = 75,
    super.key,
  });

  /// Initial selected year.
  final int initialYear;

  /// Number of years showed per line.
  final int yearsPerLine;

  /// Min year.
  final int minYear;

  /// Max year.
  final int maxYear;

  /// Year selection callback.
  final Function(int year)? onYearTap;

  /// Builder for year item.
  final YearPickerItemBuilder? yearPickerItemBuilder;

  /// Height of year item widget.
  final double yearItemHeight;

  @override
  _YearPickerWidgetState createState() => _YearPickerWidgetState();
}

class _YearPickerWidgetState extends State<YearPickerWidget> {
  int? _pickedYear;
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    _pickedYear = widget.initialYear;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ScrollablePositionedList.builder(
        initialScrollIndex:
            (widget.initialYear - widget.minYear) ~/ widget.yearsPerLine,
        itemCount: _getItemCount(),
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          return Container(
            height: widget.yearItemHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getYears(index),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _getYears(int line) {
    return List.generate(widget.yearsPerLine, (index) {
      final year = widget.minYear + (line * widget.yearsPerLine) + index;
      return InkWell(
        onTap: () {
          _pickedYear = year;
          widget.onYearTap?.call(year);
        },
        child: widget.yearPickerItemBuilder?.call(year, _isPicked(year)) ??
            Center(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getItemColor(year),
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(100, 100),
                  ),
                  border: _getItemBorder(year),
                ),
                child: Text(
                  '$year',
                  style: TextStyle(
                    color: _isPicked(year) ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
      );
    });
  }

  Border? _getItemBorder(int year) {
    return year == DateTime.now().year ? Border.all(color: Colors.green) : null;
  }

  Color? _getItemColor(int year) {
    return _isPicked(year) ? Colors.green : null;
  }

  bool _isPicked(int year) {
    if (_pickedYear == year ||
        (year == widget.initialYear && _pickedYear == null)) {
      return true;
    }
    return false;
  }

  int _getItemCount() {
    final count =
        ((widget.maxYear - widget.minYear) / widget.yearsPerLine).ceil();
    return count == 0 ? 1 : count;
  }
}
