import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_event.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_state.dart';
import 'widgets/space_creation_form.dart';
import 'widgets/space_edit_form.dart';
import 'widgets/space_list_management.dart';

class ManageSpacesTab extends StatefulWidget {
  const ManageSpacesTab({super.key});

  @override
  State<ManageSpacesTab> createState() => _ManageSpacesTabState();
}

class _ManageSpacesTabState extends State<ManageSpacesTab> with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController; // Shimmer animation controller

  @override
  void initState() {
    super.initState();

    // Initialize shimmer animation controller
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    // Load parking spaces when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParkingSpaceBloc>().add(GetAllParkingSpacesEvent());
    });
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  void _navigateToCreateSpaceForm() async {
    if (!mounted) return;

    // Pass the bloc to the form screen
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => BlocProvider.value(value: BlocProvider.of<ParkingSpaceBloc>(context), child: const SpaceCreationForm())));

    if (result == true && mounted) {
      // Refresh the list
      context.read<ParkingSpaceBloc>().add(GetAllParkingSpacesEvent());
    }
  }

  void _navigateToEditSpaceForm(ParkingSpaceEntity space) async {
    if (!mounted) return;

    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => BlocProvider.value(value: BlocProvider.of<ParkingSpaceBloc>(context), child: SpaceEditForm(space: space))));

    if (result == true && mounted) {
      // Refresh the list
      context.read<ParkingSpaceBloc>().add(GetAllParkingSpacesEvent());
    }
  }

  void _showDeleteConfirmation(ParkingSpaceEntity space) {
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
                  if (space.id != null) {
                    context.read<ParkingSpaceBloc>().add(DeleteParkingSpaceEvent(space.id!));
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('DELETE'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParkingSpaceBloc, ParkingSpaceState>(
      listener: (context, state) {
        // Show snackbar for success/error messages
        if (state is ParkingSpaceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else if (state is ParkingSpaceCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parking space created successfully'),
              backgroundColor: ParkOSColors.mediumGreen,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else if (state is ParkingSpaceUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parking space updated successfully'),
              backgroundColor: ParkOSColors.mediumGreen,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else if (state is ParkingSpaceDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Parking space deleted successfully'),
              backgroundColor: ParkOSColors.mediumGreen,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      },
      builder: (context, state) {
        // Determine if we're in a loading state
        final bool isLoading = state is ParkingSpacesLoading || state is ParkingSpaceCreating || state is ParkingSpaceUpdating || state is ParkingSpaceDeleting;

        // Get the list of spaces if available, otherwise empty list
        List<ParkingSpaceEntity> spaces = [];

        if (state is ParkingSpacesLoaded) {
          spaces = state.spaces;
        }

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

              // If spaces are empty and not loading, show empty state
              // Otherwise, use the SpaceListManagement widget
              Expanded(
                child:
                    spaces.isEmpty && !isLoading
                        ? _buildEmptyState()
                        : SpaceListManagement(
                          spaces: spaces,
                          onEditSpace: _navigateToEditSpaceForm,
                          onDeleteSpace: _showDeleteConfirmation,
                          isLoading: isLoading,
                          loadingBuilder: _buildLoadingAnimation,
                        ),
              ),
            ],
          ),
        );
      },
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
