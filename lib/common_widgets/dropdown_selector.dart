import 'package:flutter/material.dart';

class DropdownSelector extends StatefulWidget {
  final List<String> options;
  final String? initialSelection;
  final ValueChanged<String> onChanged;

  const DropdownSelector({
    Key? key,
    required this.options,
    required this.onChanged,
    this.initialSelection,
  }) : super(key: key);

  @override
  _DropdownSelectorState createState() => _DropdownSelectorState();
}

class _DropdownSelectorState extends State<DropdownSelector> {
  late String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelection ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedValue,
        isExpanded: true,
        underline: SizedBox(),
        items: widget.options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedValue = value;
          });
          widget.onChanged(value!);
        },
      ),
    );
  }
}