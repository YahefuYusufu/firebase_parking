import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_parking/presentation/blocs/notification/notification_bloc.dart';
import 'package:firebase_parking/presentation/blocs/notification/notification_event.dart';
import 'package:firebase_parking/presentation/blocs/notification/notification_state.dart';
import 'find_parking/find_parking_tab.dart';
import 'manage_spaces/manage_spaces_tab.dart';

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Request notification permissions when parking screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(const RequestNotificationPermissions());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // void _goBack() {
  //   Navigator.of(context).pop();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        if (state is NotificationPermissionGranted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔔 Parking reminders enabled!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)));
        } else if (state is NotificationPermissionDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('⚠️ Enable notifications in Settings for parking reminders'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        } else if (state is NotificationError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('❌ Notification error: ${state.message}'), backgroundColor: Colors.red, duration: const Duration(seconds: 3)));
        }
      },
      child: Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Top padding for status bar
            SizedBox(height: MediaQuery.of(context).padding.top),

            // // Header with back button
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       // Back button
            //       InkWell(
            //         onTap: _goBack,
            //         child: Container(
            //           width: 40,
            //           height: 40,
            //           decoration: BoxDecoration(
            //             color: Theme.of(context).colorScheme.surface,
            //             borderRadius: BorderRadius.circular(20),
            //             border: Border.all(color: Theme.of(context).colorScheme.outline.withAlpha(50)),
            //           ),
            //           alignment: Alignment.center,
            //           child: const Text('◀️', style: TextStyle(fontSize: 22)),
            //         ),
            //       ),

            //       // Header text
            //       Text('Parking', style: Theme.of(context).textTheme.headlineSmall),

            //       // Empty space with same width as back button for balance
            //       const SizedBox(width: 40),
            //     ],
            //   ),
            // ),

            // Reduced spacing after header
            const SizedBox(height: 16),

            // TabBar with improved styling for better visibility
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Find Parking'),
                      const SizedBox(width: 8),
                      // Optional: Show notification status indicator on Find Parking tab
                      _buildNotificationStatusIndicator(),
                    ],
                  ),
                ),
                const Tab(text: 'Manage Spaces', height: 48),
              ],
              // Use stronger colors to ensure visibility
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey[700], // Darker grey for unselected tabs
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3, // Thicker indicator line
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, // Bold text for better visibility
                fontSize: 16, // Larger text size
              ),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),

            // Add padding between tabs and content
            const SizedBox(height: 12),

            // TabBarView with padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TabBarView(controller: _tabController, children: const [FindParkingTab(), ManageSpacesTab()]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Small notification status indicator
  Widget _buildNotificationStatusIndicator() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationPermissionGranted || (state is NotificationInitialized && state.permissionsGranted)) {
          return Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle));
        } else if (state is NotificationPermissionDenied) {
          return Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
