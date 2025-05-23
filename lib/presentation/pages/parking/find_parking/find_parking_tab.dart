// lib/presentation/pages/find_parking_tab.dart
import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_event.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets/space_filter_widget.dart';
import 'widgets/space_list_widget.dart';
import 'widgets/booking_form_widget.dart';

class FindParkingTab extends StatefulWidget {
  const FindParkingTab({super.key});

  @override
  State<FindParkingTab> createState() => _FindParkingTabState();
}

class _FindParkingTabState extends State<FindParkingTab> with SingleTickerProviderStateMixin {
  String? filterSection;
  String? filterLevel;
  String? filterType;
  bool isLoading = true;
  AnimationController? _shimmerController;

  @override
  void initState() {
    super.initState();

    // Initialize the shimmer animation controller
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    // Load parking spaces
    _loadSpaces();
  }

  void _loadSpaces() {
    context.read<ParkingSpaceBloc>().add(GetAvailableParkingSpacesEvent());
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  void _applyFilters(String? section, String? level, String? type) {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      filterSection = section;
      filterLevel = level;
      filterType = type?.toLowerCase();
    });

    // Add filter event to BLoC
    context.read<ParkingSpaceBloc>().add(GetFilteredParkingSpacesEvent(section: section, level: level, type: type?.toLowerCase()));
  }

  void _handleSpaceSelected(ParkingSpaceEntity space) async {
    if (!mounted) return;

    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookingFormWidget(space: space)));

    if (result == true && mounted) {
      _loadSpaces();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with added top padding
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              children: [
                Container(width: 32, height: 32, alignment: Alignment.center, child: const Text('🅿️', style: TextStyle(fontSize: 20))),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text('Available Parking Spaces', style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Filter widget with tight bottom margin
          Container(margin: const EdgeInsets.only(bottom: 0), child: SpaceFilterWidget(onFilterChanged: _applyFilters)),

          // Space list with BLoC integration
          Expanded(
            child: BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
              builder: (context, state) {
                if (state is ParkingSpacesLoading) {
                  return _buildLoadingAnimation();
                } else if (state is ParkingSpacesLoaded) {
                  return SpaceListWidget(spaces: state.spaces, onSpaceSelected: _handleSpaceSelected, isLoading: false);
                } else if (state is ParkingSpaceError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadSpaces, child: const Text('Try Again')),
                      ],
                    ),
                  );
                } else {
                  return _buildLoadingAnimation();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build the loading animation with skeleton cards
  Widget _buildLoadingAnimation() {
    return ListView.builder(
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) {
        return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: _buildSkeletonCard());
      },
    );
  }

  // Build a single skeleton card with ParkOS themed colors
  Widget _buildSkeletonCard() {
    // Use a controller value or default to 0.5 if controller is null
    final animationValue = _shimmerController?.value ?? 0.5;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use the appropriate ParkOS colors based on theme
    final baseColor = isDarkMode ? ParkOSColors.darkSurface : ParkOSColors.lightSurface;
    final shimmerColor = isDarkMode ? ParkOSColors.darkBackground : ParkOSColors.lightBackground;
    final elementColor = isDarkMode ? ParkOSColors.darkDivider : ParkOSColors.lightDivider;
    final accentColor = ParkOSColors.darkGreen;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: baseColor,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [baseColor, shimmerColor, baseColor], stops: [0.0, animationValue, 1.0], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title skeleton
            Container(height: 20, width: 150, decoration: BoxDecoration(color: elementColor, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 12),

            // Two lines of info
            Row(
              children: [
                Container(height: 14, width: 100, decoration: BoxDecoration(color: elementColor, borderRadius: BorderRadius.circular(4))),
                const Spacer(),
                Container(height: 14, width: 60, decoration: BoxDecoration(color: elementColor, borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const SizedBox(height: 8),

            // Last line
            Row(
              children: [
                Container(height: 14, width: 80, decoration: BoxDecoration(color: elementColor, borderRadius: BorderRadius.circular(4))),
                const Spacer(),
                Container(height: 24, width: 70, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(12))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
