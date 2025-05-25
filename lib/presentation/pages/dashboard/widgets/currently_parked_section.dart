import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CurrentlyParkedSection extends StatefulWidget {
  const CurrentlyParkedSection({super.key});

  @override
  State<CurrentlyParkedSection> createState() => _CurrentlyParkedSectionState();
}

class _CurrentlyParkedSectionState extends State<CurrentlyParkedSection> {
  @override
  void initState() {
    super.initState();
    _loadActiveParking();
  }

  void _loadActiveParking() {
    print('🚀 Loading active parking...');
    context.read<ParkingBloc>().add(GetActiveParkingEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with count
        BlocBuilder<ParkingBloc, ParkingState>(
          builder: (context, state) {
            final activeParking = _getActiveParkingFromState(state);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Currently Parked', style: theme.textTheme.titleLarge),
                    if (activeParking.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                        child: Text('${activeParking.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                IconButton(onPressed: _loadActiveParking, icon: const Icon(Icons.refresh), tooltip: 'Refresh'),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Horizontal scrolling cards
        SizedBox(
          height: 190, // Increased height to accommodate bigger cards
          child: BlocBuilder<ParkingBloc, ParkingState>(
            builder: (context, state) {
              print('🔍 Current state: $state');

              if (state is ParkingLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ParkingError) {
                print('❌ Error: ${state.message}');
                return _buildErrorCard(theme, state.message);
              }

              final activeParking = _getActiveParkingFromState(state);
              print('📊 Found ${activeParking.length} active parking sessions');

              if (activeParking.isEmpty) {
                return _buildEmptyCard(theme);
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: activeParking.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return CompactParkedCard(parking: activeParking[index], onParkingEnded: _loadActiveParking);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(ThemeData theme) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('No Active Parking', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            Text('Your active sessions will appear here', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme, String message) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 8),
            Text('Error loading data', style: theme.textTheme.titleMedium?.copyWith(color: Colors.red[600])),
            Text('Tap refresh to try again', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  List<ParkingEntity> _getActiveParkingFromState(ParkingState state) {
    try {
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        print('📄 Raw list length: ${list.length}');

        // Debug: Print what type of objects we have
        for (var item in list) {
          print('📋 Item type: ${item.runtimeType}');
          if (item is ParkingEntity) {
            print('   - Vehicle ID: ${item.vehicleId}');
            print('   - Registration: ${item.vehicleRegistration}');
            print('   - Finished: ${item.finishedAt}');
            print('   - Is active: ${item.isActive}');
          }
        }

        // Filter only active parking using ParkingEntity and isActive property
        final activeParkingList = list.where((parking) => parking is ParkingEntity && parking.isActive).cast<ParkingEntity>().toList();

        print('✅ Active parking found: ${activeParkingList.length}');
        for (var parking in activeParkingList) {
          print('   - Active: ${parking.vehicleRegistration} at space ${parking.parkingSpaceNumber}');
        }

        return activeParkingList;
      }
    } catch (e) {
      print('❌ Error getting active parking from state: $e');
    }
    return [];
  }
}

// Simple, compact horizontal card
class CompactParkedCard extends StatelessWidget {
  final ParkingEntity parking;
  final VoidCallback? onParkingEnded;

  const CompactParkedCard({super.key, required this.parking, this.onParkingEnded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showActionsBottomSheet(context),
      child: SizedBox(
        width: 180, // Increased width for bigger cards
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(14.0), // Increased padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle header
                Row(
                  children: [
                    Icon(MdiIcons.car, color: Colors.green, size: 18), // Slightly bigger icon
                    const SizedBox(width: 8), // More spacing
                    Expanded(
                      child: Text(
                        parking.vehicleRegistration?.toUpperCase() ?? 'Unknown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          // Bigger font
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), // More spacing
                // Space info
                Text(
                  'Space ${parking.parkingSpaceNumber ?? 'Unknown'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Bigger font
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6), // More spacing
                // Duration
                Text(
                  _formatDuration(parking.duration),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    // Bigger font
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Cost
                if (parking.hourlyRate != null) ...[
                  const SizedBox(height: 6), // More spacing
                  Text(
                    '\$${parking.calculateFee().toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Bigger font
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
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

  void _showActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Actions - ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // View Details
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.info_outline, color: Colors.blue),
                  ),
                  title: const Text('View Details'),
                  subtitle: const Text('See complete parking information'),
                  onTap: () {
                    Navigator.pop(context);
                    _showDetailsDialog(context);
                  },
                ),

                // End Parking
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.stop_circle, color: Colors.red),
                  ),
                  title: const Text('End Parking'),
                  subtitle: const Text('Stop this parking session'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmEndParking(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Parking Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Vehicle', parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'),
                _buildDetailRow('Location', 'Space ${parking.parkingSpaceNumber ?? 'Unknown'}'),
                _buildDetailRow('Duration', _formatDuration(parking.duration)),
                _buildDetailRow('Started', _formatDateTime(parking.startedAt)),
                if (parking.hourlyRate != null) ...[
                  _buildDetailRow('Rate', '\$${parking.hourlyRate!.toStringAsFixed(2)}/hr'),
                  _buildDetailRow('Current Cost', '\$${parking.calculateFee().toStringAsFixed(2)}'),
                ],
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
    );
  }

  void _confirmEndParking(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End Parking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('End parking for ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50], // Better background color
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Session Summary', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                      const SizedBox(height: 8),
                      Text('Duration: ${_formatDuration(parking.duration)}', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500)),
                      if (parking.hourlyRate != null)
                        Text('\$${parking.calculateFee().toStringAsFixed(2)}', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (parking.id != null) {
                    context.read<ParkingBloc>().add(EndParkingEvent(parking.id!));
                    onParkingEnded?.call();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('End Parking'),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $amPm';
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
