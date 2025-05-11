import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_card.dart';
import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_form_screen.dart';
import 'package:firebase_parking/services/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        // Show loading indicator while initializing
        if (!dataProvider.initialized || dataProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehicles = dataProvider.vehicles;

        // Main content
        return Stack(
          children: [
            // Vehicle list
            vehicles.isEmpty ? _buildEmptyState(context) : _buildVehicleList(context, vehicles, dataProvider),

            // Add vehicle FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _addVehicle(context),
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

  Widget _buildVehicleList(BuildContext context, List<dynamic> vehicles, DataProvider dataProvider) {
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
                // Check if the vehicle is parked - get this from your data provider
                final isParked = dataProvider.isVehicleParked(vehicle.id ?? '');

                return VehicleCard(
                  vehicle: vehicle,
                  isParked: isParked, // Pass the parking status explicitly
                  onEdit: () => _editVehicle(context, vehicle),
                  onDelete: () => _deleteVehicle(context, vehicle),
                  onPark: isParked ? null : () => _parkVehicle(context, vehicle),
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
    // Use the current provider instance for the new screen
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeNotifierProvider<DataProvider>.value(value: dataProvider, child: const VehicleFormScreen())));
  }

  void _editVehicle(BuildContext context, dynamic vehicle) {
    // Use the current provider instance for the new screen
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeNotifierProvider<DataProvider>.value(value: dataProvider, child: VehicleFormScreen(vehicle: vehicle))));
  }

  void _deleteVehicle(BuildContext context, dynamic vehicle) {
    final dataProvider = context.read<DataProvider>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Vehicle'),
            content: Text('Are you sure you want to delete ${vehicle.registrationNumber}?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  dataProvider.deleteVehicle(vehicle.id);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _parkVehicle(BuildContext context, dynamic vehicle) {
    // Get the current provider instance
    final _ = Provider.of<DataProvider>(context, listen: false);

    // Navigate to parking screen with provider
    Navigator.pushNamed(context, '/parking', arguments: {'vehicleId': vehicle.id});
  }

  void _viewVehicleDetails(BuildContext context, dynamic vehicle) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(vehicle.registrationNumber),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', vehicle.type),
                const SizedBox(height: 8),
                _buildDetailRow('Owner', vehicle.owner?.name ?? 'Unknown'),
                const SizedBox(height: 8),
                _buildDetailRow('Personal Number', vehicle.owner?.personalNumber ?? 'Unknown'),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(children: [Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)), Text(value)]);
  }
}
