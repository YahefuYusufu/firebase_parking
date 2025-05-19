import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_event.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpaceCreationForm extends StatefulWidget {
  const SpaceCreationForm({super.key});

  @override
  State<SpaceCreationForm> createState() => _SpaceCreationFormState();
}

class _SpaceCreationFormState extends State<SpaceCreationForm> {
  final _formKey = GlobalKey<FormState>();

  final _spaceNumberController = TextEditingController();
  ParkingSpaceType _selectedType = ParkingSpaceType.regular;
  String _selectedSection = 'A';
  String _selectedLevel = '1';
  final _hourlyRateController = TextEditingController(text: '2.00');

  final List<ParkingSpaceType> _types = ParkingSpaceType.values;
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
      final newSpace = ParkingSpaceEntity(
        spaceNumber: _spaceNumberController.text,
        type: _selectedType,
        section: _selectedSection,
        level: _selectedLevel == 'G' ? null : _selectedLevel,
        hourlyRate: double.parse(_hourlyRateController.text),
        status: ParkingSpaceStatus.vacant, // New spaces are vacant by default
      );

      // Dispatch event to create space
      context.read<ParkingSpaceBloc>().add(CreateParkingSpaceEvent(newSpace));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParkingSpaceBloc, ParkingSpaceState>(
      listener: (context, state) {
        if (state is ParkingSpaceCreated) {
          // Space created successfully, navigate back
          Navigator.of(context).pop(true);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Parking Space')),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Space Number
              TextFormField(
                controller: _spaceNumberController,
                decoration: const InputDecoration(labelText: 'Space Number', hintText: 'e.g. A101', prefixIcon: Icon(Icons.tag)),
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
                decoration: const InputDecoration(labelText: 'Section', prefixIcon: Icon(Icons.place)),
                items:
                    _sections.map((section) {
                      return DropdownMenuItem<String>(value: section, child: Text('Section $section'));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedSection = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Level
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(labelText: 'Level', prefixIcon: Icon(Icons.layers)),
                items:
                    _levels.map((level) {
                      return DropdownMenuItem<String>(value: level, child: Text(level == 'G' ? 'Ground Floor' : 'Level $level'));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Type
              DropdownButtonFormField<ParkingSpaceType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Space Type', prefixIcon: Icon(Icons.directions_car)),
                items:
                    _types.map((type) {
                      return DropdownMenuItem<ParkingSpaceType>(value: type, child: Text(type.displayName));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Hourly Rate
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(labelText: 'Hourly Rate (\$)', prefixIcon: Icon(Icons.attach_money)),
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

              // Submit Button with loading state
              BlocBuilder<ParkingSpaceBloc, ParkingSpaceState>(
                builder: (context, state) {
                  final isLoading = state is ParkingSpaceCreating;

                  return ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitForm,
                    icon:
                        isLoading
                            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                            : const Icon(Icons.check_circle_outline),
                    label: Text(isLoading ? 'Creating...' : 'Create Space'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
