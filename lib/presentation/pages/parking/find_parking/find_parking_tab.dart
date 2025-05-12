import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/data/models/parking_space/parking_space.dart';
import 'package:flutter/material.dart';
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
  bool isLoading = true; // Start with loading state
  AnimationController? _shimmerController; // Make nullable to avoid late initialization error

  List<ParkingSpace> allSpaces = [
    ParkingSpace(id: '1', spaceNumber: 'A101', type: 'regular', status: 'vacant', level: '1', section: 'A', hourlyRate: 2.50),
    ParkingSpace(id: '2', spaceNumber: 'B205', type: 'handicapped', status: 'vacant', level: '2', section: 'B', hourlyRate: 2.00),
    ParkingSpace(id: '3', spaceNumber: 'C103', type: 'electric', status: 'vacant', level: '1', section: 'C', hourlyRate: 3.00),
    ParkingSpace(id: '4', spaceNumber: 'A203', type: 'compact', status: 'vacant', level: '2', section: 'A', hourlyRate: 2.25),
  ];

  List<ParkingSpace> filteredSpaces = [];

  @override
  void initState() {
    super.initState();

    // Initialize the shimmer animation controller
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    // Simulate loading data
    _loadSpaces();
  }

  // Simulate loading data with a delay
  void _loadSpaces() async {
    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        filteredSpaces = allSpaces;
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose(); // Use safe call in case it wasn't initialized
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

    // Simulate filter processing delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          filteredSpaces =
              allSpaces.where((space) {
                bool matchesSection = filterSection == null || space.section == filterSection;
                bool matchesLevel = filterLevel == null || space.level == filterLevel;
                bool matchesType = filterType == null || space.type.toLowerCase() == filterType;

                return matchesSection && matchesLevel && matchesType && space.status.toLowerCase() == 'vacant';
              }).toList();

          isLoading = false;
        });
      }
    });
  }

  void _handleSpaceSelected(ParkingSpace space) async {
    if (!mounted) return;

    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => BookingFormWidget(space: space)));

    if (result == true && mounted) {
      setState(() {
        final index = allSpaces.indexWhere((s) => s.id == space.id);
        if (index != -1) {
          final updatedSpace = ParkingSpace(
            id: space.id,
            spaceNumber: space.spaceNumber,
            type: space.type,
            status: 'occupied',
            level: space.level,
            section: space.section,
            hourlyRate: space.hourlyRate,
          );

          allSpaces[index] = updatedSpace;
          _applyFilters(filterSection, filterLevel, filterType);
        }
      });
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

          // Space list with loading animation
          Expanded(child: isLoading ? _buildLoadingAnimation() : SpaceListWidget(spaces: filteredSpaces, onSpaceSelected: _handleSpaceSelected, isLoading: false)),
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
      color: baseColor, // Will use lightSurface in light mode
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
                Container(
                  height: 24,
                  width: 70,
                  decoration: BoxDecoration(
                    color: accentColor, // Keep using darkGreen for the button
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
