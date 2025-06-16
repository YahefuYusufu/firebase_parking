import 'package:firebase_parking/presentation/pages/dashboard/widgets/currently_parked_section.dart';
import 'package:firebase_parking/presentation/pages/dashboard/widgets/quick_actions_grid.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/dashboard_stats.dart';
import 'widgets/recent_activity_card.dart';
import 'widgets/system_status_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _dashboardStatsKey = GlobalKey();
  final GlobalKey _currentlyParkedKey = GlobalKey();

  void _refreshAllDashboardData() {
    print('🔄 Dashboard: Refreshing all data...');

    try {
      final dashboardStatsWidget = _dashboardStatsKey.currentWidget as DashboardStats?;
      if (dashboardStatsWidget != null) {
        // Trigger refresh via callback
        dashboardStatsWidget.onRefreshRequested?.call();
      }

      // Try to access the currently parked section widget
      final currentlyParkedWidget = _currentlyParkedKey.currentWidget as CurrentlyParkedSection?;
      if (currentlyParkedWidget != null) {
        // Trigger refresh via callback
        currentlyParkedWidget.onRefreshRequested?.call();
      }
    } catch (e) {
      print('⚠️ Error accessing widget states: $e');
    }

    // Also trigger a general parking refresh as backup
    context.read<ParkingBloc>().add(GetActiveParkingEvent());
  }

  // Alternative simpler refresh approach
  void _forceRefreshAll() {
    print('🔄 Dashboard: Force refreshing all data...');

    // Simply trigger the bloc events directly
    context.read<ParkingBloc>().add(GetActiveParkingEvent());

    // Trigger a rebuild of the entire dashboard
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Listen for parking state changes at the dashboard level
    return BlocListener<ParkingBloc, ParkingState>(
      listener: (context, state) {
        print('🏠 Dashboard heard parking state: ${state.runtimeType}');

        // Listen for extension success and refresh all components
        String stateName = state.runtimeType.toString().toLowerCase();
        if (stateName.contains('success') || stateName.contains('updated') || stateName.contains('extended') || stateName.contains('complete')) {
          print('✅ Dashboard detected success, refreshing all components...');

          // Small delay to ensure backend is updated
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              _forceRefreshAll(); // Use the simpler approach
            }
          });
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Statistics (no refresh button)
            DashboardStats(key: _dashboardStatsKey, onRefreshRequested: _forceRefreshAll),

            const SizedBox(height: 20),

            // Quick Actions
            Text('Quick Actions', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            const QuickActionsGrid(),

            const SizedBox(height: 20),

            // Currently Parked (with the only refresh button)
            CurrentlyParkedSection(key: _currentlyParkedKey, onRefreshRequested: _forceRefreshAll),

            const SizedBox(height: 20),

            // Recent Activity
            const RecentActivityCard(),

            const SizedBox(height: 20),

            // System Status
            const SystemStatusCard(),

            // Add some bottom padding for better scroll experience
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
