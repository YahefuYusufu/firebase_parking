import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';
import 'package:firebase_parking/domain/usecases/parking/create_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/end_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/get_active_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/get_parking_usecase.dart';
import 'package:firebase_parking/domain/usecases/parking/get_user_parking_usecase.dart';
import 'package:firebase_parking/domain/repositories/parking_repository.dart'; // For extension
import 'package:firebase_parking/presentation/blocs/notification/notification_bloc.dart';
import 'package:firebase_parking/presentation/blocs/notification/notification_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'parking_event.dart';
part 'parking_state.dart';

class ParkingBloc extends Bloc<ParkingEvent, ParkingState> {
  final CreateParkingUseCase createParking;
  final GetParkingUseCase getParking;
  final GetActiveParkingUseCase getActiveParking;
  final GetUserParkingUseCase getUserParking;
  final EndParkingUseCase endParking;
  final ParkingRepository parkingRepository; // NEW: For extensions
  final NotificationBloc notificationBloc;

  ParkingBloc({
    required this.createParking,
    required this.getParking,
    required this.getActiveParking,
    required this.getUserParking,
    required this.endParking,
    required this.parkingRepository, // NEW
    required this.notificationBloc,
  }) : super(ParkingInitial()) {
    on<CreateParkingEvent>(_onCreateParking);
    on<CreateParkingWithDurationEvent>(_onCreateParkingWithDuration); // NEW
    on<ExtendParkingEvent>(_onExtendParking); // NEW
    on<GetParkingEvent>(_onGetParking);
    on<GetActiveParkingEvent>(_onGetActiveParking);
    on<GetUserParkingEvent>(_onGetUserParking);
    on<EndParkingEvent>(_onEndParking);
  }

  // Legacy create parking method
  Future<void> _onCreateParking(CreateParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      // Use default 2-hour duration for backward compatibility
      final parking = await createParking.call(
        vehicleId: event.vehicleId,
        parkingSpaceId: event.parkingSpaceId,
        timeLimit: const Duration(hours: 2), // Default duration
      );

      emit(ParkingCreated(parking));
      await _handleParkingCreatedNotifications(parking);
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  // NEW: Create parking with specific duration
  Future<void> _onCreateParkingWithDuration(CreateParkingWithDurationEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      final parking = await createParking.call(
        vehicleId: event.vehicleId,
        parkingSpaceId: event.parkingSpaceId,
        timeLimit: event.duration,
        vehicleRegistration: event.vehicleRegistration,
        parkingSpaceNumber: event.parkingSpaceNumber,
        hourlyRate: event.hourlyRate,
      );

      emit(ParkingCreated(parking));
      await _handleParkingCreatedNotifications(parking);
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  // NEW: Extend parking
  Future<void> _onExtendParking(ExtendParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      // Extend the parking using repository
      final extendedParking = await parkingRepository.extendParking(event.parkingId, event.additionalTime, event.cost, reason: event.reason);

      emit(ParkingExtended(extendedParking));

      // Handle extension notifications
      if (extendedParking.id != null && extendedParking.vehicleRegistration != null) {
        print("🔄 Handling parking extension notifications");

        notificationBloc.add(
          HandleParkingExtension(
            parkingId: extendedParking.id!,
            vehicleRegistration: extendedParking.vehicleRegistration!,
            additionalTime: event.additionalTime,
            newExpiryTime: extendedParking.expectedEndTime,
            parkingSpaceNumber: extendedParking.parkingSpaceNumber,
          ),
        );
      }
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onGetParking(GetParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      final parking = await getParking(event.parkingId);

      if (parking != null) {
        emit(ParkingLoaded(parking));
      } else {
        emit(const ParkingError('Parking not found'));
      }
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onGetActiveParking(GetActiveParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      final parkingList = await getActiveParking();
      emit(ParkingListLoaded(parkingList));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onGetUserParking(GetUserParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      final parkingList = await getUserParking(event.userId);
      emit(ParkingListLoaded(parkingList));
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  Future<void> _onEndParking(EndParkingEvent event, Emitter<ParkingState> emit) async {
    emit(ParkingLoading());

    try {
      final updatedParking = await endParking(event.parkingId);
      emit(ParkingEnded(updatedParking));

      // Cancel all scheduled reminders for this parking session
      print("🗑️ Cancelling parking notifications for ${event.parkingId}");
      notificationBloc.add(CancelParkingNotifications(event.parkingId));

      // Show "parking ended" notification
      if (updatedParking.vehicleRegistration != null) {
        notificationBloc.add(ShowParkingEndedNotification(parking: updatedParking));
      }
    } catch (e) {
      emit(ParkingError(e.toString()));
    }
  }

  // Helper method to handle notifications when parking is created
  Future<void> _handleParkingCreatedNotifications(ParkingEntity parking) async {
    if (parking.id != null && parking.vehicleRegistration != null) {
      print("🔔 Setting up notifications for ${parking.vehicleRegistration}");
      print("⏰ Time limit: ${parking.formattedTotalTimeLimit}");

      // Show immediate "parking started" notification
      notificationBloc.add(ShowParkingStartedNotification(parking: parking));

      // Schedule reminder notifications based on actual time limit
      // For testing, you can switch between these:

      // Production mode (real reminders based on time limit):
      notificationBloc.add(ScheduleEntityBasedReminders(parking: parking));

      // Test mode (quick reminders for testing):
      // notificationBloc.add(ScheduleTestReminders(
      //   parkingId: parking.id!,
      //   vehicleRegistration: parking.vehicleRegistration!,
      //   parkingStartTime: parking.startedAt,
      // ));
    }
  }
}
