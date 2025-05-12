import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

//Load all vehicles for a user
class LoadUserVehicles extends VehicleEvent {
  final String userId;

  const LoadUserVehicles(this.userId);

  @override
  List<Object?> get props => [userId];
}

//Add a new vehicle
class AddVehicle extends VehicleEvent {
  final VehicleEntity vehicle;

  const AddVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

// Update existing vehicle
class UpdateVehicle extends VehicleEvent {
  final VehicleEntity vehicle;

  const UpdateVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

// Delete a vehicle
class DeleteVehicle extends VehicleEvent {
  final String vehicleId;

  const DeleteVehicle(this.vehicleId);

  @override
  List<Object?> get props => [vehicleId];
}

// Search vehicles by registration
class SearchVehiclesByRegistration extends VehicleEvent {
  final String query;

  const SearchVehiclesByRegistration(this.query);

  @override
  List<Object?> get props => [query];
}

// Clear search results
class ClearSearch extends VehicleEvent {}

// Stream subscription for real-time updates
class WatchUserVehicles extends VehicleEvent {
  final String userId;

  const WatchUserVehicles(this.userId);

  @override
  List<Object?> get props => [userId];
}
