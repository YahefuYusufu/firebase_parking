import 'package:firebase_parking/config/theme/theme_provider.dart';
import 'package:firebase_parking/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:firebase_parking/presentation/pages/parking/parking_screen.dart';
import 'package:firebase_parking/presentation/pages/profile/profile_screen.dart';
import 'package:firebase_parking/presentation/pages/vehicles/vehicles_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';

class DesktopScaffold extends StatefulWidget {
  final int initialIndex;

  const DesktopScaffold({super.key, this.initialIndex = 0});

  @override
  // ignore: library_private_types_in_public_api
  _DesktopScaffoldState createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  late int _selectedIndex;

  // Use the actual screens directly
  final List<Widget> _screens = [DashboardScreen(), VehiclesScreen(), ParkingScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: _getAppBarTitle(),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? MdiIcons.weatherSunny : MdiIcons.weatherNight),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Desktop sidebar navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(icon: Icon(MdiIcons.homeOutline), selectedIcon: Icon(MdiIcons.home), label: Text('Home')),
              NavigationRailDestination(icon: Icon(MdiIcons.carOutline), selectedIcon: Icon(MdiIcons.car), label: Text('Vehicles')),
              NavigationRailDestination(icon: Icon(MdiIcons.alphaP), selectedIcon: Icon(MdiIcons.parking), label: Text('Parking')),
              NavigationRailDestination(icon: Icon(MdiIcons.accountOutline), selectedIcon: Icon(MdiIcons.account), label: Text('Profile')),
            ],
          ),
          // Content area
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return Text('Parking Dashboard');
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
