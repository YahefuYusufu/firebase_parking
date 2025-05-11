// lib/domain/entities/user_entity.dart
// ignore_for_file: avoid_print

class UserEntity {
  final String? id;
  final String? email;
  final bool isEmailVerified;
  final String? name;
  final String? personalNumber;
  final List<String>? vehicleIds;
  final String? profilePictureUrl;

  const UserEntity({this.id, this.email, this.isEmailVerified = false, this.name, this.personalNumber, this.vehicleIds, this.profilePictureUrl});

  // Helper method to check if profile is complete
  bool get hasCompleteProfile {
    final hasName = name != null && name!.isNotEmpty;
    final hasPersonalNumber = personalNumber != null && personalNumber!.isNotEmpty;

    print("Checking if profile is complete: hasName=$hasName, hasPersonalNumber=$hasPersonalNumber");
    return hasName && hasPersonalNumber;
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name, personalNumber: $personalNumber, '
        'isEmailVerified: $isEmailVerified, vehicleIds: $vehicleIds, '
        'profilePictureUrl: $profilePictureUrl)';
  }

  // For equatable comparison (helpful for testing and BLoC)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.isEmailVerified == isEmailVerified &&
        other.name == name &&
        other.personalNumber == personalNumber &&
        _listEquals(other.vehicleIds, vehicleIds) &&
        other.profilePictureUrl == profilePictureUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ isEmailVerified.hashCode ^ name.hashCode ^ personalNumber.hashCode ^ vehicleIds.hashCode ^ profilePictureUrl.hashCode;
  }

  // Helper method for list comparison
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
