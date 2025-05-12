import '../vehicles/vehicle.dart';
import '../parking_space/parking_space.dart';

class Parking {
  final String? id;
  final Vehicle vehicle;
  final ParkingSpace parkingSpace;
  final DateTime startedAt;
  final DateTime? finishedAt;

  Parking({this.id, required this.vehicle, required this.parkingSpace, required this.startedAt, this.finishedAt});

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
    // Convert to hours and multiply by hourly rate
    final hours = duration.inMinutes / 60.0;
    return hours * parkingSpace.hourlyRate;
  }

  // Check if the parking session is active
  bool get isActive => finishedAt == null;

  // Serialization - Convert Parking to JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'vehicle': vehicle.toJson(), 'parking_space': parkingSpace.toJson(), 'started_at': startedAt.toIso8601String(), 'finished_at': finishedAt?.toIso8601String()};
  }

  // Deserialization - Create Parking from JSON Map
  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      parkingSpace: ParkingSpace.fromJson(json['parking_space']),
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
    );
  }

  @override
  String toString() {
    final status = isActive ? 'Active' : 'Completed';
    final durationStr = '${duration.inHours}h ${duration.inMinutes % 60}m';

    return 'Parking(id: $id, status: $status, vehicle: ${vehicle.registrationNumber}, '
        'space: ${parkingSpace.spaceNumber}, duration: $durationStr)';
  }
}
