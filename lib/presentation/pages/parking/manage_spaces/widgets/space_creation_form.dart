import 'package:firebase_parking/data/models/parking_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpaceCreationForm extends StatefulWidget {
  final Function(ParkingSpace) onSpaceCreated;

  const SpaceCreationForm({super.key, required this.onSpaceCreated});

  @override
  State<SpaceCreationForm> createState() => _SpaceCreationFormState();
}

class _SpaceCreationFormState extends State<SpaceCreationForm> {
  final _formKey = GlobalKey<FormState>();

  final _spaceNumberController = TextEditingController();
  String _selectedType = 'regular';
  String _selectedSection = 'A';
  String _selectedLevel = '1';
  final _hourlyRateController = TextEditingController(text: '2.00');

  final List<String> _types = ['regular', 'compact', 'handicapped', 'electric'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _levels = ['G', '1', '2', '3'];

  @override
  void dispose() {
    _spaceNumberController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newSpace = ParkingSpace(
        spaceNumber: _spaceNumberController.text,
        type: _selectedType,
        section: _selectedSection,
        level: _selectedLevel,
        hourlyRate: double.parse(_hourlyRateController.text),
        status: 'vacant', // New spaces are vacant by default
      );

      widget.onSpaceCreated(newSpace);

      // Reset form or navigate back
      _spaceNumberController.clear();
      _hourlyRateController.text = '2.00';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Parking Space')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Space Number
            TextFormField(
              controller: _spaceNumberController,
              decoration: InputDecoration(
                labelText: 'Space Number',
                hintText: 'e.g. A101',
                prefixIcon: Icon(Icons.tag), // Using standard Icons instead
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a space number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Section
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: InputDecoration(
                labelText: 'Section',
                prefixIcon: Icon(Icons.place), // Using standard Icons instead
              ),
              items:
                  _sections.map((section) {
                    return DropdownMenuItem<String>(value: section, child: Text('Section $section'));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSection = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Level
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: InputDecoration(
                labelText: 'Level',
                prefixIcon: Icon(Icons.layers), // Using standard Icons instead
              ),
              items:
                  _levels.map((level) {
                    return DropdownMenuItem<String>(value: level, child: Text(level == 'G' ? 'Ground Floor' : 'Level $level'));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Type
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: 'Space Type',
                prefixIcon: Icon(Icons.directions_car), // Using standard Icons instead
              ),
              items:
                  _types.map((type) {
                    return DropdownMenuItem<String>(value: type, child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Hourly Rate
            TextFormField(
              controller: _hourlyRateController,
              decoration: InputDecoration(
                labelText: 'Hourly Rate (\$)',
                prefixIcon: Icon(Icons.attach_money), // Using standard Icons instead
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an hourly rate';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _submitForm,
              icon: const Icon(Icons.check_circle_outline), // Using standard Icons instead
              label: const Text('Create Space'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
