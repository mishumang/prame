import 'package:flutter/material.dart';

Future<Map<String, int>?> showCustomizationDialog(
    BuildContext context, {
      required int initialInhale,
      required int initialExhale,
      required int initialHold,
    }) async {
  double inhale = initialInhale.toDouble();
  double exhale = initialExhale.toDouble();

  return await showModalBottomSheet<Map<String, int>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        _buildModernSlider(
                          label: 'Inhale',
                          value: inhale,
                          onChanged: (value) => setState(() => inhale = value),
                          context: context,
                        ),
                        const SizedBox(height: 24),
                        _buildModernSlider(
                          label: 'Exhale',
                          value: exhale,
                          onChanged: (value) => setState(() => exhale = value),
                          context: context,
                        ),
                        const SizedBox(height: 32),
                        _buildSetButton(context, inhale, exhale),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Customize Breathing',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
      IconButton(
        icon: Icon(Icons.close, color: Colors.grey.shade600),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
}

Widget _buildModernSlider({
  required BuildContext context,
  required String label,
  required double value,
  required ValueChanged<double> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              '${value.toInt()} sec',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 6,
          activeTrackColor: Colors.blue.shade400,
          inactiveTrackColor: Colors.blue.shade100,
          thumbColor: Colors.blueAccent,
          overlayColor: Colors.blue.withOpacity(0.2),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
        ),
        child: Slider(
          value: value,
          min: 1,
          max: 10,
          divisions: 9,
          label: '${value.toInt()}s',
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget _buildSetButton(BuildContext context, double inhale, double exhale) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        backgroundColor: Colors.blue.shade600,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: () {
        Navigator.pop(context, {
          'inhale': inhale.toInt(),
          'exhale': exhale.toInt(),
          'hold': 0, // always returning 0
        });
      },
      child: const Text(
        'SET',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}