import 'package:firebase_parking/data/models/person/person.dart';
import 'package:firebase_parking/domain/entities/vehicle_entity.dart';

class VehicleModel {
  final String? id;
  final String registrationNumber;
  final String type;
  final String ownerId;
  final Person? owner;

  VehicleModel({this.id, required this.registrationNumber, required this.type, required this.ownerId, this.owner});

  // Convert to domain entity
  VehicleEntity toEntity() {
    return VehicleEntity(id: id, registrationNumber: registrationNumber, type: type, ownerId: ownerId, ownerName: owner?.name);
  }

  // Create from domain entity
  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      registrationNumber: entity.registrationNumber,
      type: entity.type,
      ownerId: entity.ownerId,
      // Note: We don't recreate the full Person object from entity
    );
  }

  // Serialization - Convert Vehicle to JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'registration_number': registrationNumber, 'type': type, 'owner_id': ownerId, 'owner': owner?.toJson()};
  }

  // For database operations (Firestore document)
  Map<String, dynamic> toFirestore() {
    return {
      'registration_number': registrationNumber,
      'type': type,
      'owner_id': ownerId,
      // Don't include 'id' as Firestore generates it
      // Don't include 'owner' as it's a joined field
    };
  }

  // Deserialization - Create Vehicle from JSON Map
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'],
      registrationNumber: json['registration_number'],
      type: json['type'],
      ownerId: json['owner_id'] ?? json['ownerId'] ?? '',
      owner: json['owner'] != null ? Person.fromJson(json['owner']) : null,
    );
  }

  // Create from Firestore document
  factory VehicleModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return VehicleModel(
      id: documentId,
      registrationNumber: json['registration_number'] ?? '',
      type: json['type'] ?? 'car',
      ownerId: json['owner_id'] ?? '',
      // Owner data might be populated separately
    );
  }

  // Copy with method
  VehicleModel copyWith({String? id, String? registrationNumber, String? type, String? ownerId, Person? owner}) {
    return VehicleModel(
      id: id ?? this.id,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      type: type ?? this.type,
      ownerId: ownerId ?? this.ownerId,
      owner: owner ?? this.owner,
    );
  }

  @override
  String toString() {
    return 'VehicleModel(id: $id, registrationNumber: $registrationNumber, type: $type, ownerId: $ownerId, owner: $owner)';
  }
}
