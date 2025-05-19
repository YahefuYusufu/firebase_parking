import 'package:firebase_parking/core/usecase/usecase.dart';
import 'package:firebase_parking/domain/usecases/parking_space/create_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/delete_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_all_parking_spaces.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_available_spaces_count.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_space_by_id.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_space_by_number.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_spaces_by_level.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_spaces_by_section.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_parking_spaces_by_status.dart';
import 'package:firebase_parking/domain/usecases/parking_space/get_space_by_vehicle_id.dart';
import 'package:firebase_parking/domain/usecases/parking_space/occupy_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/update_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/vacate_parking_space.dart';
import 'package:firebase_parking/domain/usecases/parking_space/watch_parking_spaces.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'parking_space_event.dart';
import 'parking_space_state.dart';

class ParkingSpaceBloc extends Bloc<ParkingSpaceEvent, ParkingSpaceState> {
  final GetAllParkingSpaces _getAllParkingSpaces;
  final GetParkingSpacesByStatus _getParkingSpacesByStatus;
  final GetParkingSpacesBySection _getParkingSpacesBySection;
  final GetParkingSpacesByLevel _getParkingSpacesByLevel;
  final GetParkingSpaceById _getParkingSpaceById;
  final GetParkingSpaceByNumber _getParkingSpaceByNumber;
  final CreateParkingSpace _createParkingSpace;
  final UpdateParkingSpace _updateParkingSpace;
  final DeleteParkingSpace _deleteParkingSpace;
  final OccupyParkingSpace _occupyParkingSpace;
  final VacateParkingSpace _vacateParkingSpace;
  final GetAvailableSpacesCount _getAvailableSpacesCount;
  final GetSpaceByVehicleId _getSpaceByVehicleId;
  final WatchParkingSpaces _watchParkingSpaces;

  ParkingSpaceBloc({
    required GetAllParkingSpaces getAllParkingSpaces,
    required GetParkingSpacesByStatus getParkingSpacesByStatus,
    required GetParkingSpacesBySection getParkingSpacesBySection,
    required GetParkingSpacesByLevel getParkingSpacesByLevel,
    required GetParkingSpaceById getParkingSpaceById,
    required GetParkingSpaceByNumber getParkingSpaceByNumber,
    required CreateParkingSpace createParkingSpace,
    required UpdateParkingSpace updateParkingSpace,
    required DeleteParkingSpace deleteParkingSpace,
    required OccupyParkingSpace occupyParkingSpace,
    required VacateParkingSpace vacateParkingSpace,
    required GetAvailableSpacesCount getAvailableSpacesCount,
    required GetSpaceByVehicleId getSpaceByVehicleId,
    required WatchParkingSpaces watchParkingSpaces,
  }) : _getAllParkingSpaces = getAllParkingSpaces,
       _getParkingSpacesByStatus = getParkingSpacesByStatus,
       _getParkingSpacesBySection = getParkingSpacesBySection,
       _getParkingSpacesByLevel = getParkingSpacesByLevel,
       _getParkingSpaceById = getParkingSpaceById,
       _getParkingSpaceByNumber = getParkingSpaceByNumber,
       _createParkingSpace = createParkingSpace,
       _updateParkingSpace = updateParkingSpace,
       _deleteParkingSpace = deleteParkingSpace,
       _occupyParkingSpace = occupyParkingSpace,
       _vacateParkingSpace = vacateParkingSpace,
       _getAvailableSpacesCount = getAvailableSpacesCount,
       _getSpaceByVehicleId = getSpaceByVehicleId,
       _watchParkingSpaces = watchParkingSpaces,
       super(const ParkingSpaceInitial()) {
    on<GetAllParkingSpacesEvent>(_onGetAllParkingSpaces);
    on<GetParkingSpacesByStatusEvent>(_onGetParkingSpacesByStatus);
    on<GetParkingSpacesBySectionEvent>(_onGetParkingSpacesBySection);
    on<GetParkingSpacesByLevelEvent>(_onGetParkingSpacesByLevel);
    on<GetParkingSpaceByIdEvent>(_onGetParkingSpaceById);
    on<GetParkingSpaceByNumberEvent>(_onGetParkingSpaceByNumber);
    on<CreateParkingSpaceEvent>(_onCreateParkingSpace);
    on<UpdateParkingSpaceEvent>(_onUpdateParkingSpace);
    on<DeleteParkingSpaceEvent>(_onDeleteParkingSpace);
    on<OccupyParkingSpaceEvent>(_onOccupyParkingSpace);
    on<VacateParkingSpaceEvent>(_onVacateParkingSpace);
    on<GetAvailableSpacesCountEvent>(_onGetAvailableSpacesCount);
    on<GetSpaceByVehicleIdEvent>(_onGetSpaceByVehicleId);
    on<WatchParkingSpacesEvent>(_onWatchParkingSpaces);
  }

