import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:flutter/material.dart';

class ParkingSpaceCard extends StatelessWidget {
  final ParkingSpaceEntity space;
  final VoidCallback? onTap;

  const ParkingSpaceCard({super.key, required this.space, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      // Remove top margin to reduce space between filter and first card
      // Keep bottom margin for spacing between cards
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Space ${space.spaceNumber}', style: theme.textTheme.titleLarge), _buildStatusBadge(context)]),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Using emoji instead of MdiIcons
                  const Text('🅿️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('Section ${space.section}, Level ${space.level ?? 'G'}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(_getTypeEmoji(space.type.name), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text('${_getTypeLabel(space.type.name)} Space', style: theme.textTheme.bodyMedium),
                  const Spacer(),
                  Text('\$${space.hourlyRate.toStringAsFixed(2)}/hr', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    String statusText;

    if (space.status == ParkingSpaceStatus.vacant) {
      backgroundColor = Colors.green;
      statusText = 'Available';
    } else {
      backgroundColor = Colors.red;
      statusText = 'Occupied';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  // Using emojis instead of MdiIcons
  String _getTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'handicapped':
        return '♿';
      case 'compact':
        return '🚗';
      case 'electric':
        return '🔌';
      default:
        return '🚙';
    }
  }

  String _getTypeLabel(String type) {
    // Capitalize first letter
    return type.substring(0, 1).toUpperCase() + type.substring(1);
  }
}
