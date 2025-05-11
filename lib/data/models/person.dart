import 'user_model.dart';

class Person {
  final String? id;
  final String name;
  final String personalNumber;
  final String? email;
  final List<String>? vehicleIds;

  Person({this.id, required this.name, required this.personalNumber, this.email, this.vehicleIds});

  // Serialization - Convert Person to JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'personal_number': personalNumber, 'email': email, 'vehicle_ids': vehicleIds};
  }

  // Deserialization - Create Person from JSON Map
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      personalNumber: json['personal_number'],
      email: json['email'],
      vehicleIds: json['vehicle_ids'] != null ? List<String>.from(json['vehicle_ids']) : null,
    );
  }

  // Convert User Model to Person
  factory Person.fromUserModel(UserModel userModel) {
    if (userModel.name == null || userModel.personalNumber == null) {
      throw Exception('Cannot create Person: name or personalNumber is null');
    }

    return Person(id: userModel.id, name: userModel.name!, personalNumber: userModel.personalNumber!, email: userModel.email, vehicleIds: userModel.vehicleIds);
  }

  // Convert to UserModel
  UserModel toUserModel({bool isEmailVerified = false}) {
    return UserModel(id: id, name: name, personalNumber: personalNumber, email: email, vehicleIds: vehicleIds, isEmailVerified: isEmailVerified);
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $name, personalNumber: $personalNumber, '
        'email: $email, vehicleIds: $vehicleIds)';
  }
}
