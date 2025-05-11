import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ParkedVehicleCard extends StatelessWidget {
  final String plate;
  final String model;
  final String location;
  final String timeRemaining;

  const ParkedVehicleCard({super.key, required this.plate, required this.model, required this.location, required this.timeRemaining});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen.withAlpha(51) : ParkOSColors.darkGreen.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(MdiIcons.car, color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(plate, style: theme.textTheme.titleLarge), Text(model, style: theme.textTheme.bodyMedium)],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(16)),
                  child: Text('Active', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Location', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey)), Text(location, style: theme.textTheme.bodyMedium)],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey)),
                      Text(timeRemaining, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)), child: const Text('End Parking')),
          ],
        ),
      ),
    );
  }
}
