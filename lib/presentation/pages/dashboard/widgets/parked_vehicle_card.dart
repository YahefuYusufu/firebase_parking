import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ParkedVehicleCard extends StatelessWidget {
  final ParkingEntity parking; // Changed back to ParkingEntity
  final VoidCallback? onParkingEnded;

  const ParkedVehicleCard({super.key, required this.parking, this.onParkingEnded});

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
                    children: [
                      Text(parking.vehicleRegistration?.toUpperCase() ?? 'Unknown Vehicle', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Vehicle ID: ${parking.vehicleId ?? 'N/A'}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: parking.isActive ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(16)),
                  child: Text(parking.isActive ? 'Active' : 'Ended', style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('Space ${parking.parkingSpaceNumber ?? 'Unknown'}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(parking.duration),
                        style: theme.textTheme.bodyMedium?.copyWith(color: parking.isActive ? Colors.green : Colors.grey[600], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Started', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(_formatDateTime(parking.startedAt), style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rate', style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(
                        parking.hourlyRate != null ? '\$${parking.hourlyRate!.toStringAsFixed(2)}/hr' : 'N/A',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show estimated cost if hourly rate is available
            if (parking.hourlyRate != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue[200]!)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(parking.isActive ? 'Current Cost:' : 'Total Cost:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.blue[700])),
                    Text('\$${parking.calculateFee().toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue[700])),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Action Buttons
            if (parking.isActive) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showParkingDetails(context),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Details'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: BlocConsumer<ParkingBloc, ParkingState>(
                      listener: (context, state) {
                        if (state is ParkingEnded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Parking session ended successfully!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          onParkingEnded?.call();
                        } else if (state is ParkingError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error: ${state.message}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is ParkingLoading;
                        return ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _confirmEndParking(context),
                          icon:
                              isLoading
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.stop_circle_outlined, size: 18),
                          label: Text(isLoading ? 'Ending...' : 'End Parking'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(0, 44)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Show summary for ended parking
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Session Ended', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey[700])),
                    if (parking.finishedAt != null) Text(_formatDateTime(parking.finishedAt!), style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Same day - show time
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $amPm';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Show actual date
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _confirmEndParking(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('End Parking Session'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to end parking for vehicle ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Summary:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Location: Space ${parking.parkingSpaceNumber ?? 'Unknown'}'),
                      Text('Duration: ${_formatDuration(parking.duration)}'),
                      if (parking.hourlyRate != null) ...[
                        Text('Rate: \$${parking.hourlyRate!.toStringAsFixed(2)}/hr'),
                        Text('Total Cost: \$${parking.calculateFee().toStringAsFixed(2)}'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (parking.id != null) {
                    context.read<ParkingBloc>().add(EndParkingEvent(parking.id!));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('End Parking'),
              ),
            ],
          ),
    );
  }

  void _showParkingDetails(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Parking Details - ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Vehicle Registration', parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'),
                  _buildDetailRow('Vehicle ID', parking.vehicleId ?? 'N/A'),
                  _buildDetailRow('Location', 'Space ${parking.parkingSpaceNumber ?? 'Unknown'}'),
                  _buildDetailRow('Parking Space ID', parking.parkingSpaceId ?? 'N/A'),
                  _buildDetailRow('Started', _formatDateTime(parking.startedAt)),
                  _buildDetailRow('Duration', _formatDuration(parking.duration)),
                  if (parking.hourlyRate != null) ...[
                    _buildDetailRow('Hourly Rate', '\$${parking.hourlyRate!.toStringAsFixed(2)}'),
                    _buildDetailRow('Current Cost', '\$${parking.calculateFee().toStringAsFixed(2)}'),
                  ],
                  if (parking.finishedAt != null) _buildDetailRow('Ended', _formatDateTime(parking.finishedAt!)),
                ],
              ),
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
