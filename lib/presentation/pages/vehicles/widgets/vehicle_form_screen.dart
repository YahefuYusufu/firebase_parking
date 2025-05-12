import 'package:firebase_parking/config/theme/park_os_colors.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class VehicleFormScreen extends StatefulWidget {
  final VehicleEntity? vehicle; // Changed from Vehicle to VehicleEntity

  const VehicleFormScreen({super.key, this.vehicle});

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  late TextEditingController _registrationController;
  late String _selectedType; // Changed to handle VehicleType enum
  String? _ownerId;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing vehicle data if in edit mode
    _registrationController = TextEditingController(text: widget.vehicle?.registrationNumber ?? '');
    _selectedType = widget.vehicle?.type ?? VehicleType.car.name;

    // Get current user ID from auth state
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _ownerId = widget.vehicle?.ownerId ?? authState.user.id;
    }
  }

  @override
  void dispose() {
    _registrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(MdiIcons.arrowLeft), onPressed: () => Navigator.pop(context)),
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: BlocListener<VehicleBloc, VehicleState>(
        listener: (context, state) {
          if (state is VehicleOperationSuccess) {
            // Navigate back on success
            Navigator.pop(context);
          } else if (state is VehicleError) {
            // Show error
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: ParkOSColors.errorRed));
          }
        },
        child: Padding(
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

                // Vehicle Type dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Vehicle Type', prefixIcon: Icon(MdiIcons.car)),
                  value: _selectedType,
                  items:
                      VehicleType.values.map((type) {
                        return DropdownMenuItem<String>(value: type.name, child: Text(type.displayName));
                      }).toList(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a vehicle type';
                    }
                    return null;
                  },
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Owner information (read-only)
                if (_ownerId != null) ...[
                  TextFormField(decoration: InputDecoration(labelText: 'Owner', prefixIcon: Icon(MdiIcons.account)), initialValue: _getOwnerDisplay(), enabled: false),
                  const SizedBox(height: 24),
                ],

                // Submit Button
                BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (context, state) {
                    final isLoading = state is VehicleOperationInProgress || _isSubmitting;

                    return ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitForm,
                      icon:
                          isLoading
                              ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                              : Icon(widget.vehicle == null ? MdiIcons.plus : MdiIcons.contentSave),
                      label: Text(widget.vehicle == null ? 'Add Vehicle' : 'Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? ParkOSColors.terminalGreen : ParkOSColors.darkGreen,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _getOwnerDisplay() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.user.name ?? authState.user.email;
    }
    return 'Current User';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _ownerId != null) {
      setState(() => _isSubmitting = true);

      final vehicleBloc = context.read<VehicleBloc>();

      if (widget.vehicle == null) {
        // Create new vehicle
        final newVehicle = VehicleEntity(registrationNumber: _registrationController.text.toUpperCase(), type: _selectedType, ownerId: _ownerId!, ownerName: _getOwnerDisplay());

        vehicleBloc.add(AddVehicle(newVehicle));
      } else {
        // Update existing vehicle
        final updatedVehicle = widget.vehicle!.copyWith(registrationNumber: _registrationController.text.toUpperCase(), type: _selectedType);

        vehicleBloc.add(UpdateVehicle(updatedVehicle));
      }
    }
  }
}
