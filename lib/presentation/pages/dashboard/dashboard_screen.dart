import 'package:firebase_parking/presentation/pages/dashboard/widgets/currently_parked_section.dart';
import 'package:firebase_parking/presentation/pages/dashboard/widgets/quick_actions_grid.dart';
import 'package:flutter/material.dart';
import 'widgets/dashboard_stats.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/system_status_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Statistics
          const DashboardStats(),

          const SizedBox(height: 20),

          // Quick Actions
          Text('Quick Actions', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          const QuickActionsGrid(),

          const SizedBox(height: 20),

          // Currently Parked
          const SizedBox(height: 12),
          const CurrentlyParkedSection(),

          const SizedBox(height: 20),

          // Recent Activity
          const RecentActivityCard(),

          const SizedBox(height: 20),

          // System Status
          const SystemStatusCard(),
        ],
      ),
    );
  }
}
