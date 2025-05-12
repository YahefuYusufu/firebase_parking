import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';
import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_card.dart';
import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../blocs/vehicle/vehicle_bloc.dart';
import '../../blocs/vehicle/vehicle_event.dart';
import '../../blocs/vehicle/vehicle_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    // Load vehicles when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicles();
    });
  }

  void _loadVehicles() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<VehicleBloc>().add(LoadUserVehicles(authState.user.id!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<VehicleBloc, VehicleState>(
      listener: (context, state) {
        // Show snackbar for success/error messages
        if (state is VehicleOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              backgroundColor: ParkOSColors.mediumGreen, // Better contrast than darkGreen
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else if (state is VehicleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              backgroundColor: ParkOSColors.errorRed,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Show loading indicator
        if (state is VehicleLoading || state is VehicleInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get vehicles from state
        List<VehicleEntity> vehicles = [];
        if (state is VehicleLoaded) {
          vehicles = state.vehicles;
        } else if (state is VehicleOperationInProgress) {
          vehicles = state.vehicles;
        } else if (state is VehicleOperationSuccess) {
          vehicles = state.vehicles;
        }

        // Main content
        return Stack(
          children: [
            // Vehicle list
            vehicles.isEmpty ? _buildEmptyState(context) : _buildVehicleList(context, vehicles, state),

            // Add vehicle FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: (state is VehicleOperationInProgress) ? null : () => _addVehicle(context),
                backgroundColor: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen,
                foregroundColor: isDark ? Colors.black : Colors.white,
                child: Icon(MdiIcons.plus),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(MdiIcons.carOff, size: 64, color: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen),
          const SizedBox(height: 16),
          Text('No Vehicles Found', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Add your first vehicle to get started', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addVehicle(context),
            icon: Icon(MdiIcons.plus),
            label: const Text('Add Vehicle'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.brightness == Brightness.dark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen,
              foregroundColor: theme.brightness == Brightness.dark ? Colors.black : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context, List<VehicleEntity> vehicles, VehicleState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage your registered vehicles', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: vehicles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];

                // Get parking status from state (if implemented)
                bool isParked = false;
                if (state is VehicleLoaded) {
                  isParked = state.isVehicleParked(vehicle.id ?? '');
                }

                // Check if operation is in progress for this vehicle
                bool isOperating = false;
                if (state is VehicleOperationInProgress) {
                  isOperating = true;
                }

                return VehicleCard(
                  vehicle: vehicle,
                  isParked: isParked,
                  onEdit: isOperating ? null : () => _editVehicle(context, vehicle),
                  onDelete: isOperating ? null : () => _deleteVehicle(context, vehicle),
                  onPark: (isParked || isOperating) ? null : () => _parkVehicle(context, vehicle),
                  onViewDetails: () => _viewVehicleDetails(context, vehicle),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addVehicle(BuildContext context) {
    // Navigate to form screen with BLoC
    Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider.value(value: BlocProvider.of<VehicleBloc>(context), child: const VehicleFormScreen()))).then((_) {
      // Reload vehicles after returning from form
      _loadVehicles();
    });
  }

  void _editVehicle(BuildContext context, VehicleEntity vehicle) {
    // Navigate to form screen with BLoC
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlocProvider.value(value: BlocProvider.of<VehicleBloc>(context), child: VehicleFormScreen(vehicle: vehicle))),
    ).then((_) {
      // Reload vehicles after returning from form
      _loadVehicles();
    });
  }

  void _deleteVehicle(BuildContext context, VehicleEntity vehicle) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Vehicle'),
            content: Text('Are you sure you want to delete ${vehicle.registrationNumber}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.read<VehicleBloc>().add(DeleteVehicle(vehicle.id!));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _parkVehicle(BuildContext context, VehicleEntity vehicle) {
    // Navigate to parking screen
    Navigator.pushNamed(context, '/parking', arguments: {'vehicleId': vehicle.id});
  }

  void _viewVehicleDetails(BuildContext context, VehicleEntity vehicle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: isDark ? ParkOSColors.darkSurface : ParkOSColors.lightSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                Icon(MdiIcons.car, color: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen),
                const SizedBox(width: 8),
                Text(vehicle.registrationNumber, style: TextStyle(color: isDark ? ParkOSColors.darkTextPrimary : ParkOSColors.lightTextPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', vehicle.type, isDark),
                const SizedBox(height: 12),
                _buildDetailRow('Owner', vehicle.ownerName ?? 'Unknown', isDark),
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Status',
                  'Available', // You can make this dynamic based on parking status
                  isDark,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 16, color: isDark ? ParkOSColors.darkTextSecondary : ParkOSColors.lightTextSecondary))),
      ],
    );
  }
}
