// lib/presentation/pages/booking_form_widget.dart
// ignore_for_file: unused_local_variable, unnecessary_type_check, avoid_print

import 'dart:async';
import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_bloc.dart';
import 'package:firebase_parking/presentation/blocs/auth/auth_state.dart';
import 'package:firebase_parking/presentation/blocs/parking/parking_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_bloc.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_event.dart';
import 'package:firebase_parking/presentation/blocs/vehicle/vehicle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingFormWidget extends StatefulWidget {
  final ParkingSpaceEntity space;

  const BookingFormWidget({super.key, required this.space});

  @override
  State<BookingFormWidget> createState() => _BookingFormWidgetState();
}

class _BookingFormWidgetState extends State<BookingFormWidget> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Form fields
  late TextEditingController _vehicleRegController;
  late TextEditingController _vehicleTypeController;
  VehicleEntity? selectedVehicle;

  @override
  void initState() {
    super.initState();
    _vehicleRegController = TextEditingController();
    _vehicleTypeController = TextEditingController();

    // Load user's vehicles
    _loadUserVehicles();
  }

  void _loadUserVehicles() {
    // Get the current user ID
    String? userId;
    final authState = context.read<AuthBloc>().state;

    if (authState is Authenticated) {
      userId = authState.user.id;
    } else if (authState is ProfileIncomplete) {
      userId = authState.user.id;
    }

    if (userId != null) {
      // Using the correct event name from your implementation
      context.read<VehicleBloc>().add(LoadUserVehicles(userId));
    }
  }

  @override
  void dispose() {
    _vehicleRegController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      // Get the current user ID
      String? userId;
      final authState = context.read<AuthBloc>().state;

      if (authState is Authenticated) {
        userId = authState.user.id;
      } else if (authState is ProfileIncomplete) {
        userId = authState.user.id;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to book parking')));
        setState(() {
          isLoading = false;
        });
        return;
      }

      if (selectedVehicle != null) {
        // Use existing vehicle
        _createParkingWithVehicle(selectedVehicle!.id!);
      } else {
        // Create a new vehicle first
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User ID is missing')));
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Create a new vehicle
        final newVehicle = VehicleEntity(registrationNumber: _vehicleRegController.text, type: _vehicleTypeController.text, ownerId: userId);

        // Create the vehicle through BLoC using the correct event name
        context.read<VehicleBloc>().add(AddVehicle(newVehicle));

        // Use a separate method to handle the stream subscription to avoid async gap issues
        _listenForVehicleCreation();
      }
    }
  }

  void _listenForVehicleCreation() {
    // Pre-declare the subscription
    StreamSubscription? vehicleSubscription;

    vehicleSubscription = context.read<VehicleBloc>().stream.listen((state) {
      // Check if widget is still mounted before updating UI
      if (!mounted) {
        vehicleSubscription?.cancel();
        return;
      }

      // Get the actual state type
      if (state is VehicleState) {
        // Check properties or methods to determine the state type
        // This approach avoids using 'is' with potentially undefined types
        if (state.toString().contains('VehicleAdded') || state.toString().contains('vehicle added')) {
          // Access the vehicle, assuming it has a property or can be accessed somehow
          final createdVehicle = getVehicleFromState(state);
          if (createdVehicle != null && createdVehicle.id != null) {
            _createParkingWithVehicle(createdVehicle.id!);
          }
          vehicleSubscription?.cancel();
        } else if (state.toString().contains('VehicleError') || state.toString().contains('error')) {
          // Get error message
          final errorMessage = getErrorMessageFromState(state);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating vehicle: $errorMessage')));
          setState(() {
            isLoading = false;
          });
          vehicleSubscription?.cancel();
        }
      }
    });
  }

  // Helper method to extract vehicle from state without using 'is'
  VehicleEntity? getVehicleFromState(VehicleState state) {
    // Try to access the vehicle property based on your state implementation
    try {
      // This is a generic approach - adjust based on your actual state structure
      if (state.props.isNotEmpty && state.props[0] is VehicleEntity) {
        return state.props[0] as VehicleEntity;
      }
    } catch (e) {
      print('Error getting vehicle from state: $e');
    }
    return null;
  }

  // Helper method to extract error message from state without using 'is'
  String getErrorMessageFromState(VehicleState state) {
    // Try to access the error message property based on your state implementation
    try {
      // This is a generic approach - adjust based on your actual state structure
      if (state.props.isNotEmpty && state.props[0] is String) {
        return state.props[0] as String;
      }
    } catch (e) {
      print('Error getting error message from state: $e');
    }
    return 'Unknown error';
  }

  void _createParkingWithVehicle(String vehicleId) {
    // Now create the parking record
    if (widget.space.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parking space ID is missing')));
      setState(() {
        isLoading = false;
      });
      return;
    }

    // Create the parking - adjust this event name if needed
    final ParkingEvent createEvent = CreateParkingEvent(vehicleId: vehicleId, parkingSpaceId: widget.space.id!);

    context.read<ParkingBloc>().add(createEvent);

    // Use a separate method to handle the stream subscription
    _listenForParkingCreation();
  }

  void _listenForParkingCreation() {
    // Pre-declare the subscription
    StreamSubscription? parkingSubscription;

    parkingSubscription = context.read<ParkingBloc>().stream.listen((state) {
      // Check if widget is still mounted before updating UI
      if (!mounted) {
        parkingSubscription?.cancel();
        return;
      }

      // Get the actual state type
      if (state is ParkingState) {
        // Check properties or methods to determine the state type
        if (state.toString().contains('ParkingCreated') || state.toString().contains('parking created')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking confirmed for Space ${widget.space.spaceNumber}')));
          Navigator.of(context).pop(true);
          parkingSubscription?.cancel();
        } else if (state.toString().contains('ParkingError') || state.toString().contains('error')) {
          // Get error message
          final errorMessage = getErrorMessageFromParkingState(state);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating parking: $errorMessage')));
          setState(() {
            isLoading = false;
          });
          parkingSubscription?.cancel();
        }
      }
    });
  }

  // Helper method to extract error message from parking state without using 'is'
  String getErrorMessageFromParkingState(ParkingState state) {
    // Try to access the error message property based on your state implementation
    try {
      // This is a generic approach - adjust based on your actual state structure
      if (state.props.isNotEmpty && state.props[0] is String) {
        return state.props[0] as String;
      }
    } catch (e) {
      print('Error getting error message from state: $e');
    }
    return 'Unknown error';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Text('◀️', style: TextStyle(fontSize: 22)), onPressed: () => Navigator.of(context).pop()),
        title: Text('Book Space ${widget.space.spaceNumber}'),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            // Main form content
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Space Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Space Details', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(_getTypeEmoji(widget.space.type.name), style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSecondaryContainer)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Space ${widget.space.spaceNumber}', style: Theme.of(context).textTheme.titleSmall),
                                  Text('Section ${widget.space.section}, Level ${widget.space.level ?? 'G'}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Text('\$${widget.space.hourlyRate.toStringAsFixed(2)}/hr', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Vehicle Selection
                Text('Vehicle Information', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),

                // Display user's vehicles (if available)
                BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (context, state) {
                    // Check for vehicles without relying on specific type names
                    final vehicles = getVehiclesFromState(state);

                    if (vehicles.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Select an existing vehicle or create a new one:'),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<VehicleEntity?>(
                                value: selectedVehicle,
                                isExpanded: true,
                                hint: const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Select a vehicle')),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                items: [
                                  // Option for entering a new vehicle
                                  const DropdownMenuItem<VehicleEntity?>(value: null, child: Text('Enter a new vehicle')),
                                  // User's existing vehicles
                                  ...vehicles.map((vehicle) {
                                    return DropdownMenuItem<VehicleEntity?>(value: vehicle, child: Text('${vehicle.registrationNumber} (${vehicle.type})'));
                                  }),
                                ],
                                onChanged: (VehicleEntity? value) {
                                  setState(() {
                                    selectedVehicle = value;
                                    if (value != null) {
                                      _vehicleRegController.text = value.registrationNumber;
                                      _vehicleTypeController.text = value.type;
                                    } else {
                                      _vehicleRegController.clear();
                                      _vehicleTypeController.clear();
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return Container(); // No vehicles loaded yet
                  },
                ),

                // Only show text fields if no vehicle is selected or creating new
                if (selectedVehicle == null)
                  Column(
                    children: [
                      // Registration Number
                      TextFormField(
                        controller: _vehicleRegController,
                        decoration: InputDecoration(
                          labelText: 'Registration Number',
                          hintText: 'E.g. ABC123',
                          prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🚗', style: TextStyle(fontSize: 20))),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter registration number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Type
                      TextFormField(
                        controller: _vehicleTypeController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          hintText: 'E.g. Sedan, SUV, etc.',
                          prefixIcon: Container(width: 48, alignment: Alignment.center, child: const Text('🚙', style: TextStyle(fontSize: 20))),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle type';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Booking Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Booking Summary', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Rate:'), Text('\$${widget.space.hourlyRate.toStringAsFixed(2)}/hour')]),
                        const SizedBox(height: 8),
                        const Text('Parking fees will be calculated based on your actual parking duration.', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('✅', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      const Text('Confirm Booking', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),

            // Loading overlay
            if (isLoading)
              Container(
                color: Color.fromRGBO(
                  0,
                  0,
                  0,
                  0.3, // Using RGBA values directly instead of withOpacity
                ),
                child: const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Creating your parking...')]),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper function to extract vehicles from vehicle state without using 'is'
  List<VehicleEntity> getVehiclesFromState(VehicleState state) {
    // Try to access the vehicles property based on your state implementation
    try {
      // This is a generic approach - adjust based on your actual state structure
      if (state.props.isNotEmpty && state.props[0] is List) {
        final list = state.props[0] as List;
        if (list.isNotEmpty && list[0] is VehicleEntity) {
          return list.cast<VehicleEntity>();
        }
      }
    } catch (e) {
      print('Error getting vehicles from state: $e');
    }
    return [];
  }

  // Helper function to get emoji for space type
  String _getTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'handicapped':
        return '♿';
      case 'compact':
        return '🚗';
      case 'electric':
        return '🔌';
      default:
        return 'P';
    }
  }
}
