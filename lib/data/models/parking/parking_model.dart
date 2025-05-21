// lib/data/models/parking/parking_model.dart
import 'package:firebase_parking/data/models/parking_space/parking_space.dart';
import 'package:firebase_parking/data/models/vehicles/vehicle.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';

class ParkingModel {
  final String? id;
  final Vehicle vehicle;
  final ParkingSpace parkingSpace;
  final DateTime startedAt;
  final DateTime? finishedAt;

  ParkingModel({this.id, required this.vehicle, required this.parkingSpace, required this.startedAt, this.finishedAt});

  // Calculate the duration of the parking session
  Duration get duration {
    if (finishedAt != null) {
      return finishedAt!.difference(startedAt);
    } else {
      // For ongoing sessions, calculate duration until now
      return DateTime.now().difference(startedAt);
    }
  }

  // Calculate the parking fee based on duration and hourly rate
  double calculateFee() {
    // Convert to hours and multiply by hourly rate
    final hours = duration.inMinutes / 60.0;
    return hours * parkingSpace.hourlyRate;
  }

  // Check if the parking session is active
  bool get isActive => finishedAt == null;

  // Convert to domain entity
  ParkingEntity toEntity() {
    return ParkingEntity(
      id: id,
      vehicleId: vehicle.id,
      parkingSpaceId: parkingSpace.id,
      startedAt: startedAt,
      finishedAt: finishedAt,
      vehicleRegistration: vehicle.registrationNumber,
      parkingSpaceNumber: parkingSpace.spaceNumber,
      hourlyRate: parkingSpace.hourlyRate,
    );
  }

  // Create from domain entity (simplified version, actual implementation may need more data)
  factory ParkingModel.fromEntity(ParkingEntity entity, Vehicle vehicle, ParkingSpace parkingSpace) {
    return ParkingModel(id: entity.id, vehicle: vehicle, parkingSpace: parkingSpace, startedAt: entity.startedAt, finishedAt: entity.finishedAt);
  }

  // Serialization - Convert Parking to JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'vehicle': vehicle.toJson(), 'parking_space': parkingSpace.toJson(), 'started_at': startedAt.toIso8601String(), 'finished_at': finishedAt?.toIso8601String()};
  }

  // For database operations (Firestore document)
  Map<String, dynamic> toFirestore() {
    return {
      'vehicle_id': vehicle.id,
      'parking_space_id': parkingSpace.id,
      'started_at': startedAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      // Don't include 'id' as Firestore generates it
      // Don't include full vehicle or parking space objects
    };
  }

  // Deserialization - Create Parking from JSON Map
  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: json['id'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parking_space']),
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
    );
  }

  // Create from Firestore document (simplified, actual implementation would need to fetch vehicle and parking space separately)
  factory ParkingModel.fromFirestore(Map<String, dynamic> json, String documentId, Vehicle vehicle, ParkingSpace parkingSpace) {
    return ParkingModel(
      id: documentId,
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
    );
  }

  // Copy with method
  ParkingModel copyWith({String? id, Vehicle? vehicle, ParkingSpace? parkingSpace, DateTime? startedAt, DateTime? finishedAt}) {
    return ParkingModel(
      id: id ?? this.id,
      vehicle: vehicle ?? this.vehicle,
      parkingSpace: parkingSpace ?? this.parkingSpace,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  @override
  String toString() {
    final status = isActive ? 'Active' : 'Completed';
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return 'ParkingModel(id: $id, status: $status, vehicle: ${vehicle.registrationNumber}, '
        'space: ${parkingSpace.spaceNumber}, duration: $durationStr)';
  }
}
