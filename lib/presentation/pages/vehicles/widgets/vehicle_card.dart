import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/data/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPark;
  final VoidCallback? onViewDetails;
  final bool isParked;

  const VehicleCard({super.key, required this.vehicle, this.onEdit, this.onDelete, this.onPark, this.onViewDetails, this.isParked = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Status color based on parking status
    final statusColor = isParked ? (isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen) : Colors.grey;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with plate number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(vehicle.registrationNumber, style: theme.textTheme.titleLarge),
                  Row(
                    children: [
                      Icon(isParked ? MdiIcons.parking : MdiIcons.carOff, color: statusColor, size: 20),
                      const SizedBox(width: 6),
                      Text(isParked ? 'Parked' : 'Available', style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Vehicle details
              Text('${vehicle.type} - Owned by ${vehicle.owner?.name ?? 'Unknown'}', style: theme.textTheme.bodyMedium),

              // Parking location if parked
              if (isParked) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(MdiIcons.mapMarker, size: 16, color: isDark ? ParkOSColors.lightGreen : ParkOSColors.mediumGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Parked at: Zone A, Space 12', // Replace with actual location
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Delete button
                  if (onDelete != null) IconButton(icon: Icon(MdiIcons.delete, color: ParkOSColors.errorRed), onPressed: onDelete, tooltip: 'Delete'),

                  // Edit button
                  if (onEdit != null)
                    IconButton(icon: Icon(MdiIcons.pencilOutline), onPressed: onEdit, tooltip: 'Edit', color: isDark ? ParkOSColors.lightGreen : ParkOSColors.darkGreen),

                  // Spacer
                  const Spacer(),

                  // Park button (only if not parked)
                  if (onPark != null && !isParked)
                    TextButton.icon(
                      icon: Icon(MdiIcons.parking),
                      label: const Text('Park Now'),
                      onPressed: onPark,
                      style: TextButton.styleFrom(foregroundColor: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen),
                    ),

                  // End parking button (only if parked)
                  if (isParked)
                    TextButton.icon(
                      icon: Icon(MdiIcons.carOff),
                      label: const Text('End Parking'),
                      onPressed: () {
                        // Handle end parking
                      },
                      style: TextButton.styleFrom(foregroundColor: ParkOSColors.errorRed),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
