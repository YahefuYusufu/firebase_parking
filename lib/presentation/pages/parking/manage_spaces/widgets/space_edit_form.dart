import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_bloc.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_event.dart';
import 'package:firebase_parking/presentation/blocs/parking_space/parking_space_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SpaceEditForm extends StatefulWidget {
  final ParkingSpaceEntity space;

  const SpaceEditForm({super.key, required this.space});

  @override
  State<SpaceEditForm> createState() => _SpaceEditFormState();
}

class _SpaceEditFormState extends State<SpaceEditForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _spaceNumberController;
  late ParkingSpaceType _selectedType;
  late String _selectedSection;
  late String _selectedLevel;
  late TextEditingController _hourlyRateController;
  late ParkingSpaceStatus _selectedStatus;

  final List<ParkingSpaceType> _types = ParkingSpaceType.values;
  final List<String> _sections = ['A', 'B', 'C', 'D'];
  final List<String> _levels = ['G', '1', '2', '3'];
  final List<ParkingSpaceStatus> _statuses = [ParkingSpaceStatus.vacant, ParkingSpaceStatus.occupied, ParkingSpaceStatus.reserved, ParkingSpaceStatus.maintenance];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing space data
    _spaceNumberController = TextEditingController(text: widget.space.spaceNumber);
    _selectedType = widget.space.type;
    _selectedSection = widget.space.section;
    _selectedLevel = widget.space.level ?? 'G';
    _hourlyRateController = TextEditingController(text: widget.space.hourlyRate.toStringAsFixed(2));
    _selectedStatus = widget.space.status;
  }

  @override
  void dispose() {
    _spaceNumberController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Check if we're changing status from occupied to vacant
      final wasOccupied = widget.space.status == ParkingSpaceStatus.occupied;
      final nowVacant = _selectedStatus == ParkingSpaceStatus.vacant;

      // Create updated space entity
      final updatedSpace = ParkingSpaceEntity(
        id: widget.space.id,
        spaceNumber: _spaceNumberController.text,
        type: _selectedType,
        status: _selectedStatus,
        level: _selectedLevel == 'G' ? null : _selectedLevel,
        section: _selectedSection,
        hourlyRate: double.parse(_hourlyRateController.text),
        // If it was occupied but now vacant, remove the occupiedBy reference
        occupiedBy: (wasOccupied && nowVacant) ? null : widget.space.occupiedBy,
      );

      // Dispatch update event
      context.read<ParkingSpaceBloc>().add(UpdateParkingSpaceEvent(updatedSpace));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ParkingSpaceBloc, ParkingSpaceState>(
      listener: (context, state) {
        if (state is ParkingSpaceUpdated) {
          // Space updated successfully
          Navigator.of(context).pop(true);
        } else if (state is ParkingSpaceError) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Space ${widget.space.spaceNumber}'),
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        ),
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

              // Status
              DropdownButtonFormField<ParkingSpaceStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.info_outline)),
                items:
                    _statuses.map((status) {
                      return DropdownMenuItem<ParkingSpaceStatus>(value: status, child: Text(status.displayName));
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;

                      // If status is changing to vacant and was occupied,
                      // show a confirmation dialog
                      if (widget.space.status == ParkingSpaceStatus.occupied && value == ParkingSpaceStatus.vacant) {
                        _showVacateConfirmation();
                      }
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
                  final isLoading = state is ParkingSpaceUpdating;

                  return ElevatedButton.icon(
                    onPressed: isLoading ? null : _submitForm,
                    icon:
                        isLoading
                            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                            : const Icon(Icons.save),
                    label: Text(isLoading ? 'Saving...' : 'Save Changes'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                  );
                },
              ),

              // Show occupied by information if applicable
              if (widget.space.status == ParkingSpaceStatus.occupied && widget.space.occupiedBy != null) ...[
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),
                _buildOccupiedByInfo(widget.space.occupiedBy!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Build the occupied by information section
  Widget _buildOccupiedByInfo(VehicleEntity vehicle) {
    return ListTile(
      title: const Text('Currently Occupied By'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Registration: ${vehicle.registrationNumber}'), Text('Type: ${vehicle.type}'), if (vehicle.ownerName != null) Text('Owner: ${vehicle.ownerName}')],
      ),
      leading: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
        child: Text('🚙', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSecondaryContainer)),
      ),
      // Add action to directly vacate
      trailing: ElevatedButton(
        onPressed: () => _handleVacate(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        child: const Text('Vacate'),
      ),
    );
  }

  // Show confirmation when changing from occupied to vacant
  void _showVacateConfirmation() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Vacate Space'),
            content: Text(
              'Are you sure you want to vacate this space? '
              'This will remove the current vehicle (${widget.space.occupiedBy?.registrationNumber}).',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Revert back to occupied
                  setState(() {
                    _selectedStatus = ParkingSpaceStatus.occupied;
                  });
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Keep it as vacant
                  Navigator.of(dialogContext).pop();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('VACATE'),
              ),
            ],
          ),
    );
  }

  // Handle direct vacate button
  void _handleVacate() {
    if (widget.space.id != null) {
      // Use vacate specific event
      context.read<ParkingSpaceBloc>().add(VacateParkingSpaceEvent(widget.space.id!));

      // Update local state
      setState(() {
        _selectedStatus = ParkingSpaceStatus.vacant;
      });
    }
  }
}
