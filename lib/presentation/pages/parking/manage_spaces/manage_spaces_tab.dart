import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/data/models/parking_space.dart';
import 'package:flutter/material.dart';
import 'widgets/space_creation_form.dart';
import 'widgets/space_edit_form.dart';
import 'widgets/space_list_management.dart';

class ManageSpacesTab extends StatefulWidget {
  const ManageSpacesTab({super.key});

  @override
  State<ManageSpacesTab> createState() => _ManageSpacesTabState();
}

class _ManageSpacesTabState extends State<ManageSpacesTab> with SingleTickerProviderStateMixin {
  List<ParkingSpace> managedSpaces = [];
  bool isLoading = true; // Start with loading state
  AnimationController? _shimmerController; // Shimmer animation controller

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation controller
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _loadParkingSpaces();
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  // Load parking spaces from your backend
  Future<void> _loadParkingSpaces() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      // For now, use sample data
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate network delay
      final sampleSpaces = [
        ParkingSpace(id: '1', spaceNumber: 'A101', type: 'regular', status: 'vacant', level: '1', section: 'A', hourlyRate: 2.50),
        ParkingSpace(id: '2', spaceNumber: 'B205', type: 'handicapped', status: 'vacant', level: '2', section: 'B', hourlyRate: 2.00),
        ParkingSpace(id: '3', spaceNumber: 'C103', type: 'electric', status: 'vacant', level: '1', section: 'C', hourlyRate: 3.00),
        ParkingSpace(id: '4', spaceNumber: 'A203', type: 'compact', status: 'vacant', level: '2', section: 'A', hourlyRate: 2.25),
      ];

      if (!mounted) return;

      setState(() {
        managedSpaces = sampleSpaces;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load parking spaces: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  void _navigateToCreateSpaceForm() async {
    if (!mounted) return;

    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SpaceCreationForm(onSpaceCreated: _handleSpaceCreated)));

    if (result != null && mounted) {
      // Space was created, refresh the list
      _loadParkingSpaces();
    }
  }

  void _handleSpaceCreated(ParkingSpace newSpace) async {
    if (!mounted) return;

    setState(() {
      managedSpaces.add(newSpace);
    });
    Navigator.of(context).pop(newSpace);
  }

  void _navigateToEditSpaceForm(ParkingSpace space) async {
    if (!mounted) return;

    final result = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => SpaceEditForm(space: space, onSpaceUpdated: _handleSpaceUpdated)));

    if (result != null && mounted) {
      // Space was updated, refresh the list
      _loadParkingSpaces();
    }
  }

  void _handleSpaceUpdated(ParkingSpace updatedSpace) async {
    if (!mounted) return;

    setState(() {
      final index = managedSpaces.indexWhere((space) => space.id == updatedSpace.id);
      if (index != -1) {
        managedSpaces[index] = updatedSpace;
      }
    });
    Navigator.of(context).pop(updatedSpace);
  }

  void _showDeleteConfirmation(ParkingSpace space) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Parking Space'),
            content: Text('Are you sure you want to delete Space ${space.spaceNumber}?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('CANCEL')),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteSpace(space);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  void _deleteSpace(ParkingSpace space) async {
    try {
      if (!mounted) return;

      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 1000));

      if (!mounted) return;

      setState(() {
        managedSpaces.removeWhere((s) => s.id == space.id);
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Space ${space.spaceNumber} deleted successfully')));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete space: ${e.toString()}'), backgroundColor: Colors.red));
      }
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
            padding: const EdgeInsets.only(top: 20.0),
            child: Row(
              children: [
                Container(width: 32, height: 32, alignment: Alignment.center, child: const Text('🅿️', style: TextStyle(fontSize: 20))),
                const SizedBox(width: 8),
                Text('Manage Parking Spaces', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Always show the Add Space button
          ElevatedButton(
            onPressed: _navigateToCreateSpaceForm,
            child: Row(mainAxisSize: MainAxisSize.min, children: const [Text('➕', style: TextStyle(fontSize: 18)), SizedBox(width: 8), Text('Add Space')]),
          ),

          const SizedBox(height: 16),

          // Always show SpaceListManagement with our custom loading state
          // This keeps filters visible while showing loading animation for just the list
          Expanded(
            child:
                managedSpaces.isEmpty && !isLoading
                    ? _buildEmptyState()
                    : SpaceListManagement(
                      spaces: managedSpaces,
                      onEditSpace: _navigateToEditSpaceForm,
                      onDeleteSpace: _showDeleteConfirmation,
                      // Pass our loading state, but let SpaceListManagement handle it
                      isLoading: isLoading,
                      // Custom loading builder to replace default CircularProgressIndicator
                      loadingBuilder: _buildLoadingAnimation,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('P', style: TextStyle(fontSize: 64, color: Colors.grey[400], fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('No parking spaces created yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Get started by adding your first parking space', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _navigateToCreateSpaceForm,
            child: Row(mainAxisSize: MainAxisSize.min, children: const [Text('➕', style: TextStyle(fontSize: 18)), SizedBox(width: 8), Text('Create First Space')]),
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
      color: baseColor, // Will use appropriate theme color
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [baseColor, shimmerColor, baseColor], stops: [0.0, animationValue, 1.0], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Leading circle
            Container(width: 48, height: 48, decoration: BoxDecoration(color: elementColor, shape: BoxShape.circle)),
            const SizedBox(width: 16),

            // Main content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title skeleton
                  Container(height: 18, width: 120, decoration: BoxDecoration(color: elementColor, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),

                  // Subtitle skeleton
                  Container(height: 14, width: 180, decoration: BoxDecoration(color: elementColor, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),

            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: elementColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor, // Use accent color for second button
                    shape: BoxShape.circle,
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
