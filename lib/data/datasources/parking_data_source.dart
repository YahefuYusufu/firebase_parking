// lib/data/datasources/parking_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_parking/data/models/parking/parking_model.dart';
import 'package:firebase_parking/data/models/parking_space/parking_space_model.dart';
import 'package:firebase_parking/data/models/vehicles/vehicle_model.dart';

abstract class ParkingDataSource {
  Future<ParkingModel> createParking(ParkingModel parking);
  Future<ParkingModel?> getParking(String parkingId);
  Future<List<ParkingModel>> getActiveParking();
  Future<List<ParkingModel>> getUserParking(String userId);
  Future<ParkingModel> endParking(String parkingId);
}

class FirebaseParkingDataSource implements ParkingDataSource {
  final FirebaseFirestore _firestore;

  FirebaseParkingDataSource({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collections
  CollectionReference get _parkingCollection => _firestore.collection('parking');
  CollectionReference get _vehiclesCollection => _firestore.collection('vehicles');
  CollectionReference get _parkingSpacesCollection => _firestore.collection('parking_spaces');

  @override
  Future<ParkingModel> createParking(ParkingModel parking) async {
    // 1. Save the parking record
    final docRef = await _parkingCollection.add(parking.toFirestore());

    // 2. Update parking space status to occupied
    await _parkingSpacesCollection.doc(parking.parkingSpace.id).update({'status': 'occupied', 'vehicle_id': parking.vehicle.id});

    // 3. Return the created parking with the generated ID
    return parking.copyWith(id: docRef.id);
  }

  @override
  Future<ParkingModel?> getParking(String parkingId) async {
    final doc = await _parkingCollection.doc(parkingId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data() as Map<String, dynamic>;

    // Fetch the vehicle
    final vehicleDoc = await _vehiclesCollection.doc(data['vehicle_id']).get();
    final vehicle = VehicleModel.fromFirestore(vehicleDoc.data() as Map<String, dynamic>, vehicleDoc.id);

    // Fetch the parking space
    final spaceDoc = await _parkingSpacesCollection.doc(data['parking_space_id']).get();
    final parkingSpace = ParkingSpaceModel.fromFirestore(spaceDoc.data() as Map<String, dynamic>, spaceDoc.id);

    // Create and return the parking model
    return ParkingModel.fromFirestore(data, doc.id, vehicle, parkingSpace);
  }

  @override
  Future<List<ParkingModel>> getActiveParking() async {
    final query = await _parkingCollection.where('finished_at', isNull: true).orderBy('started_at', descending: true).get();

    final parkingList = <ParkingModel>[];

    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Fetch the vehicle
      final vehicleDoc = await _vehiclesCollection.doc(data['vehicle_id']).get();
      final vehicle = VehicleModel.fromFirestore(vehicleDoc.data() as Map<String, dynamic>, vehicleDoc.id);

      // Fetch the parking space
      final spaceDoc = await _parkingSpacesCollection.doc(data['parking_space_id']).get();
      final parkingSpace = ParkingSpaceModel.fromFirestore(spaceDoc.data() as Map<String, dynamic>, spaceDoc.id);

      // Create and add the parking model
      parkingList.add(ParkingModel.fromFirestore(data, doc.id, vehicle, parkingSpace));
    }

    return parkingList;
  }

  @override
  Future<List<ParkingModel>> getUserParking(String userId) async {
    // First, get all vehicles belonging to the user
    final vehiclesQuery = await _vehiclesCollection.where('owner_id', isEqualTo: userId).get();

    final vehicleIds = vehiclesQuery.docs.map((doc) => doc.id).toList();

    if (vehicleIds.isEmpty) {
      return [];
    }

    // Then get all parking records for these vehicles
    final parkingQuery = await _parkingCollection.where('vehicle_id', whereIn: vehicleIds).orderBy('started_at', descending: true).get();

    final parkingList = <ParkingModel>[];

    for (final doc in parkingQuery.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Fetch the vehicle
      final vehicleDoc = await _vehiclesCollection.doc(data['vehicle_id']).get();
      final vehicle = VehicleModel.fromFirestore(vehicleDoc.data() as Map<String, dynamic>, vehicleDoc.id);

      // Fetch the parking space
      final spaceDoc = await _parkingSpacesCollection.doc(data['parking_space_id']).get();
      final parkingSpace = ParkingSpaceModel.fromFirestore(spaceDoc.data() as Map<String, dynamic>, spaceDoc.id);

      // Create and add the parking model
      parkingList.add(ParkingModel.fromFirestore(data, doc.id, vehicle, parkingSpace));
    }

    return parkingList;
  }

  @override
  Future<ParkingModel> endParking(String parkingId) async {
    // Get the current parking record
    final doc = await _parkingCollection.doc(parkingId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('Parking record not found');
    }

    final data = doc.data() as Map<String, dynamic>;

    // Update the parking record with end time
    final now = DateTime.now();
    await _parkingCollection.doc(parkingId).update({'finished_at': now.toIso8601String()});

    // Free up the parking space
    await _parkingSpacesCollection.doc(data['parking_space_id']).update({'status': 'vacant', 'vehicle_id': null});

    // Return the updated parking record
    final updatedParking = await getParking(parkingId);
    if (updatedParking == null) {
      throw Exception('Failed to retrieve updated parking record');
    }
    return updatedParking;
  }
}
