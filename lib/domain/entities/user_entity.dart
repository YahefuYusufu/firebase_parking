// lib/domain/entities/user_entity.dart
class UserEntity {
  final String? id;
  final String? email;
  final bool isEmailVerified;
  final String? name;
  final String? personalNumber;
  final List<String>? vehicleIds;

  const UserEntity({this.id, this.email, this.isEmailVerified = false, this.name, this.personalNumber, this.vehicleIds});

  // Optional: Include a method to check if user has complete profile
  bool get hasCompleteProfile => name != null && personalNumber != null;
}
