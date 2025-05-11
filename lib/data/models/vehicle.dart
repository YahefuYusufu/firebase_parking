import 'person.dart';

class Vehicle {
  final String? id;
  final String registrationNumber;
  final String type;
  final String ownerId;
  final Person? owner;

  Vehicle({this.id, required this.registrationNumber, required this.type, required this.ownerId, this.owner});

  // Serialization - Convert Vehicle to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_number': registrationNumber,
      'type': type,
      'ownerId': ownerId,
      'owner': owner?.toJson(), // Convert owner Person object to JSON
    };
  }

  // For database operations (internal use in repository)
  Map<String, dynamic> toMap() {
    return {'id': id, 'registration_number': registrationNumber, 'type': type, 'owner_id': ownerId};
  }

  // Deserialization - Create Vehicle from JSON Map
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      registrationNumber: json['registration_number'],
      type: json['type'],
      ownerId: json['ownerId'] ?? json['owner_id'] ?? '',
      owner: json['owner'] != null ? Person.fromJson(json['owner']) : null,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, registrationNumber: $registrationNumber, type: $type, ownerId: $ownerId, owner: $owner)';
  }
}