  Future<void> _onGetAllParkingSpaces(GetAllParkingSpacesEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getAllParkingSpaces(const NoParams());

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (spaces) => emit(ParkingSpacesLoaded(spaces)));
  }

  Future<void> _onGetParkingSpacesByStatus(GetParkingSpacesByStatusEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getParkingSpacesByStatus(GetParkingSpacesByStatusParams(status: event.status));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (spaces) => emit(ParkingSpacesLoaded(spaces)));
  }

  Future<void> _onGetParkingSpacesBySection(GetParkingSpacesBySectionEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getParkingSpacesBySection(GetParkingSpacesBySectionParams(section: event.section));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (spaces) => emit(ParkingSpacesLoaded(spaces)));
  }

  Future<void> _onGetParkingSpacesByLevel(GetParkingSpacesByLevelEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getParkingSpacesByLevel(GetParkingSpacesByLevelParams(level: event.level));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (spaces) => emit(ParkingSpacesLoaded(spaces)));
  }

  Future<void> _onGetParkingSpaceById(GetParkingSpaceByIdEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getParkingSpaceById(GetParkingSpaceByIdParams(spaceId: event.spaceId));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceLoaded(space)));
  }

  Future<void> _onGetParkingSpaceByNumber(GetParkingSpaceByNumberEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getParkingSpaceByNumber(GetParkingSpaceByNumberParams(spaceNumber: event.spaceNumber));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceLoaded(space)));
  }

  Future<void> _onCreateParkingSpace(CreateParkingSpaceEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpaceCreating());

    final result = await _createParkingSpace(CreateParkingSpaceParams(space: event.space));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceCreated(space)));
  }

  Future<void> _onUpdateParkingSpace(UpdateParkingSpaceEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpaceUpdating());

    final result = await _updateParkingSpace(UpdateParkingSpaceParams(space: event.space));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceUpdated(space)));
  }

  Future<void> _onDeleteParkingSpace(DeleteParkingSpaceEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpaceDeleting());

    final result = await _deleteParkingSpace(DeleteParkingSpaceParams(spaceId: event.spaceId));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (_) => emit(const ParkingSpaceDeleted()));
  }

  Future<void> _onOccupyParkingSpace(OccupyParkingSpaceEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _occupyParkingSpace(OccupyParkingSpaceParams(spaceId: event.spaceId, vehicleId: event.vehicleId));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceOccupied(space)));
  }

  Future<void> _onVacateParkingSpace(VacateParkingSpaceEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _vacateParkingSpace(VacateParkingSpaceParams(spaceId: event.spaceId));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceVacated(space)));
  }

  Future<void> _onGetAvailableSpacesCount(GetAvailableSpacesCountEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getAvailableSpacesCount(const NoParams());

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (count) => emit(AvailableSpacesCountLoaded(count)));
  }

  Future<void> _onGetSpaceByVehicleId(GetSpaceByVehicleIdEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    final result = await _getSpaceByVehicleId(GetSpaceByVehicleIdParams(vehicleId: event.vehicleId));

    result.fold((failure) => emit(ParkingSpaceError(failure.message)), (space) => emit(ParkingSpaceByVehicleLoaded(space)));
  }

  Future<void> _onWatchParkingSpaces(WatchParkingSpacesEvent event, Emitter<ParkingSpaceState> emit) async {
    emit(const ParkingSpacesLoading());

    await emit.forEach(
      _watchParkingSpaces(const NoParams() as WatchParkingSpacesParams),
      onData: (result) {
        return result.fold((failure) => ParkingSpaceError(failure.message), (spaces) => ParkingSpacesLoaded(spaces));
      },
    );
  }
}
