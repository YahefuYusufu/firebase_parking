import 'package:equatable/equatable.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';

class ParkingSpaceEntity extends Equatable {
  final String? id;
  final String spaceNumber;
  final ParkingSpaceType type;
  final ParkingSpaceStatus status;
  final String? level;
  final String section;
  final double hourlyRate;
  final VehicleEntity? occupiedBy;

  const ParkingSpaceEntity({
    this.id,
    required this.spaceNumber,
    required this.type,
    required this.status,
    this.level,
    required this.section,
    required this.hourlyRate,
    this.occupiedBy,
  });

  @override
  List<Object?> get props => [id, spaceNumber, type, status, level, section, hourlyRate, occupiedBy];

  // Convenience methods
  bool get isVacant => status == ParkingSpaceStatus.vacant;
  bool get isOccupied => status == ParkingSpaceStatus.occupied;
  String get displayName => '$section-$spaceNumber';
  String get fullLocation => level != null ? 'Level $level, Section $section, Space $spaceNumber' : 'Section $section, Space $spaceNumber';

  // Copy with method for updating
  ParkingSpaceEntity copyWith({
    String? id,
    String? spaceNumber,
    ParkingSpaceType? type,
    ParkingSpaceStatus? status,
    String? level,
    String? section,
    double? hourlyRate,
    VehicleEntity? occupiedBy,
  }) {
    return ParkingSpaceEntity(
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
    return 'ParkingSpaceEntity(id: $id, spaceNumber: $spaceNumber, type: $type, status: $status, level: $level, section: $section, hourlyRate: $hourlyRate, occupiedBy: $occupiedBy)';
  }
}

// Enum for parking space types
enum ParkingSpaceType {
  regular('Regular'),
  handicapped('Handicapped'),
  compact('Compact'),
  electric('Electric'),
  vip('VIP');

  final String displayName;
  const ParkingSpaceType(this.displayName);

  static ParkingSpaceType fromString(String type) {
    return ParkingSpaceType.values.firstWhere((e) => e.name.toLowerCase() == type.toLowerCase(), orElse: () => ParkingSpaceType.regular);
  }
}

// Enum for parking space status
enum ParkingSpaceStatus {
  vacant('Vacant'),
  occupied('Occupied'),
  reserved('Reserved'),
  maintenance('Maintenance');

  final String displayName;
  const ParkingSpaceStatus(this.displayName);

  static ParkingSpaceStatus fromString(String status) {
    return ParkingSpaceStatus.values.firstWhere((e) => e.name.toLowerCase() == status.toLowerCase(), orElse: () => ParkingSpaceStatus.vacant);
  }
}
