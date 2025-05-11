import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:flutter/material.dart';

class ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final IconData icon;

  const ActivityItem({super.key, required this.title, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen.withAlpha(51) : ParkOSColors.darkGreen.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: theme.textTheme.titleSmall), Text(time, style: theme.textTheme.bodySmall)]),
          ),
        ],
      ),
    );
  }
}
