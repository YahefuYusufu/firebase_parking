// Simplified RecentActivityCard without custom MultiBlocBuilder
import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Activity data model for mixed activity types
class ActivityData {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color? iconColor;
  final ActivityType type;

  ActivityData({required this.title, required this.subtitle, required this.timestamp, required this.icon, this.iconColor, required this.type});
}

enum ActivityType { parking, vehicle, space, issue }

class RecentActivityCard extends StatefulWidget {
  const RecentActivityCard({super.key});

  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard> {
  @override
  void initState() {
    super.initState();
    _loadRecentActivity();
  }

  void _loadRecentActivity() {
    print('🔄 Loading recent activity...');

    // Get current user ID
    String? userId;
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      userId = authState.user.id;
    } else if (authState is ProfileIncomplete) {
      userId = authState.user.id;
    }

    if (userId != null) {
      print('👤 Loading activity for user: $userId');
      try {
        // Load user's parking history (this might cause the index error)
        context.read<ParkingBloc>().add(GetUserParkingEvent(userId));

        // Load user's vehicles for recent additions
        context.read<VehicleBloc>().add(LoadUserVehicles(userId));
      } catch (e) {
        print('❌ Error loading recent activity: $e');
        // Show error message to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Unable to refresh activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      print('⚠️ No user found for loading activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Activity', style: theme.textTheme.titleLarge),
                IconButton(onPressed: _loadRecentActivity, icon: const Icon(Icons.refresh, size: 20), tooltip: 'Refresh'),
              ],
            ),
            const SizedBox(height: 16),

            // Simplified approach - just show parking history with better error handling
            BlocBuilder<ParkingBloc, ParkingState>(
              builder: (context, parkingState) {
                print('📊 Recent Activity - Parking state: ${parkingState.runtimeType}');

                if (parkingState is ParkingLoading) {
                  return const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()));
                }

                if (parkingState is ParkingError) {
                  print('❌ Recent Activity Error: ${parkingState.message}');
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.warning_amber_outlined, size: 48, color: Colors.orange[400]),
                        const SizedBox(height: 12),
                        Text('Activity temporarily unavailable', style: theme.textTheme.titleMedium?.copyWith(color: Colors.orange[600])),
                        const SizedBox(height: 4),
                        Text('Database indexing in progress', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () {
                            // Try loading active parking instead as a fallback
                            context.read<ParkingBloc>().add(GetActiveParkingEvent());
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Show Active Parking'),
                        ),
                      ],
                    ),
                  );
                }

                final parkingHistory = _getParkingFromState(parkingState);
                print('📋 Found ${parkingHistory.length} parking records for activity');

                if (parkingHistory.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(Icons.timeline_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No Recent Activity', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                        const SizedBox(height: 4),
                        Text('Your parking activity will appear here', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                // Create activities from parking history
                final activities = _createParkingActivities(parkingHistory);
                print('🎯 Created ${activities.length} activities to display');

                return Column(
                  children:
                      activities.take(5).map((activity) {
                        final isLast = activities.indexOf(activity) == (activities.length > 5 ? 4 : activities.length - 1);

                        return Column(
                          children: [
                            ActivityItem(
                              title: activity.title,
                              subtitle: activity.subtitle,
                              time: _formatActivityTime(activity.timestamp),
                              icon: activity.icon,
                              iconColor: activity.iconColor,
                            ),
                            if (!isLast) const Divider(),
                          ],
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<ActivityData> _createParkingActivities(List<ParkingEntity> parkingHistory) {
    final activities = <ActivityData>[];

    for (final parking in parkingHistory) {
      // Add parking started activity
      activities.add(
        ActivityData(
          title: 'Car parked: ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}',
          subtitle: 'Space ${parking.parkingSpaceNumber ?? 'Unknown'}',
          timestamp: parking.startedAt,
          icon: MdiIcons.parking,
          iconColor: Colors.green,
          type: ActivityType.parking,
        ),
      );

      // Add parking ended activity if finished
      if (parking.finishedAt != null) {
        activities.add(
          ActivityData(
            title: 'Parking ended: ${parking.vehicleRegistration?.toUpperCase() ?? 'Unknown'}',
            subtitle: 'Duration: ${_formatDuration(parking.duration)} • \$${parking.calculateFee().toStringAsFixed(2)}',
            timestamp: parking.finishedAt!,
            icon: MdiIcons.carOff,
            iconColor: Colors.orange,
            type: ActivityType.parking,
          ),
        );
      }
    }

    // Sort by timestamp (most recent first)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return activities;
  }

  List<ParkingEntity> _getParkingFromState(ParkingState state) {
    try {
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        return list.whereType<ParkingEntity>().toList();
      }
    } catch (e) {
      debugPrint('Error getting parking from state: $e');
    }
    return [];
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      // Show actual date for older items
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
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

// Updated ActivityItem to support subtitle and icon color
class ActivityItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String time;
  final IconData icon;
  final Color? iconColor;

  const ActivityItem({super.key, required this.title, this.subtitle, required this.time, required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: (iconColor ?? theme.colorScheme.primary).withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]))],
              ],
            ),
          ),
          Text(time, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
