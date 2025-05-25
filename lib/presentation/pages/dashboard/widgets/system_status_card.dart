import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen.withAlpha(51) : ParkOSColors.darkGreen.withAlpha(25),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(MdiIcons.circle, color: Colors.green, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('System Status: Operational', style: theme.textTheme.titleMedium),
                    Text('All parking systems are functioning normally', style: theme.textTheme.bodyLarge),
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
