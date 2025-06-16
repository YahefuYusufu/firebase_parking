// lib/data/models/parking/parking_model.dart
import 'package:firebase_parking/data/models/parking_space/parking_space_model.dart';
import 'package:firebase_parking/data/models/vehicles/vehicle_model.dart';
import 'package:firebase_parking/domain/entities/parking_entity.dart';

class ParkingModel {
  final String? id;
  final VehicleModel vehicle;
  final ParkingSpaceModel parkingSpace;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Duration originalTimeLimit; // NEW: Original time limit
  final List<ParkingExtensionModel> extensions; // NEW: Extensions

  ParkingModel({this.id, required this.vehicle, required this.parkingSpace, required this.startedAt, this.finishedAt, required this.originalTimeLimit, this.extensions = const []});

  // Calculate total time limit including extensions
  Duration get totalTimeLimit {
    Duration total = originalTimeLimit;
    for (final extension in extensions) {
      total += extension.additionalTime;
    }
    return total;
  }

  // Calculate the expected end time
  DateTime get expectedEndTime => startedAt.add(totalTimeLimit);

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
    // Base fee for original time
    final originalHours = originalTimeLimit.inMinutes / 60.0;
    final baseFee = originalHours * parkingSpace.hourlyRate;

    // Add extension costs
    final extensionCost = extensions.fold(0.0, (sum, ext) => sum + ext.cost);

    return baseFee + extensionCost;
  }

  // Check if the parking session is active
  bool get isActive => finishedAt == null;

  // Check if parking has expired
  bool get hasExpired => DateTime.now().isAfter(expectedEndTime);

  // Convert to domain entity
  ParkingEntity toEntity() {
    return ParkingEntity(
      id: id,
      vehicleId: vehicle.id,
      parkingSpaceId: parkingSpace.id,
      startedAt: startedAt,
      finishedAt: finishedAt,
      originalTimeLimit: originalTimeLimit,
      extensions: extensions.map((e) => e.toEntity()).toList(),
      vehicleRegistration: vehicle.registrationNumber,
      parkingSpaceNumber: parkingSpace.spaceNumber,
      hourlyRate: parkingSpace.hourlyRate,
    );
  }

  // Create from domain entity
  factory ParkingModel.fromEntity(ParkingEntity entity, VehicleModel vehicle, ParkingSpaceModel parkingSpace) {
    return ParkingModel(
      id: entity.id,
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      startedAt: entity.startedAt,
      finishedAt: entity.finishedAt,
      originalTimeLimit: entity.originalTimeLimit,
      extensions: entity.extensions.map((e) => ParkingExtensionModel.fromEntity(e)).toList(),
    );
  }

  // Add extension
  ParkingModel extend({required Duration additionalTime, required double cost, String? reason}) {
    final extension = ParkingExtensionModel(additionalTime: additionalTime, cost: cost, extendedAt: DateTime.now(), reason: reason);

    return copyWith(extensions: [...extensions, extension]);
  }

  // Serialization - Convert Parking to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle': vehicle.toJson(),
      'parking_space': parkingSpace.toJson(),
      'started_at': startedAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'original_time_limit': originalTimeLimit.inMilliseconds,
      'extensions': extensions.map((e) => e.toJson()).toList(),
    };
  }

  // For database operations (Firestore document)
  Map<String, dynamic> toFirestore() {
    return {
      'vehicle_id': vehicle.id,
      'parking_space_id': parkingSpace.id,
      'started_at': startedAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'original_time_limit': originalTimeLimit.inMilliseconds,
      'extensions': extensions.map((e) => e.toJson()).toList(),
    };
  }

  // Deserialization - Create Parking from JSON Map
  factory ParkingModel.fromJson(Map<String, dynamic> json) {
    return ParkingModel(
      id: json['id'],
      vehicle: VehicleModel.fromJson(json['vehicle']),
      parkingSpace: ParkingSpaceModel.fromJson(json['parking_space']),
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
      originalTimeLimit: Duration(milliseconds: json['original_time_limit'] ?? 7200000), // Default 2 hours
      extensions: (json['extensions'] as List<dynamic>?)?.map((e) => ParkingExtensionModel.fromJson(e)).toList() ?? [],
    );
  }

  // Create from Firestore document
  factory ParkingModel.fromFirestore(Map<String, dynamic> json, String documentId, VehicleModel vehicle, ParkingSpaceModel parkingSpace) {
    return ParkingModel(
      id: documentId,
      vehicle: vehicle,
      parkingSpace: parkingSpace,
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
      originalTimeLimit: Duration(milliseconds: json['original_time_limit'] ?? 7200000), // Default 2 hours
      extensions: (json['extensions'] as List<dynamic>?)?.map((e) => ParkingExtensionModel.fromJson(e)).toList() ?? [],
    );
  }

  // Copy with method
  ParkingModel copyWith({
    String? id,
    VehicleModel? vehicle,
    ParkingSpaceModel? parkingSpace,
    DateTime? startedAt,
    DateTime? finishedAt,
    Duration? originalTimeLimit,
    List<ParkingExtensionModel>? extensions,
  }) {
    return ParkingModel(
      id: id ?? this.id,
      vehicle: vehicle ?? this.vehicle,
      parkingSpace: parkingSpace ?? this.parkingSpace,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      originalTimeLimit: originalTimeLimit ?? this.originalTimeLimit,
      extensions: extensions ?? this.extensions,
    );
  }

  @override
  String toString() {
    final status = isActive ? 'Active' : 'Completed';
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';
    final totalTimeStr = '${totalTimeLimit.inHours}h ${totalTimeLimit.inMinutes % 60}m';

    return 'ParkingModel(id: $id, status: $status, vehicle: ${vehicle.registrationNumber}, '
        'space: ${parkingSpace.spaceNumber}, duration: $durationStr, totalLimit: $totalTimeStr, '
        'extensions: ${extensions.length})';
  }
}

// Model for parking extensions
class ParkingExtensionModel {
  final Duration additionalTime;
  final double cost;
  final DateTime extendedAt;
  final String? reason;

  const ParkingExtensionModel({required this.additionalTime, required this.cost, required this.extendedAt, this.reason});

  // Convert to domain entity
  ParkingExtension toEntity() {
    return ParkingExtension(additionalTime: additionalTime, cost: cost, extendedAt: extendedAt, reason: reason);
  }

  // Create from domain entity
  factory ParkingExtensionModel.fromEntity(ParkingExtension entity) {
    return ParkingExtensionModel(additionalTime: entity.additionalTime, cost: entity.cost, extendedAt: entity.extendedAt, reason: entity.reason);
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {'additional_time': additionalTime.inMilliseconds, 'cost': cost, 'extended_at': extendedAt.toIso8601String(), 'reason': reason};
  }

  factory ParkingExtensionModel.fromJson(Map<String, dynamic> json) {
    return ParkingExtensionModel(
      additionalTime: Duration(milliseconds: json['additional_time']),
      cost: (json['cost'] as num).toDouble(),
      extendedAt: DateTime.parse(json['extended_at']),
      reason: json['reason'],
    );
  }
}
