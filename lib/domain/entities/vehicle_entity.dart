// lib/domain/entities/vehicle_entity.dart

import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String? id;
  final String registrationNumber;
  final String type;
  final String ownerId;
  final String? ownerName; // Simplified from Person object for entity

  const VehicleEntity({this.id, required this.registrationNumber, required this.type, required this.ownerId, this.ownerName});

  @override
  List<Object?> get props => [id, registrationNumber, type, ownerId, ownerName];

  // Convenience methods
  bool get isNew => id == null;

  // For display purposes
  String get displayName => registrationNumber.toUpperCase();

  // Copy with method for updating
  VehicleEntity copyWith({String? id, String? registrationNumber, String? type, String? ownerId, String? ownerName}) {
    return VehicleEntity(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  @override
  String toString() {
    return 'VehicleEntity(id: $id, registrationNumber: $registrationNumber, type: $type, ownerId: $ownerId, ownerName: $ownerName)';
  }
}

// Enum for vehicle types to ensure consistency
enum VehicleType {
  car('Car'),
  motorcycle('Motorcycle'),
  truck('Truck'),
  van('Van'),
  bus('Bus'),
  other('Other');

  final String displayName;
  const VehicleType(this.displayName);

  static VehicleType fromString(String type) {
    return VehicleType.values.firstWhere((e) => e.name.toLowerCase() == type.toLowerCase(), orElse: () => VehicleType.other);
  }
}
