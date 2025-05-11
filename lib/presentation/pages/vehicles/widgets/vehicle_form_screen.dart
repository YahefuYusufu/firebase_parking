import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/data/models/person.dart';
import 'package:firebase_parking/data/models/vehicle.dart';
import 'package:firebase_parking/services/data_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle; // Optional vehicle for editing

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  late TextEditingController _registrationController;
  late TextEditingController _typeController;
  String? _selectedOwnerId;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing vehicle data if in edit mode
    _registrationController = TextEditingController(text: widget.vehicle?.registrationNumber ?? '');
    _typeController = TextEditingController(text: widget.vehicle?.type ?? '');
    _selectedOwnerId = widget.vehicle?.ownerId;

    // Ensure data provider is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _registrationController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // Explicitly define the leading icon
        leading: IconButton(icon: Icon(MdiIcons.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Consumer<DataProvider>(
        builder: (context, dataProvider, child) {
          // Show loading while data initializes
          if (!dataProvider.initialized) {
            return const Center(child: CircularProgressIndicator());
          }

          final persons = dataProvider.persons;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Registration Number field
                  TextFormField(
                    controller: _registrationController,
                    decoration: InputDecoration(labelText: 'Registration Number', hintText: 'Enter vehicle registration number', prefixIcon: Icon(MdiIcons.cardText)),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a registration number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Vehicle Type field
                  TextFormField(
                    controller: _typeController,
                    decoration: InputDecoration(labelText: 'Vehicle Type', hintText: 'Enter vehicle type (e.g., Sedan, SUV)', prefixIcon: Icon(MdiIcons.car)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a vehicle type';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Owner Dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Owner',
                      prefixIcon: Icon(MdiIcons.account),
                      isCollapsed: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      // Make sure suffixIcon isn't conflicting with dropdown icon
                      suffixIcon: null,
                    ),
                    // Add this to customize the dropdown icon
                    icon: Icon(MdiIcons.menuDown),
                    // Rest of your code remains the same
                    value: _selectedOwnerId,
                    hint: const Text('Select owner'),
                    // ...

                    // Add this to ensure the dropdown isn't too wide
                    isExpanded: true,
                    items:
                        persons.map((Person person) {
                          return DropdownMenuItem<String>(
                            value: person.id,
                            // Use a more compact display for the name
                            child: Text('${person.name} (${person.personalNumber})', overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an owner';
                      }
                      return null;
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOwnerId = newValue;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _submitForm(dataProvider),
                    icon:
                        _isLoading
                            ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(strokeWidth: 3))
                            : Icon(widget.vehicle == null ? MdiIcons.plus : MdiIcons.contentSave),
                    label: Text(widget.vehicle == null ? 'Add Vehicle' : 'Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submitForm(DataProvider dataProvider) async {
    // Validate form
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Get selected owner's data
        final selectedOwner = dataProvider.persons.firstWhere((person) => person.id == _selectedOwnerId);

        // Create or update vehicle
        if (widget.vehicle == null) {
          // Create new vehicle
          final newVehicle = Vehicle(registrationNumber: _registrationController.text.toUpperCase(), type: _typeController.text, ownerId: _selectedOwnerId!, owner: selectedOwner);

          await dataProvider.createVehicle(newVehicle);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle added successfully')));
        } else {
          // Update existing vehicle
          final updatedVehicle = Vehicle(
            id: widget.vehicle!.id,
            registrationNumber: _registrationController.text.toUpperCase(),
            type: _typeController.text,
            ownerId: _selectedOwnerId!,
            owner: selectedOwner,
          );

          await dataProvider.updateVehicle(updatedVehicle);

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle updated successfully')));
        }

        // Navigate back
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        // Handle errors
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }
}
