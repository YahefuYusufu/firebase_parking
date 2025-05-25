import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _hasInitializedVehicleWatch = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Get user data from authenticated state
          final user = state.user;

          // Start watching user vehicles when screen loads (only once)
          if (!_hasInitializedVehicleWatch) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (user.id != null && !_hasInitializedVehicleWatch) {
                print("ProfileScreen: Starting to watch vehicles for user: ${user.id}");
                context.read<VehicleBloc>().add(WatchUserVehicles(user.id!));
                _hasInitializedVehicleWatch = true;
              } else {
                print("ProfileScreen: User ID is null, cannot watch vehicles");
              }
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile header with avatar and basic info
                  Card(
                    elevation: isDark ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isDark ? BorderSide(color: theme.colorScheme.primary.withAlpha((0.3 * 255).round())) : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                            child: Icon(MdiIcons.account, size: 64, color: theme.colorScheme.primary),
                          ),
                          const SizedBox(height: 16),

                          // User's name
                          Text(user.name ?? 'User', style: theme.textTheme.headlineSmall?.copyWith(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),

                          // User's email
                          if (user.email != null)
                            Text(
                              user.email!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: isDark ? 'Source Code Pro' : null,
                                color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Personal Number
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(16),
                              border: isDark ? Border.all(color: theme.colorScheme.primary.withAlpha((0.3 * 255).round())) : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(MdiIcons.identifier, size: 18, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text('ID: ${user.personalNumber ?? 'Not set'}', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Edit Profile Button - Prominently positioned right under profile info
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/edit-profile');
                              },
                              icon: Icon(MdiIcons.accountEdit),
                              label: Text(isDark ? 'EDIT PROFILE' : 'Edit Profile', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.primary), padding: const EdgeInsets.symmetric(vertical: 12.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vehicles section with BlocBuilder
                  _buildVehiclesSection(context, user.id),

                  _buildExpandableSection(
                    context,
                    title: isDark ? 'PARKING HISTORY' : 'Parking History',
                    icon: MdiIcons.history,
                    children: [
                      // This will be populated when you have parking history data
                      _buildEmptyStateCard(context, message: 'No parking history yet', buttonText: null),
                    ],
                  ),

                  _buildExpandableSection(
                    context,
                    title: isDark ? 'PAYMENT METHODS' : 'Payment Methods',
                    icon: MdiIcons.creditCardOutline,
                    children: [
                      // This will be populated when you have payment methods data
                      _buildEmptyStateCard(
                        context,
                        message: 'No payment methods added yet',
                        buttonText: 'Add Payment Method',
                        onTap: () {
                          // Navigate to payment method screen when implemented
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Coming soon')));
                        },
                      ),
                    ],
                  ),

                  // System information (in terminal style for dark mode)
                  if (isDark)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(border: Border.all(color: theme.colorScheme.primary.withAlpha((0.3 * 255).round())), borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Text('SYSTEM: USER SESSION ACTIVE', style: TextStyle(fontFamily: 'Source Code Pro', fontSize: 10, color: theme.colorScheme.primary, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(
                              'UID: ${user.id ?? 'UNKNOWN'}',
                              style: TextStyle(fontFamily: 'Source Code Pro', fontSize: 10, color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round())),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        // Show loading state while checking authentication
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Vehicles section with BlocBuilder
  Widget _buildVehiclesSection(BuildContext context, String? userId) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, vehicleState) {
        print("ProfileScreen: VehicleState changed to: ${vehicleState.runtimeType}");

        List<Widget> children = [];

        if (vehicleState is VehicleLoading) {
          print("ProfileScreen: Showing loading state");
          children = [const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))];
        } else if (vehicleState is VehicleError) {
          print("ProfileScreen: Showing error state: ${vehicleState.message}");
          children = [_buildErrorCard(context, vehicleState.message)];
        } else if (vehicleState is VehicleLoaded) {
          print("ProfileScreen: Showing loaded state with ${vehicleState.vehicles.length} vehicles");
          if (vehicleState.vehicles.isEmpty) {
            children = [_buildEmptyStateCard(context, message: 'No vehicles added yet', buttonText: null)];
          } else {
            // Show vehicle count badge
            children = [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: isDark ? Border.all(color: theme.colorScheme.primary.withAlpha((0.3 * 255).round())) : null,
                  ),
                  child: Text(
                    '${vehicleState.vehicles.length} vehicle${vehicleState.vehicles.length == 1 ? '' : 's'}',
                    style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontSize: 12, fontWeight: FontWeight.w500, color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Vehicle cards
              ...vehicleState.vehicles.map((vehicle) => _buildVehicleCard(context, vehicle)),
            ];
          }
        } else {
          // Initial state
          children = [_buildEmptyStateCard(context, message: 'No vehicles added yet', buttonText: null)];
        }

        return _buildExpandableSection(context, title: isDark ? 'MY VEHICLES' : 'My Vehicles', icon: MdiIcons.carMultiple, children: children);
      },
    );
  }

  // Vehicle card widget
  Widget _buildVehicleCard(BuildContext context, VehicleEntity vehicle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get vehicle type icon
    IconData vehicleIcon;
    switch (vehicle.type.toLowerCase()) {
      case 'motorcycle':
        vehicleIcon = MdiIcons.motorbike;
        break;
      case 'truck':
        vehicleIcon = MdiIcons.truck;
        break;
      case 'van':
        vehicleIcon = MdiIcons.vanUtility;
        break;
      case 'bus':
        vehicleIcon = MdiIcons.bus;
        break;
      default:
        vehicleIcon = MdiIcons.car;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withAlpha((0.2 * 255).round()) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? theme.colorScheme.primary.withAlpha((0.2 * 255).round()) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: theme.colorScheme.primary.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(8)),
            child: Icon(vehicleIcon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName, style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  vehicle.type.toUpperCase(),
                  style: TextStyle(
                    fontFamily: isDark ? 'Source Code Pro' : null,
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                    letterSpacing: isDark ? 1 : 0,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(MdiIcons.dotsVertical, color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round())),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  Navigator.pushNamed(context, '/vehicles/edit', arguments: vehicle);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context, vehicle);
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'edit', child: Row(children: [Icon(MdiIcons.pencil, size: 16), const SizedBox(width: 8), Text(isDark ? 'EDIT' : 'Edit')])),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(MdiIcons.delete, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(isDark ? 'DELETE' : 'Delete', style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  // Error card widget
  Widget _buildErrorCard(BuildContext context, String message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withAlpha((0.1 * 255).round()) : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withAlpha((0.3 * 255).round())),
      ),
      child: Column(
        children: [
          Icon(MdiIcons.alertCircle, color: Colors.red, size: 24),
          const SizedBox(height: 8),
          Text('Error loading vehicles', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontSize: 12, color: Colors.red.withAlpha((0.8 * 255).round())),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {
              final user = context.read<AuthBloc>().state;
              if (user is Authenticated && user.user.id != null) {
                context.read<VehicleBloc>().add(WatchUserVehicles(user.user.id!));
              }
            },
            icon: Icon(MdiIcons.refresh, size: 16),
            label: Text(isDark ? 'RETRY' : 'Retry', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context, VehicleEntity vehicle) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isDark ? 'DELETE VEHICLE' : 'Delete Vehicle', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null)),
            content: Text('Are you sure you want to delete ${vehicle.displayName}? This action cannot be undone.', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(isDark ? 'CANCEL' : 'Cancel', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null))),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (vehicle.id != null) {
                    context.read<VehicleBloc>().add(DeleteVehicle(vehicle.id!));
                  }
                },
                child: Text(isDark ? 'DELETE' : 'Delete', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Expandable section widget
  Widget _buildExpandableSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark ? BorderSide(color: theme.colorScheme.primary.withAlpha((0.3 * 255).round())) : BorderSide.none,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: isDark ? 1 : 0)),
              ],
            ),
            iconColor: theme.colorScheme.primary,
            collapsedIconColor: theme.colorScheme.primary,
            children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children))],
          ),
        ),
      ),
    );
  }

  // Empty state card widget
  Widget _buildEmptyStateCard(BuildContext context, {required String message, String? buttonText, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? theme.colorScheme.primary.withAlpha((0.2 * 255).round()) : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(message, style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()))),
          if (buttonText != null && onTap != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onTap,
              icon: Icon(MdiIcons.plus, size: 16),
              label: Text(buttonText, style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
