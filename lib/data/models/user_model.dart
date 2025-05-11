import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String? id;
  final String? email;
  final bool isEmailVerified;
  final String? name;
  final String? personalNumber;
  final List<String>? vehicleIds;

  const UserModel({this.id, this.email, this.isEmailVerified = false, this.name, this.personalNumber, this.vehicleIds});

  // Convert from Firebase Auth User
  factory UserModel.fromFirebaseUser(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      isEmailVerified: firebaseUser.emailVerified,
      // Note: Firebase Auth User doesn't have name, personalNumber, or vehicleIds
      // Those will be null until fetched from Firestore
    );
  }

  // Create from Firebase Auth User + Firestore data
  factory UserModel.fromFirebaseUserWithData(firebase_auth.User firebaseUser, Map<String, dynamic>? userData) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      isEmailVerified: firebaseUser.emailVerified,
      name: userData?['name'],
      personalNumber: userData?['personal_number'],
      vehicleIds: userData?['vehicle_ids'] != null ? List<String>.from(userData!['vehicle_ids']) : null,
    );
  }

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'personal_number': personalNumber,
      'vehicle_ids': vehicleIds,
      // Don't store isEmailVerified in Firestore as it's managed by Firebase Auth
    };
  }

  // Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      personalNumber: json['personal_number'],
      vehicleIds: json['vehicle_ids'] != null ? List<String>.from(json['vehicle_ids']) : null,
      // isEmailVerified would come from Firebase Auth, not Firestore
      isEmailVerified: false,
    );
  }

  // Convert to Domain Entity
  UserEntity toEntity() {
    return UserEntity(id: id, email: email, isEmailVerified: isEmailVerified, name: name, personalNumber: personalNumber, vehicleIds: vehicleIds);
  }

  // Create a new UserModel with updated fields
  UserModel copyWith({String? id, String? email, bool? isEmailVerified, String? name, String? personalNumber, List<String>? vehicleIds}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      name: name ?? this.name,
      personalNumber: personalNumber ?? this.personalNumber,
      vehicleIds: vehicleIds ?? this.vehicleIds,
    );
  }
}
