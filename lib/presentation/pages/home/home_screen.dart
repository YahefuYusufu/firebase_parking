import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onIndexChanged;
  final int selectedIndex;

  const HomeScreen({super.key, required this.selectedIndex, required this.onIndexChanged});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [_PlaceholderScreen('Dashboard'), _PlaceholderScreen('Vehicles'), _PlaceholderScreen('Parking'), _PlaceholderScreen('Profile')];
  }

  @override
  Widget build(BuildContext context) {
    // Return only the content without Scaffold
    return _screens[widget.selectedIndex];
  }
}

// Placeholder widget for empty screens
class _PlaceholderScreen extends StatelessWidget {
  final String screenName;

  const _PlaceholderScreen(this.screenName);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 16),
          Text('$screenName Screen', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 8),
          Text('To be implemented', style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
