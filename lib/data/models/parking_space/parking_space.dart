import '../vehicles/vehicle.dart';

class ParkingSpace {
  final String? id;
  final String spaceNumber;
  final String type; // regular, handicapped, compact
  final String status; // occupied, vacant
  final String? level; // floor/level number
  final String section; // A, B, C etc.
  final double hourlyRate;
  final Vehicle? occupiedBy; // current vehicle occupying the space

  ParkingSpace({this.id, required this.spaceNumber, required this.type, this.status = 'vacant', this.level, required this.section, required this.hourlyRate, this.occupiedBy});

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

  // For database operations (following your Vehicle pattern)
  Map<String, dynamic> toMap() {
    return {'id': id, 'space_number': spaceNumber, 'type': type, 'status': status, 'level': level, 'section': section, 'hourly_rate': hourlyRate, 'vehicle_id': occupiedBy?.id};
  }

  // Deserialization - Create ParkingSpace from JSON Map
  factory ParkingSpace.fromJson(Map<String, dynamic> json) {
    return ParkingSpace(
      id: json['id'],
      spaceNumber: json['space_number'],
      type: json['type'],
      status: json['status'],
      level: json['level'],
      section: json['section'],
      hourlyRate: json['hourly_rate'],
      occupiedBy: json['occupied_by'] != null ? Vehicle.fromJson(json['occupied_by']) : null,
    );
  }

  @override
  String toString() {
    return 'ParkingSpace(id: $id, spaceNumber: $spaceNumber, type: $type, '
        'status: $status, level: $level, section: $section, '
        'hourlyRate: $hourlyRate, occupiedBy: $occupiedBy)';
  }
}
