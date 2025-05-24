import 'package:flutter/material.dart';

class TimerPickerWidget extends StatefulWidget {
  final Function(int) onDurationSelected;
  final List<int> durations;
  final int initialDuration;
  final String titleLabel; // Label shown at the top.
  final String bottomLabel; // Label shown at the bottom.

  TimerPickerWidget({
    required this.onDurationSelected,
    required this.durations,
    required this.initialDuration,
    required this.titleLabel,
    required this.bottomLabel,
  });

  @override
  _TimerPickerWidgetState createState() => _TimerPickerWidgetState();
}

class _TimerPickerWidgetState extends State<TimerPickerWidget> {
  late int _selectedDuration;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialDuration;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    // Set initial scroll position to align the selected duration under the arrow
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDuration(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double itemWidth = 80.0;
    final double offset = _scrollController.offset;
    final int index = (offset / itemWidth)
        .round()
        .clamp(0, widget.durations.length - 1);

    if (_selectedDuration != widget.durations[index]) {
      setState(() {
        _selectedDuration = widget.durations[index];
      });
      widget.onDurationSelected(_selectedDuration);
    }
  }

  void _scrollToSelectedDuration({bool animate = true}) {
    final double itemWidth = 80.0;
    final int index = widget.durations.indexOf(_selectedDuration);
    // Adjust the scroll offset to center the selected item under the arrow
    final double offset = index * itemWidth - (itemWidth / 2);

    if (animate) {
      _scrollController.animateTo(
        offset,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.titleLabel, // Display dynamic title.
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Icon(Icons.expand_more, size: 24, color: Colors.black),
        SizedBox(height: 5),
        Container(
          height: 60,
          width: 250, // Fixed width to display the numbers.
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollEndNotification) {
                _scrollToSelectedDuration(animate: true);
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.durations.length,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 85),
              itemBuilder: (context, index) {
                final int duration = widget.durations[index];
                final bool isSelected = duration == _selectedDuration;

                return Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: isSelected ? 36 : 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.grey.shade400,
                    ),
                    child: Text("$duration"),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.bottomLabel, // Display dynamic bottom label.
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
