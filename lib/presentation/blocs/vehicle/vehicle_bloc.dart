// lib/presentation/blocs/vehicle/vehicle_bloc.dart
// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/vehicle_repository.dart';
import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository repository;
  StreamSubscription? _vehiclesSubscription;

  VehicleBloc({required this.repository}) : super(VehicleInitial()) {
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

    final result = await repository.getUserVehicles(event.userId);

    result.fold((failure) => emit(VehicleError(failure.message)), (vehicles) => emit(VehicleLoaded(vehicles: vehicles)));
  }

  Future<void> _onAddVehicle(AddVehicle event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentVehicles = (state as VehicleLoaded).vehicles;
      emit(VehicleOperationInProgress(vehicles: currentVehicles, operation: 'add'));

      final result = await repository.addVehicle(event.vehicle);

      result.fold((failure) => emit(VehicleError(failure.message)), (newVehicle) {
        final updatedVehicles = [...currentVehicles, newVehicle];
        emit(VehicleOperationSuccess(vehicles: updatedVehicles, message: 'Vehicle added successfully'));
        // Emit loaded state directly without delay
        emit(VehicleLoaded(vehicles: updatedVehicles));
      });
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicle event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentVehicles = (state as VehicleLoaded).vehicles;
      emit(VehicleOperationInProgress(vehicles: currentVehicles, operation: 'update'));

      final result = await repository.updateVehicle(event.vehicle);

      result.fold((failure) => emit(VehicleError(failure.message)), (updatedVehicle) {
        final updatedVehicles =
            currentVehicles.map((v) {
              return v.id == updatedVehicle.id ? updatedVehicle : v;
            }).toList();

        emit(VehicleOperationSuccess(vehicles: updatedVehicles, message: 'Vehicle updated successfully'));
        // Emit loaded state directly without delay
        emit(VehicleLoaded(vehicles: updatedVehicles));
      });
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicle event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentVehicles = (state as VehicleLoaded).vehicles;
      emit(VehicleOperationInProgress(vehicles: currentVehicles, operation: 'delete'));

      final result = await repository.deleteVehicle(event.vehicleId);

      result.fold((failure) => emit(VehicleError(failure.message)), (_) {
        final updatedVehicles = currentVehicles.where((v) => v.id != event.vehicleId).toList();
        emit(VehicleOperationSuccess(vehicles: updatedVehicles, message: 'Vehicle deleted successfully'));
        // Emit loaded state directly without delay
        emit(VehicleLoaded(vehicles: updatedVehicles));
      });
    }
  }

  Future<void> _onSearchVehicles(SearchVehiclesByRegistration event, Emitter<VehicleState> emit) async {
    if (state is VehicleLoaded) {
      final currentState = state as VehicleLoaded;

      final result = await repository.searchVehiclesByRegistration(event.query);

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
    emit(VehicleLoading());

    await _vehiclesSubscription?.cancel();
    _vehiclesSubscription = repository.watchUserVehicles(event.userId).listen((result) {
      result.fold((failure) => emit(VehicleError(failure.message)), (vehicles) => emit(VehicleLoaded(vehicles: vehicles)));
    });
  }

  @override
  Future<void> close() {
    _vehiclesSubscription?.cancel();
    return super.close();
  }
}
