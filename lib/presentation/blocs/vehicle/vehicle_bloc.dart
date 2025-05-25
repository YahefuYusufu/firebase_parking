// lib/presentation/blocs/vehicle/vehicle_bloc.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/vehicle_repository.dart';
import '../../../domain/usecases/vehicles/add_vehicle.dart' as add_use_case;
import '../../../domain/usecases/vehicles/get_user_vehicles.dart';
import '../../../domain/usecases/vehicles/get_vehicle_by_id.dart';
import '../../../domain/usecases/vehicles/update_vehicle.dart' as update_use_case;
import '../../../domain/usecases/vehicles/delete_vehicle.dart' as delete_use_case;
import '../../../domain/usecases/vehicles/check_registration_exists.dart';
import '../../../domain/usecases/vehicles/search_vehicles_by_registration.dart' as search_use_case;
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final add_use_case.AddVehicle addVehicleUseCase;
  final GetUserVehicles getUserVehiclesUseCase;
  final GetVehicleById getVehicleByIdUseCase;
  final update_use_case.UpdateVehicle updateVehicleUseCase;
  final delete_use_case.DeleteVehicle deleteVehicleUseCase;
  final CheckRegistrationExists checkRegistrationExistsUseCase;
  final search_use_case.SearchVehiclesByRegistration searchVehiclesByRegistrationUseCase;

  final VehicleRepository repository; // Keep for watchUserVehicles
  StreamSubscription? _vehiclesSubscription;

  VehicleBloc({
    required this.addVehicleUseCase,
    required this.getUserVehiclesUseCase,
    required this.getVehicleByIdUseCase,
    required this.updateVehicleUseCase,
    required this.deleteVehicleUseCase,
    required this.checkRegistrationExistsUseCase,
    required this.searchVehiclesByRegistrationUseCase,
    required this.repository,
  }) : super(VehicleInitial()) {
    on<LoadUserVehicles>(_onLoadUserVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<SearchVehiclesByRegistration>(_onSearchVehicles);
    on<ClearSearch>(_onClearSearch);
    on<WatchUserVehicles>(_onWatchUserVehicles);
  }

  Future<void> _onLoadUserVehicles(LoadUserVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());

    final result = await getUserVehiclesUseCase(GetUserVehiclesParams(userId: event.userId));

    result.fold((failure) => emit(VehicleError(failure.message)), (vehicles) => emit(VehicleLoaded(vehicles: vehicles)));
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentVehicles = (state as VehicleLoaded).vehicles;
      emit(VehicleOperationInProgress(vehicles: currentVehicles, operation: 'add'));

      final result = await addVehicleUseCase(add_use_case.AddVehicleParams(vehicle: event.vehicle));

      result.fold((failure) => emit(VehicleError(failure.message)), (newVehicle) {
        final updatedVehicles = [...currentVehicles, newVehicle];
        emit(VehicleOperationSuccess(vehicles: updatedVehicles, message: 'Vehicle added successfully'));
        emit(VehicleLoaded(vehicles: updatedVehicles));
      });
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentVehicles = (state as VehicleLoaded).vehicles;
      emit(VehicleOperationInProgress(vehicles: currentVehicles, operation: 'update'));

      final result = await updateVehicleUseCase(update_use_case.UpdateVehicleParams(vehicle: event.vehicle));

      result.fold((failure) => emit(VehicleError(failure.message)), (updatedVehicle) {
        final updatedVehicles =
            currentVehicles.map((v) {
              return v.id == updatedVehicle.id ? updatedVehicle : v;
            }).toList();

        emit(VehicleOperationSuccess(vehicles: updatedVehicles, message: 'Vehicle updated successfully'));
        emit(VehicleLoaded(vehicles: updatedVehicles));
      });
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentVehicles = (state as VehicleLoaded).vehicles;
      emit(VehicleOperationInProgress(vehicles: currentVehicles, operation: 'delete'));

      final result = await deleteVehicleUseCase(delete_use_case.DeleteVehicleParams(vehicleId: event.vehicleId));

      result.fold((failure) => emit(VehicleError(failure.message)), (_) {
        final updatedVehicles = currentVehicles.where((v) => v.id != event.vehicleId).toList();
        emit(VehicleOperationSuccess(vehicles: updatedVehicles, message: 'Vehicle deleted successfully'));
        emit(VehicleLoaded(vehicles: updatedVehicles));
      });
    }
  }

  Future<void> _onSearchVehicles(SearchVehiclesByRegistration event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentState = state as VehicleLoaded;

      final result = await searchVehiclesByRegistrationUseCase(search_use_case.SearchVehiclesByRegistrationParams(query: event.query));

      result.fold((failure) => emit(VehicleError(failure.message)), (searchResults) => emit(currentState.copyWith(searchResults: searchResults)));
    }
  }

  void _onClearSearch(ClearSearch event, Emitter<VehicleState> emit) {
    if (state is VehicleLoaded) {
      final currentState = state as VehicleLoaded;
      emit(currentState.copyWith(searchResults: null));
    }
  }

  Future<void> _onWatchUserVehicles(WatchUserVehicles event, Emitter<VehicleState> emit) async {
    // Only emit loading if we don't already have vehicles loaded
    if (state is! VehicleLoaded) {
      emit(VehicleLoading());
    }

    // Cancel any existing subscription
    await _vehiclesSubscription?.cancel();

    // Set up the stream subscription
    _vehiclesSubscription = repository
        .watchUserVehicles(event.userId)
        .listen(
          (result) {
            result.fold(
              (failure) {
                if (!emit.isDone) {
                  emit(VehicleError(failure.message));
                }
              },
              (vehicles) {
                if (!emit.isDone) {
                  emit(VehicleLoaded(vehicles: vehicles));
                }
              },
            );
          },
          onError: (error) {
            print("VehicleBloc: Stream error: $error");
            if (!emit.isDone) {
              emit(VehicleError('Failed to watch vehicles: ${error.toString()}'));
            }
          },
        );
  }

  @override
  Future<void> close() {
    _vehiclesSubscription?.cancel();
    return super.close();
  }
}
