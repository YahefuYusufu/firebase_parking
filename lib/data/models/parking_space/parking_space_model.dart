// lib/data/models/parking_space_model.dart
import 'package:firebase_parking/domain/entities/parking_space_entity.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';

import '../vehicles/vehicle.dart';

class ParkingSpaceModel {
  final String? id;
  final String spaceNumber;
  final String type;
  final String status;
  final String? level;
  final String section;
  final double hourlyRate;
  final Vehicle? occupiedBy;

  ParkingSpaceModel({this.id, required this.spaceNumber, required this.type, this.status = 'vacant', this.level, required this.section, required this.hourlyRate, this.occupiedBy});

  // Convert to domain entity
  ParkingSpaceEntity toEntity() {
    VehicleEntity? vehicleEntity;
    if (occupiedBy != null) {
      // Manual conversion from Vehicle to VehicleEntity
      vehicleEntity = VehicleEntity(
        id: occupiedBy!.id,
        registrationNumber: occupiedBy!.registrationNumber,
        type: occupiedBy!.type,
        ownerId: occupiedBy!.ownerId,
        ownerName: occupiedBy!.owner?.name,
      );
    }

    return ParkingSpaceEntity(
      id: id,
      spaceNumber: spaceNumber,
      type: ParkingSpaceType.fromString(type),
      status: ParkingSpaceStatus.fromString(status),
      level: level,
      section: section,
      hourlyRate: hourlyRate,
      occupiedBy: vehicleEntity,
    );
  }

  // Create from domain entity
  factory ParkingSpaceModel.fromEntity(ParkingSpaceEntity entity) {
    Vehicle? vehicleModel;
    if (entity.occupiedBy != null) {
      // Convert VehicleEntity to Vehicle
      vehicleModel = Vehicle(
        id: entity.occupiedBy!.id,
        registrationNumber: entity.occupiedBy!.registrationNumber,
        type: entity.occupiedBy!.type,
        ownerId: entity.occupiedBy!.ownerId,
        // Note: We don't have owner data from entity, so we leave it null
      );
    }

    return ParkingSpaceModel(
      id: entity.id,
      spaceNumber: entity.spaceNumber,
      type: entity.type.name,
      status: entity.status.name,
      level: entity.level,
      section: entity.section,
      hourlyRate: entity.hourlyRate,
      occupiedBy: vehicleModel,
    );
  }

  // Serialization - Convert ParkingSpace to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'space_number': spaceNumber,
      'type': type,
      'status': status,
      'level': level,
      'section': section,
      'hourly_rate': hourlyRate,
      'occupied_by': occupiedBy?.toJson(),
    };
  }

  // For database operations (Firestore document)
  Map<String, dynamic> toFirestore() {
    return {
      'space_number': spaceNumber,
      'type': type,
      'status': status,
      'level': level,
      'section': section,
      'hourly_rate': hourlyRate,
      'vehicle_id': occupiedBy?.id,
      // Don't include 'id' as Firestore generates it
      // Don't include full vehicle object
    };
  }

  // Deserialization - Create ParkingSpace from JSON Map
  factory ParkingSpaceModel.fromJson(Map<String, dynamic> json) {
    return ParkingSpaceModel(
      id: json['id'],
      spaceNumber: json['space_number'] ?? '',
      type: json['type'] ?? 'regular',
      status: json['status'] ?? 'vacant',
      level: json['level'],
      section: json['section'] ?? '',
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      occupiedBy: json['occupied_by'] != null ? Vehicle.fromJson(json['occupied_by']) : null,
    );
  }

  // Create from Firestore document
  factory ParkingSpaceModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return ParkingSpaceModel(
      id: documentId,
      spaceNumber: json['space_number'] ?? '',
      type: json['type'] ?? 'regular',
      status: json['status'] ?? 'vacant',
      level: json['level'],
      section: json['section'] ?? '',
      hourlyRate: (json['hourly_rate'] ?? 0).toDouble(),
      // Vehicle data might be populated separately
    );
  }

  // Copy with method
  ParkingSpaceModel copyWith({String? id, String? spaceNumber, String? type, String? status, String? level, String? section, double? hourlyRate, Vehicle? occupiedBy}) {
    return ParkingSpaceModel(
      id: id ?? this.id,
      spaceNumber: spaceNumber ?? this.spaceNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      level: level ?? this.level,
      section: section ?? this.section,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      occupiedBy: occupiedBy ?? this.occupiedBy,
    );
  }

  @override
  String toString() {
    return 'ParkingSpaceModel(id: $id, spaceNumber: $spaceNumber, type: $type, status: $status, level: $level, section: $section, hourlyRate: $hourlyRate, occupiedBy: $occupiedBy)';
  }
}
