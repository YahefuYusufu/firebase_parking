import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'activity_item.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

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
            Text('Recent Activity', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            ActivityItem(title: 'Car parked: ABC123', time: 'Today, 10:30 AM', icon: MdiIcons.parking),
            const Divider(),
            ActivityItem(title: 'Vehicle added: XYZ789', time: 'Yesterday, 3:45 PM', icon: MdiIcons.plusBox),
            const Divider(),
            ActivityItem(title: 'Parking space added', time: 'Yesterday, 2:15 PM', icon: MdiIcons.plusCircleOutline),
          ],
        ),
      ),
    );
  }
}
