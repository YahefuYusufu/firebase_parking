import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/pages/dashboard/widgets/parked_vehicle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Currently Parked', style: theme.textTheme.titleLarge), IconButton(onPressed: _loadActiveParking, icon: const Icon(Icons.refresh), tooltip: 'Refresh')],
        ),
        const SizedBox(height: 12),
        BlocBuilder<ParkingBloc, ParkingState>(
          builder: (context, state) {
            print('🔍 Current state: $state');

            if (state is ParkingLoading) {
              return const Card(child: Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator())));
            }

            if (state is ParkingError) {
              print('❌ Error: ${state.message}');
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error loading parking data', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(state.message, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(onPressed: _loadActiveParking, icon: const Icon(Icons.refresh), label: const Text('Try Again')),
                    ],
                  ),
                ),
              );
            }

            final activeParking = _getActiveParkingFromState(state);
            print('📊 Found ${activeParking.length} active parking sessions');

            if (activeParking.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.local_parking_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No Active Parking', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Text('You don\'t have any active parking sessions', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children:
                  activeParking.map((parking) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ParkedVehicleCard(
                        parking: parking, // Now passing ParkingEntity (not ParkingModel)
                        onParkingEnded: _loadActiveParking,
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  // Updated to return List<ParkingEntity> (which is what your BLoC actually returns)
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
