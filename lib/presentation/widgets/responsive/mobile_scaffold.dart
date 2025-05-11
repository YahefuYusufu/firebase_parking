import 'package:firebase_parking/config/theme/theme_provider.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_event.dart';
import 'package:firebase_parking/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:firebase_parking/presentation/pages/parking/parking_screen.dart';
import 'package:firebase_parking/presentation/pages/profile/profile_screen.dart';
import 'package:firebase_parking/presentation/pages/vehicles/vehicles_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class MobileScaffold extends StatefulWidget {
  final int initialIndex;

  const MobileScaffold({super.key, this.initialIndex = 0});

  @override
  // ignore: library_private_types_in_public_api
  _MobileScaffoldState createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  late int _selectedIndex;

  // Use the actual screens instead of placeholders
  final List<Widget> _screens = [DashboardScreen(), VehiclesScreen(), ParkingScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _handleLogout(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Show a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isDark ? 'CONFIRM LOGOUT' : 'Logout', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
          content: Text(
            isDark ? '> Are you sure you want to terminate your current session?' : 'Are you sure you want to logout?',
            style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(isDark ? 'CANCEL' : 'Cancel', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog

                // Dispatch SignOutRequested event to AuthBloc
                context.read<AuthBloc>().add(SignOutRequested());

                // We don't need to navigate manually here anymore
                // The BlocListener in the main app will handle navigation
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(isDark ? 'CONFIRM_LOGOUT' : 'Logout', style: TextStyle(fontFamily: isDark ? 'Source Code Pro' : null, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider at the build level
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: _getAppBarTitle(), actions: _buildAppBarActions(context, themeProvider)),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(MdiIcons.homeOutline), selectedIcon: Icon(MdiIcons.home), label: 'Home'),
          NavigationDestination(icon: Icon(MdiIcons.carOutline), selectedIcon: Icon(MdiIcons.car), label: 'Vehicles'),
          NavigationDestination(icon: Icon(MdiIcons.alphaP, size: 32), selectedIcon: Icon(MdiIcons.parking), label: 'Parking'),
          NavigationDestination(icon: Icon(MdiIcons.accountOutline), selectedIcon: Icon(MdiIcons.account), label: 'Profile'),
        ],
      ),
    );
  }

  // Helper method to build app bar actions
  List<Widget>? _buildAppBarActions(BuildContext context, ThemeProvider themeProvider) {
    // Only show menu in Profile tab
    if (_selectedIndex == 3) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return [
        PopupMenuButton<String>(
          // Use contrast color instead of primary
          icon: Icon(
            MdiIcons.dotsVertical,
            // For light mode, use onPrimary to contrast with the green app bar
            // For dark mode, keep using primary
            color: isDark ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
          ),
          onSelected: (value) {
            switch (value) {
              case 'theme':
                themeProvider.toggleTheme();
                break;
              case 'logout':
                _handleLogout(context);
                break;
            }
          },
          itemBuilder:
              (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'theme',
                  child: Row(
                    children: [
                      Icon(themeProvider.isDarkMode ? MdiIcons.weatherNight : MdiIcons.weatherSunny, size: 22, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text(themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode'),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(children: [Icon(MdiIcons.logout, size: 22, color: Colors.red), SizedBox(width: 12), Text('Logout', style: TextStyle(color: Colors.red))]),
                ),
              ],
        ),
      ];
    }
    return null; // No actions for other tabs
  }

  Widget _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return Text('Dashboard');
      case 1:
        return Text('My Vehicles');
      case 2:
        return Text('Find Parking');
      case 3:
        return Text('Profile');
      default:
        return Text('Parking System');
    }
  }
}
