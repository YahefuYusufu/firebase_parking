import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          // Get user data from authenticated state
          final user = state.user;

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

                  // Expandable sections
                  _buildExpandableSection(
                    context,
                    title: isDark ? 'MY VEHICLES' : 'My Vehicles',
                    icon: MdiIcons.carMultiple,
                    children: [
                      // This will be populated when you have vehicle data
                      _buildEmptyStateCard(
                        context,
                        message: 'No vehicles added yet',
                        buttonText: 'Add Vehicle',
                        onTap: () {
                          Navigator.pushNamed(context, '/vehicles/add');
                        },
                      ),
                    ],
                  ),

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
