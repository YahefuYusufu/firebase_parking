import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/pages/dashboard/widgets/parking_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CompactParkedCard extends StatefulWidget {
  final ParkingEntity parking;
  final VoidCallback? onParkingEnded;
  final VoidCallback? onParkingUpdate;

  const CompactParkedCard({super.key, required this.parking, this.onParkingEnded, this.onParkingUpdate});

  @override
  State<CompactParkedCard> createState() => _CompactParkedCardState();
}

class _CompactParkedCardState extends State<CompactParkedCard> {
  bool _isExtending = false;
  bool _hasTriggeredUpdate = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Enhanced BlocListener to catch extensions from ANY source (notification bar OR card)
    return BlocListener<ParkingBloc, ParkingState>(
      listener: (context, state) {
        print('🔄 Card heard state: ${state.runtimeType}');

        String stateName = state.runtimeType.toString().toLowerCase();

        // Handle ANY extension success (from notification bar OR card)
        if (stateName.contains('success') || stateName.contains('loaded') || stateName.contains('updated') || stateName.contains('extended') || !stateName.contains('loading')) {
          print('✅ Parking data updated (possibly from notification), refreshing card...');

          // Reset extension state if we were extending from this card
          if (_isExtending) {
            setState(() {
              _isExtending = false;
              _hasTriggeredUpdate = true;
            });

            // Show success message only if extension came from this card
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Parking extended successfully! 🎉'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
          }

          // ALWAYS trigger update to sync with notification bar changes
          widget.onParkingUpdate?.call();

          // Reset flag after delay
          if (_hasTriggeredUpdate) {
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                _hasTriggeredUpdate = false;
              }
            });
          }
        }

        // Handle errors
        if (state is ParkingError) {
          print('❌ Parking error: ${state.message}');

          if (_isExtending) {
            setState(() {
              _isExtending = false;
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
        }
      },
      child: GestureDetector(
        onTap: () => _showActionsBottomSheet(context),
        child: SizedBox(
          width: 220,
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Vehicle header with extension indicator
                  Row(
                    children: [
                      Icon(MdiIcons.car, color: Colors.green, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.parking.vehicleRegistration?.toUpperCase() ?? 'Unknown',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (_isExtending) ...[const SizedBox(width: 4), const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Space info
                  Text(
                    'Space ${widget.parking.parkingSpaceNumber ?? 'Unknown'}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Timer widget with extend capability
                  Flexible(child: ParkingTimerWidget(parking: widget.parking, onExtendPressed: _isExtending ? null : () => _showExtendOptions(context))),
                  const SizedBox(height: 6),

                  // Cost
                  if (widget.parking.hourlyRate != null)
                    Text(
                      '\$${widget.parking.calculateFee().toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showExtendOptions(BuildContext context) {
    if (_isExtending) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => ExtendParkingBottomSheet(parking: widget.parking, onExtend: (duration, cost) => _extendParking(context, duration, cost)),
    );
  }

  void _extendParking(BuildContext context, Duration additionalTime, double cost) {
    if (widget.parking.id != null && !_isExtending) {
      print('🚀 Extending parking from CARD for ID: ${widget.parking.id}');

      setState(() {
        _isExtending = true;
        _hasTriggeredUpdate = false;
      });

      // Dispatch the extend event
      context.read<ParkingBloc>().add(ExtendParkingEvent(parkingId: widget.parking.id!, additionalTime: additionalTime, cost: cost, reason: 'User extension from card'));

      // Show immediate feedback
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Extending parking by ${_formatDuration(additionalTime)}...'), backgroundColor: Colors.orange, duration: const Duration(seconds: 2)));

      // Backup timeout - reset state if no response
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && _isExtending && !_hasTriggeredUpdate) {
          print('⏰ Extension timeout, resetting state...');
          setState(() {
            _isExtending = false;
          });
        }
      });
    }
  }

  void _showActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => ParkingActionsBottomSheet(
            parking: widget.parking,
            onEndParking: () => _confirmEndParking(context),
            onViewDetails: () => _showDetailsDialog(context),
            onExtendParking: () => _showExtendOptions(context), // Keep extend in actions too
          ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => ParkingDetailsDialog(parking: widget.parking));
  }

  void _confirmEndParking(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => EndParkingConfirmDialog(
            parking: widget.parking,
            onConfirm: () {
              if (widget.parking.id != null) {
                context.read<ParkingBloc>().add(EndParkingEvent(widget.parking.id!));
                widget.onParkingEnded?.call();
              }
            },
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
}

class ExtendParkingBottomSheet extends StatelessWidget {
  final ParkingEntity parking;
  final Function(Duration, double) onExtend;

  const ExtendParkingBottomSheet({super.key, required this.parking, required this.onExtend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Extend Parking - ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Info about multiple extend options
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withAlpha(15), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.blue[600]),
                const SizedBox(width: 6),
                Expanded(child: Text('You can also extend from the notification bar', style: TextStyle(fontSize: 11, color: Colors.blue[600]))),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _buildExtendOption(context, '30 minutes', const Duration(minutes: 30), 15.0),
          _buildExtendOption(context, '1 hour', const Duration(hours: 1), 25.0),
          _buildExtendOption(context, '2 hours', const Duration(hours: 2), 45.0),

          const SizedBox(height: 10),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildExtendOption(BuildContext context, String label, Duration duration, double cost) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.withAlpha(25), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.add_circle_outline, color: Colors.blue),
      ),
      title: Text('+ $label'),
      subtitle: Text('\$${cost.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pop(context);
        onExtend(duration, cost);
      },
    );
  }
}

class ParkingActionsBottomSheet extends StatelessWidget {
  final ParkingEntity parking;
  final VoidCallback onEndParking;
  final VoidCallback onViewDetails;
  final VoidCallback? onExtendParking; // Added back extend option

  const ParkingActionsBottomSheet({
    super.key,
    required this.parking,
    required this.onEndParking,
    required this.onViewDetails,
    this.onExtendParking, // Optional extend callback
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Actions - ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Extend Parking Action (alternative to timer button)
          if (onExtendParking != null)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
              title: const Text('Extend Parking'),
              subtitle: const Text('Add more time to your session'),
              onTap: () {
                Navigator.pop(context);
                onExtendParking!();
              },
            ),

          // View Details Action
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
              onViewDetails();
            },
          ),

          // End Parking Action
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
              onEndParking();
            },
          ),
        ],
      ),
    );
  }
}

class ParkingDetailsDialog extends StatelessWidget {
  final ParkingEntity parking;

  const ParkingDetailsDialog({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
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
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $amPm';
  }
}

class EndParkingConfirmDialog extends StatelessWidget {
  final ParkingEntity parking;
  final VoidCallback onConfirm;

  const EndParkingConfirmDialog({super.key, required this.parking, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('End Parking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('End parking for ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}?'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange[200]!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session Summary', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange[800])),
                const SizedBox(height: 8),
                Text('Duration: ${_formatDuration(parking.duration)}', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500)),
                if (parking.hourlyRate != null) Text('\$${parking.calculateFee().toStringAsFixed(2)}', style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500)),
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
            onConfirm();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('End Parking'),
        ),
      ],
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
}
