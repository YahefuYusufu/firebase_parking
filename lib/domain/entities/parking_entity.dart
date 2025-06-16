class ParkingEntity {
  final String? id;
  final String? vehicleId;
  final String? parkingSpaceId;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Duration originalTimeLimit; // Original time limit when parking started
  final List<ParkingExtension> extensions; // List of extensions made

  // Additional fields for convenience
  final String? vehicleRegistration;
  final String? parkingSpaceNumber;
  final double? hourlyRate;

  ParkingEntity({
    this.id,
    this.vehicleId,
    this.parkingSpaceId,
    required this.startedAt,
    this.finishedAt,
    required this.originalTimeLimit, // Required field
    this.extensions = const [], // Default to empty list
    this.vehicleRegistration,
    this.parkingSpaceNumber,
    this.hourlyRate,
  });

  // Check if the parking session is active
  bool get isActive => finishedAt == null;

  // Calculate total time limit including all extensions
  Duration get totalTimeLimit {
    Duration total = originalTimeLimit;
    for (final extension in extensions) {
      total += extension.additionalTime;
    }
    return total;
  }

  // Calculate the expected end time based on start time + total time limit
  DateTime get expectedEndTime => startedAt.add(totalTimeLimit);

  // Check if parking has expired (past expected end time)
  bool get hasExpired => DateTime.now().isAfter(expectedEndTime);

  // Calculate time remaining until expiration
  Duration get timeRemaining {
    if (!isActive) return Duration.zero;
    final remaining = expectedEndTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  // Check if parking is in grace period (expired but within grace time)
  bool isInGracePeriod([Duration gracePeriod = const Duration(minutes: 5)]) {
    if (!hasExpired) return false;
    final graceEndTime = expectedEndTime.add(gracePeriod);
    return DateTime.now().isBefore(graceEndTime);
  }

  // Check if extension is allowed (not expired or within grace period)
  bool get canExtend => !hasExpired || isInGracePeriod();

  // Get total extensions count
  int get extensionCount => extensions.length;

  // Get total extension time
  Duration get totalExtensionTime {
    return extensions.fold(Duration.zero, (total, extension) => total + extension.additionalTime);
  }

  // Get total extension cost
  double get totalExtensionCost {
    return extensions.fold(0.0, (total, extension) => total + extension.cost);
  }

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

    // Base fee for original time
    final originalHours = originalTimeLimit.inMinutes / 60.0;
    final baseFee = originalHours * hourlyRate!;

    // Add extension costs
    return baseFee + totalExtensionCost;
  }

  // Calculate potential overage fee if parking exceeds total time limit
  double calculateOverageFee({double? overageRate}) {
    if (!hasExpired || hourlyRate == null) return 0.0;

    final overageTime = duration - totalTimeLimit;
    if (overageTime.isNegative) return 0.0;

    final overageHours = overageTime.inMinutes / 60.0;
    final rate = overageRate ?? (hourlyRate! * 2.0); // 2x rate for overage
    return overageHours * rate;
  }

  // Get total fee including overage
  double get totalFee => calculateFee() + calculateOverageFee();

  // Helper method to get formatted total time limit
  String get formattedTotalTimeLimit {
    final hours = totalTimeLimit.inHours;
    final minutes = totalTimeLimit.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Helper method to get formatted time remaining
  String get formattedTimeRemaining {
    final remaining = timeRemaining;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  // Method to extend parking time
  ParkingEntity extend({required Duration additionalTime, required double cost, String? reason}) {
    if (!canExtend) {
      throw Exception('Cannot extend parking: session has expired beyond grace period');
    }

    final extension = ParkingExtension(additionalTime: additionalTime, cost: cost, extendedAt: DateTime.now(), reason: reason);

    return copyWith(extensions: [...extensions, extension]);
  }

  // Method to check if parking needs a reminder soon
  bool needsReminder([Duration beforeExpiry = const Duration(minutes: 15)]) {
    if (!isActive || hasExpired) return false;
    final reminderTime = expectedEndTime.subtract(beforeExpiry);
    return DateTime.now().isAfter(reminderTime);
  }

  // Copy with method
  ParkingEntity copyWith({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    DateTime? startedAt,
    DateTime? finishedAt,
    Duration? originalTimeLimit,
    List<ParkingExtension>? extensions,
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
      originalTimeLimit: originalTimeLimit ?? this.originalTimeLimit,
      extensions: extensions ?? this.extensions,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber ?? this.parkingSpaceNumber,
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }

  // Factory constructors for common parking durations
  static ParkingEntity createWithDuration({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    required DateTime startedAt,
    DateTime? finishedAt,
    required int hours,
    int minutes = 0,
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) {
    return ParkingEntity(
      id: id,
      vehicleId: vehicleId,
      parkingSpaceId: parkingSpaceId,
      startedAt: startedAt,
      finishedAt: finishedAt,
      originalTimeLimit: Duration(hours: hours, minutes: minutes),
      vehicleRegistration: vehicleRegistration,
      parkingSpaceNumber: parkingSpaceNumber,
      hourlyRate: hourlyRate,
    );
  }

  // Common parking durations
  static ParkingEntity create1Hour({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    required DateTime startedAt,
    DateTime? finishedAt,
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) => createWithDuration(
    id: id,
    vehicleId: vehicleId,
    parkingSpaceId: parkingSpaceId,
    startedAt: startedAt,
    finishedAt: finishedAt,
    hours: 1,
    vehicleRegistration: vehicleRegistration,
    parkingSpaceNumber: parkingSpaceNumber,
    hourlyRate: hourlyRate,
  );

  static ParkingEntity create2Hours({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    required DateTime startedAt,
    DateTime? finishedAt,
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) => createWithDuration(
    id: id,
    vehicleId: vehicleId,
    parkingSpaceId: parkingSpaceId,
    startedAt: startedAt,
    finishedAt: finishedAt,
    hours: 2,
    vehicleRegistration: vehicleRegistration,
    parkingSpaceNumber: parkingSpaceNumber,
    hourlyRate: hourlyRate,
  );

  static ParkingEntity create4Hours({
    String? id,
    String? vehicleId,
    String? parkingSpaceId,
    required DateTime startedAt,
    DateTime? finishedAt,
    String? vehicleRegistration,
    String? parkingSpaceNumber,
    double? hourlyRate,
  }) => createWithDuration(
    id: id,
    vehicleId: vehicleId,
    parkingSpaceId: parkingSpaceId,
    startedAt: startedAt,
    finishedAt: finishedAt,
    hours: 4,
    vehicleRegistration: vehicleRegistration,
    parkingSpaceNumber: parkingSpaceNumber,
    hourlyRate: hourlyRate,
  );

  @override
  String toString() {
    return 'ParkingEntity{id: $id, vehicle: $vehicleRegistration, space: $parkingSpaceNumber, '
        'duration: $formattedTotalTimeLimit, remaining: $formattedTimeRemaining, '
        'extensions: $extensionCount, active: $isActive}';
  }
}

// Extension tracking class
class ParkingExtension {
  final Duration additionalTime;
  final double cost;
  final DateTime extendedAt;
  final String? reason;

  const ParkingExtension({required this.additionalTime, required this.cost, required this.extendedAt, this.reason});

  // Helper method to get formatted additional time
  String get formattedAdditionalTime {
    final hours = additionalTime.inHours;
    final minutes = additionalTime.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  String toString() {
    return 'ParkingExtension{time: $formattedAdditionalTime, cost: \${cost.toStringAsFixed(2)}, '
        'at: ${extendedAt.toIso8601String()}, reason: $reason}';
  }

  // Convert to/from JSON for storage
  Map<String, dynamic> toJson() {
    return {'additionalTime': additionalTime.inMilliseconds, 'cost': cost, 'extendedAt': extendedAt.toIso8601String(), 'reason': reason};
  }

  factory ParkingExtension.fromJson(Map<String, dynamic> json) {
    return ParkingExtension(
      additionalTime: Duration(milliseconds: json['additionalTime']),
      cost: (json['cost'] as num).toDouble(),
      extendedAt: DateTime.parse(json['extendedAt']),
      reason: json['reason'],
    );
  }
}
