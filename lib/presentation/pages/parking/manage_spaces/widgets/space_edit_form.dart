import 'package:firebase_parking/data/models/parking_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpaceEditForm extends StatefulWidget {
  final ParkingSpace space;
  final Function(ParkingSpace) onSpaceUpdated;

  const SpaceEditForm({super.key, required this.space, required this.onSpaceUpdated});

  @override
  State<SpaceEditForm> createState() => _SpaceEditFormState();
}

class _SpaceEditFormState extends State<SpaceEditForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _spaceNumberController;
  late String _selectedType;
  late String _selectedSection;
  late String _selectedLevel;
  late TextEditingController _hourlyRateController;
  late String _status;

  final List<String> _types = ['regular', 'compact', 'handicapped', 'electric'];
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _levels = ['G', '1', '2', '3'];
  final List<String> _statuses = ['vacant', 'occupied'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing space data
    _spaceNumberController = TextEditingController(text: widget.space.spaceNumber);
    _selectedType = widget.space.type;
    _selectedSection = widget.space.section;
    _selectedLevel = widget.space.level ?? 'G';
    _hourlyRateController = TextEditingController(text: widget.space.hourlyRate.toStringAsFixed(2));
    _status = widget.space.status;
  }

  @override
  void dispose() {
    _spaceNumberController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedSpace = ParkingSpace(
        id: widget.space.id,
        spaceNumber: _spaceNumberController.text,
        type: _selectedType,
        section: _selectedSection,
        level: _selectedLevel == 'G' ? null : _selectedLevel,
        hourlyRate: double.parse(_hourlyRateController.text),
        status: _status,
        occupiedBy: widget.space.occupiedBy, // Preserve the current vehicle if occupied
      );

      widget.onSpaceUpdated(updatedSpace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Text('◀️', style: TextStyle(fontSize: 22)), onPressed: () => Navigator.of(context).pop()),
        title: Text('Edit Space ${widget.space.spaceNumber}'),
      ),
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
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🔖', style: TextStyle(fontSize: 20))),
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
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('📍', style: TextStyle(fontSize: 20))),
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
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🔢', style: TextStyle(fontSize: 20))),
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
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🚗', style: TextStyle(fontSize: 20))),
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

            // Status
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Status',
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('ℹ️', style: TextStyle(fontSize: 20))),
              ),
              items:
                  _statuses.map((status) {
                    return DropdownMenuItem<String>(value: status, child: Text(status.substring(0, 1).toUpperCase() + status.substring(1)));
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            const SizedBox(height: 20),

            // Hourly Rate
            TextFormField(
              controller: _hourlyRateController,
              decoration: InputDecoration(
                labelText: 'Hourly Rate (\$)',
                prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('💲', style: TextStyle(fontSize: 20))),
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
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 24, alignment: Alignment.center, child: const Text('💾', style: TextStyle(fontSize: 18))),
                  const SizedBox(width: 8),
                  const Text('Save Changes'),
                ],
              ),
            ),

            if (widget.space.status.toLowerCase() == 'occupied') ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),

              // Show occupied by information if applicable
              ListTile(
                title: const Text('Currently Occupied By'),
                subtitle:
                    widget.space.occupiedBy != null
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Registration: ${widget.space.occupiedBy!.registrationNumber}'),
                            Text('Type: ${widget.space.occupiedBy!.type}'),
                            if (widget.space.occupiedBy!.owner != null) Text('Owner: ${widget.space.occupiedBy!.owner!.toString()}'),
                          ],
                        )
                        : const Text('Unknown vehicle'),
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
                  child: Text('🚙', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
