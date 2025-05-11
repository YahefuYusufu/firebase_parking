import 'package:firebase_parking/data/models/parking_space.dart';
import 'package:firebase_parking/presentation/pages/parking/shared/parking_space_card.dart';
import 'package:flutter/material.dart';

class SpaceListWidget extends StatelessWidget {
  final List<ParkingSpace> spaces;
  final Function(ParkingSpace) onSpaceSelected;
  final bool isLoading;

  const SpaceListWidget({super.key, required this.spaces, required this.onSpaceSelected, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (spaces.isEmpty) {
      // Wrap this in a SingleChildScrollView to handle overflow
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Add this to minimize height
            children: [
              Icon(Icons.local_parking, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('No parking spaces available', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Try adjusting your filters or check back later', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: spaces.length,
      itemBuilder: (context, index) {
        final space = spaces[index];
        return ParkingSpaceCard(space: space, onTap: () => onSpaceSelected(space));
      },
    );
  }
}
