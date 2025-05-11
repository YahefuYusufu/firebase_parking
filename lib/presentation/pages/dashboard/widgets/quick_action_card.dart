import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:flutter/material.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionCard({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen),
              const SizedBox(height: 8),
              Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
