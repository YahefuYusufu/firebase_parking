import 'package:equatable/equatable.dart';
import '../../../domain/entities/vehicle_entity.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

// Initial state
class VehicleInitial extends VehicleState {}

// Loading state
class VehicleLoading extends VehicleState {}

// Loaded state with list of vehicles
class VehicleLoaded extends VehicleState {
  final List<VehicleEntity> vehicles;
  final List<VehicleEntity>? searchResults;

  const VehicleLoaded({required this.vehicles, this.searchResults});

  @override
  List<Object?> get props => [vehicles, searchResults];

  // Check if a vehicle is currently parked (you can implement this logic)
  bool isVehicleParked(String vehicleId) {
    // This would need to check against parking data
    // For now, return false as placeholder
    return false;
  }

  VehicleLoaded copyWith({List<VehicleEntity>? vehicles, List<VehicleEntity>? searchResults}) {
    return VehicleLoaded(vehicles: vehicles ?? this.vehicles, searchResults: searchResults);
  }
}

// Error state
class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}

// Operation in progress state (for add/update/delete)
class VehicleOperationInProgress extends VehicleState {
  final List<VehicleEntity> vehicles;
  final String operation; // 'add', 'update', or 'delete'

  const VehicleOperationInProgress({required this.vehicles, required this.operation});

  @override
  List<Object?> get props => [vehicles, operation];
}

// Operation success state
class VehicleOperationSuccess extends VehicleState {
  final List<VehicleEntity> vehicles;
  final String message;

  const VehicleOperationSuccess({required this.vehicles, required this.message});

  @override
  List<Object?> get props => [vehicles, message];
}
