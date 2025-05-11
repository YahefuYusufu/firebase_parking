import 'package:firebase_parking/presentation/pages/vehicles/widgets/vehicle_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../parking/parking_screen.dart';
import 'quick_action_card.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        QuickActionCard(title: 'Park Vehicle', icon: MdiIcons.parking, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ParkingScreen()))),
        QuickActionCard(
          title: 'Add Vehicle',
          icon: MdiIcons.plusBox, // This icon isn't appearing
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleFormScreen())),
        ),
        QuickActionCard(title: 'Report Issue', icon: MdiIcons.alertCircleOutline, onTap: () => _showReportDialog(context)),
      ],
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Report an Issue'),
            content: TextField(maxLines: 5, decoration: InputDecoration(hintText: 'Describe the issue...', border: OutlineInputBorder())),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Issue reported successfully')));
                },
                child: Text('Submit'),
              ),
            ],
          ),
    );
  }
}
