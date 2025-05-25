import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_event.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_state.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardStats extends StatefulWidget {
  const DashboardStats({super.key});

  @override
  State<DashboardStats> createState() => _DashboardStatsState();
}

class _DashboardStatsState extends State<DashboardStats> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    // Get the current user ID
    String? userId;
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      userId = authState.user.id;
    } else if (authState is ProfileIncomplete) {
      userId = authState.user.id;
    }

    if (userId != null) {
      // Load user's vehicles
      context.read<VehicleBloc>().add(LoadUserVehicles(userId));

      // Load user's parking history
      context.read<ParkingBloc>().add(GetUserParkingEvent(userId));
    }

    // Load parking space statistics
    context.read<ParkingSpaceBloc>().add(GetAllParkingSpacesEvent());

    // Load active parking
    context.read<ParkingBloc>().add(GetActiveParkingEvent());
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
            Text('Summary', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            // Use MultiBlocBuilder to listen to multiple BLoCs
            MultiBlocListener(
              listeners: [
                BlocListener<VehicleBloc, VehicleState>(
                  listener: (context, state) {
                    // Handle vehicle state changes if needed
                  },
                ),
                BlocListener<ParkingBloc, ParkingState>(
                  listener: (context, state) {
                    // Handle parking state changes if needed
                  },
                ),
                BlocListener<ParkingSpaceBloc, ParkingSpaceState>(
                  listener: (context, state) {
                    // Handle parking space state changes if needed
                  },
                ),
              ],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User Vehicles Count
                  BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, state) {
                      final vehicles = _getVehiclesFromState(state);
                      return _buildStatItem(context, vehicles.length.toString(), 'Vehicles');
                    },
                  ),

                  // Total Parking Spaces Count
                  BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
                    builder: (context, state) {
                      final spaces = _getParkingSpacesFromState(state);
                      return _buildStatItem(context, spaces.length.toString(), 'Spaces');
                    },
                  ),

                  // Currently Parked (Active Parking)
                  BlocBuilder<ParkingBloc, ParkingState>(
                    builder: (context, state) {
                      final activeParking = _getActiveParkingFromState(state);
                      return _buildStatItem(context, activeParking.length.toString(), 'Parked');
                    },
                  ),

                  // Available Spaces
                  BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
                    builder: (context, state) {
                      final spaces = _getParkingSpacesFromState(state);
                      final availableSpaces =
                          spaces.where((space) {
                            // Handle both enum and string status types
                            final status = space.status.toString().toLowerCase();
                            return status.contains('vacant') || status.contains('available');
                          }).length;

                      return _buildStatItem(context, availableSpaces.toString(), 'Available');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  // Helper method to extract vehicles from state (similar to BookingFormWidget)
  List<dynamic> _getVehiclesFromState(VehicleState state) {
    try {
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        return list;
      }
    } catch (e) {
      debugPrint('Error getting vehicles from state: $e');
    }
    return [];
  }

  // Helper method to extract parking spaces from state
  List<dynamic> _getParkingSpacesFromState(ParkingSpaceState state) {
    try {
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        return list;
      }
    } catch (e) {
      debugPrint('Error getting parking spaces from state: $e');
    }
    return [];
  }

  // Helper method to extract active parking from state
  List<dynamic> _getActiveParkingFromState(ParkingState state) {
    try {
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        return list;
      }
    } catch (e) {
      debugPrint('Error getting active parking from state: $e');
    }
    return [];
  }
}
