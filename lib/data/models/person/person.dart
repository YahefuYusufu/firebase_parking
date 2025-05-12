// lib/data/models/person.dart
// ignore_for_file: avoid_print

import 'user_model.dart';

class Person {
  final String? id;
  final String name;
  final String personalNumber;
  final String? email;
  final List<String>? vehicleIds;
  final String? profilePictureUrl; // Add this field to align with UserModel

  Person({
    this.id,
    required this.name,
    required this.personalNumber,
    this.email,
    this.vehicleIds,
    this.profilePictureUrl, // Initialize it
  });

  // Serialization - Convert Person to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'personal_number': personalNumber,
      'email': email,
      'vehicle_ids': vehicleIds,
      'profile_picture_url': profilePictureUrl, // Include in JSON
    };
  }

  // Deserialization - Create Person from JSON Map
  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      name: json['name'],
      personalNumber: json['personal_number'],
      email: json['email'],
      vehicleIds: json['vehicle_ids'] != null ? List<String>.from(json['vehicle_ids']) : null,
      profilePictureUrl: json['profile_picture_url'], // Parse from JSON
    );
  }

  // Convert User Model to Person
  factory Person.fromUserModel(UserModel userModel) {
    if (userModel.name == null || userModel.personalNumber == null) {
      print("WARNING: Converting UserModel to Person with missing required fields: name=${userModel.name}, personalNumber=${userModel.personalNumber}");
      throw Exception('Cannot create Person: name or personalNumber is null');
    }

    return Person(
      id: userModel.id,
      name: userModel.name!,
      personalNumber: userModel.personalNumber!,
      email: userModel.email,
      vehicleIds: userModel.vehicleIds,
      profilePictureUrl: userModel.profilePictureUrl,
    );
  }

  // Convert to UserModel
  UserModel toUserModel({bool isEmailVerified = false}) {
    return UserModel(
      id: id,
      name: name,
      personalNumber: personalNumber,
      email: email,
      vehicleIds: vehicleIds,
      profilePictureUrl: profilePictureUrl,
      isEmailVerified: isEmailVerified,
    );
  }

  // Create a new Person with updated fields
  Person copyWith({String? id, String? name, String? personalNumber, String? email, List<String>? vehicleIds, String? profilePictureUrl}) {
    return Person(
      id: id ?? this.id,
      name: name ?? this.name,
      personalNumber: personalNumber ?? this.personalNumber,
      email: email ?? this.email,
      vehicleIds: vehicleIds ?? this.vehicleIds,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  String toString() {
    return 'Person(id: $id, name: $name, personalNumber: $personalNumber, '
        'email: $email, vehicleIds: $vehicleIds, profilePictureUrl: $profilePictureUrl)';
  }
}
