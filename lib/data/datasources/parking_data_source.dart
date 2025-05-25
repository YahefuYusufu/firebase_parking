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
    // 1. CHECK IF VEHICLE IS ALREADY PARKED
    final existingParkingQuery = await _parkingCollection.where('vehicle_id', isEqualTo: parking.vehicle.id).where('finished_at', isNull: true).get();

    if (existingParkingQuery.docs.isNotEmpty) {
      throw Exception('Vehicle ${parking.vehicle.registrationNumber} is already parked in another space. Please end the current parking session first.');
    }

    // 2. CHECK IF PARKING SPACE IS OCCUPIED
    final spaceDoc = await _parkingSpacesCollection.doc(parking.parkingSpace.id).get();
    if (spaceDoc.exists) {
      final spaceData = spaceDoc.data() as Map<String, dynamic>?;
      if (spaceData != null && spaceData['status'] != 'vacant') {
        throw Exception('Parking space ${parking.parkingSpace.spaceNumber} is not available');
      }
    }

    // 3. Save the parking record
    final docRef = await _parkingCollection.add(parking.toFirestore());

    // 4. Update parking space status to occupied
    await _parkingSpacesCollection.doc(parking.parkingSpace.id).update({'status': 'occupied', 'vehicle_id': parking.vehicle.id});

    // 5. Return the created parking with the generated ID
    return parking.copyWith(id: docRef.id);
  }

  @override
  Future<ParkingModel?> getParking(String parkingId) async {
    try {
      final doc = await _parkingCollection.doc(parkingId).get();

      if (!doc.exists || doc.data() == null) {
        print('⚠️ Parking document $parkingId not found or has null data');
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;

      // Check if required fields exist
      if (data['vehicle_id'] == null || data['parking_space_id'] == null) {
        print('⚠️ Parking document $parkingId missing required fields');
        return null;
      }

      // Fetch the vehicle with null check
      final vehicleDoc = await _vehiclesCollection.doc(data['vehicle_id']).get();
      if (!vehicleDoc.exists || vehicleDoc.data() == null) {
        print('⚠️ Vehicle ${data['vehicle_id']} not found for parking $parkingId');
        return null;
      }
      final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
      final vehicle = VehicleModel.fromFirestore(vehicleData, vehicleDoc.id);

      // Fetch the parking space with null check
      final spaceDoc = await _parkingSpacesCollection.doc(data['parking_space_id']).get();
      if (!spaceDoc.exists || spaceDoc.data() == null) {
        print('⚠️ Parking space ${data['parking_space_id']} not found for parking $parkingId');
        return null;
      }
      final spaceData = spaceDoc.data() as Map<String, dynamic>;
      final parkingSpace = ParkingSpaceModel.fromFirestore(spaceData, spaceDoc.id);

      // Create and return the parking model
      return ParkingModel.fromFirestore(data, doc.id, vehicle, parkingSpace);
    } catch (e) {
      print('❌ Error getting parking $parkingId: $e');
      return null;
    }
  }

  @override
  Future<List<ParkingModel>> getActiveParking() async {
    print('🔍 Fetching active parking...');

    try {
      final query = await _parkingCollection.where('finished_at', isNull: true).orderBy('started_at', descending: true).get();

      print('📊 Found ${query.docs.length} active parking documents');

      final parkingList = <ParkingModel>[];

      for (final doc in query.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;

          // Check if document data is null
          if (data == null) {
            print('⚠️ Document ${doc.id} has null data, skipping...');
            continue;
          }

          // Check if required fields exist
          if (data['vehicle_id'] == null || data['parking_space_id'] == null) {
            print('⚠️ Document ${doc.id} missing required fields, skipping...');
            continue;
          }

          print('📄 Processing doc: ${doc.id} - Vehicle ID: ${data['vehicle_id']}');

          // Fetch the vehicle with null check
          final vehicleDoc = await _vehiclesCollection.doc(data['vehicle_id']).get();
          if (!vehicleDoc.exists || vehicleDoc.data() == null) {
            print('⚠️ Vehicle not found: ${data['vehicle_id']}, skipping parking ${doc.id}');
            continue;
          }

          final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
          final vehicle = VehicleModel.fromFirestore(vehicleData, vehicleDoc.id);

          // Fetch the parking space with null check
          final spaceDoc = await _parkingSpacesCollection.doc(data['parking_space_id']).get();
          if (!spaceDoc.exists || spaceDoc.data() == null) {
            print('⚠️ Parking space not found: ${data['parking_space_id']}, skipping parking ${doc.id}');
            continue;
          }

          final spaceData = spaceDoc.data() as Map<String, dynamic>;
          final parkingSpace = ParkingSpaceModel.fromFirestore(spaceData, spaceDoc.id);

          // Create and add the parking model
          final parkingModel = ParkingModel.fromFirestore(data, doc.id, vehicle, parkingSpace);
          parkingList.add(parkingModel);
          print('✅ Added parking: ${vehicle.registrationNumber} at ${parkingSpace.spaceNumber}');
        } catch (e) {
          print('❌ Error processing parking doc ${doc.id}: $e');
          continue; // Skip this document and continue with others
        }
      }

      print('🎉 Total active parking loaded: ${parkingList.length}');
      return parkingList;
    } catch (e) {
      print('❌ Error in getActiveParking: $e');
      throw Exception('Failed to fetch active parking: $e');
    }
  }

  @override
  Future<List<ParkingModel>> getUserParking(String userId) async {
    print('🔍 Fetching user parking for: $userId');

    try {
      // First, get all vehicles belonging to the user
      final vehiclesQuery = await _vehiclesCollection.where('owner_id', isEqualTo: userId).get();
      final vehicleIds = vehiclesQuery.docs.map((doc) => doc.id).toList();

      print('🚗 Found ${vehicleIds.length} vehicles for user');

      if (vehicleIds.isEmpty) {
        return [];
      }

      // Get parking records for these vehicles
      final parkingQuery = await _parkingCollection.where('vehicle_id', whereIn: vehicleIds).orderBy('started_at', descending: true).get();

      print('📊 Found ${parkingQuery.docs.length} parking records');

      final parkingList = <ParkingModel>[];

      for (final doc in parkingQuery.docs) {
        try {
          final data = doc.data() as Map<String, dynamic>?;

          // Check if document data is null
          if (data == null) {
            print('⚠️ Document ${doc.id} has null data, skipping...');
            continue;
          }

          // Check if required fields exist
          if (data['vehicle_id'] == null || data['parking_space_id'] == null) {
            print('⚠️ Document ${doc.id} missing required fields, skipping...');
            continue;
          }

          // Fetch the vehicle with null check
          final vehicleDoc = await _vehiclesCollection.doc(data['vehicle_id']).get();
          if (!vehicleDoc.exists || vehicleDoc.data() == null) {
            print('⚠️ Vehicle not found: ${data['vehicle_id']}, skipping parking ${doc.id}');
            continue;
          }

          final vehicleData = vehicleDoc.data() as Map<String, dynamic>;
          final vehicle = VehicleModel.fromFirestore(vehicleData, vehicleDoc.id);

          // Fetch the parking space with null check
          final spaceDoc = await _parkingSpacesCollection.doc(data['parking_space_id']).get();
          if (!spaceDoc.exists || spaceDoc.data() == null) {
            print('⚠️ Parking space not found: ${data['parking_space_id']}, skipping parking ${doc.id}');
            continue;
          }

          final spaceData = spaceDoc.data() as Map<String, dynamic>;
          final parkingSpace = ParkingSpaceModel.fromFirestore(spaceData, spaceDoc.id);

          // Create and add the parking model
          final parkingModel = ParkingModel.fromFirestore(data, doc.id, vehicle, parkingSpace);
          parkingList.add(parkingModel);
        } catch (e) {
          print('❌ Error processing user parking doc ${doc.id}: $e');
          continue; // Skip this document and continue with others
        }
      }

      print('🎉 Total user parking loaded: ${parkingList.length}');
      return parkingList;
    } catch (e) {
      print('❌ Error in getUserParking: $e');
      throw Exception('Failed to fetch user parking: $e');
    }
  }

  @override
  Future<ParkingModel> endParking(String parkingId) async {
    try {
      // Get the current parking record
      final doc = await _parkingCollection.doc(parkingId).get();

      if (!doc.exists || doc.data() == null) {
        throw Exception('Parking record not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      // Update the parking record with end time
      final now = DateTime.now();
      await _parkingCollection.doc(parkingId).update({'finished_at': now.toIso8601String()});

      // Free up the parking space (only if it still exists)
      final spaceId = data['parking_space_id'];
      if (spaceId != null) {
        final spaceDoc = await _parkingSpacesCollection.doc(spaceId).get();
        if (spaceDoc.exists) {
          await _parkingSpacesCollection.doc(spaceId).update({'status': 'vacant', 'vehicle_id': null});
          print('✅ Freed up parking space: $spaceId');
        } else {
          print('⚠️ Parking space $spaceId not found when ending parking - may have been deleted');
        }
      }

      // Return the updated parking record
      final updatedParking = await getParking(parkingId);
      if (updatedParking == null) {
        throw Exception('Failed to retrieve updated parking record');
      }
      return updatedParking;
    } catch (e) {
      print('❌ Error ending parking $parkingId: $e');
      throw Exception('Failed to end parking: $e');
    }
  }
}
