class ParkingEntity {
  final String? id;
  final String? vehicleId;
  final String? parkingSpaceId;
  final DateTime startedAt;
  final DateTime? finishedAt;

  // Additional fields for convenience
  final String? vehicleRegistration;
  final String? parkingSpaceNumber;
  final double? hourlyRate;

  ParkingEntity({this.id, this.vehicleId, this.parkingSpaceId, required this.startedAt, this.finishedAt, this.vehicleRegistration, this.parkingSpaceNumber, this.hourlyRate});

  // Check if the parking session is active
  bool get isActive => finishedAt == null;

  // Calculate the duration of the parking session
  Duration get duration {
    if (finishedAt != null) {
      return finishedAt!.difference(startedAt);
    } else {
      // For ongoing sessions, calculate duration until now
      return DateTime.now().difference(startedAt);
    }
  }

  // Calculate the parking fee based on duration and hourly rate
  double calculateFee() {
    if (hourlyRate == null) return 0.0;

    // Convert to hours and multiply by hourly rate
    final hours = duration.inMinutes / 60.0;
    return hours * hourlyRate!;
  }

  // Copy with method
  ParkingEntity copyWith({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) {
    return ParkingEntity(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      parkingSpaceId: parkingSpaceId ?? this.parkingSpaceId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber ?? this.parkingSpaceNumber,
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }
}
