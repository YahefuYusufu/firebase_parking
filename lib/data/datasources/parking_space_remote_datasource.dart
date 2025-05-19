// lib/data/datasources/parking_space_remote_datasource.dart
// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_parking/data/models/parking_space/parking_space_model.dart';

abstract class ParkingSpaceRemoteDataSource {
  Future<ParkingSpaceModel> createParkingSpace(ParkingSpaceModel space);
  Future<List<ParkingSpaceModel>> getAllParkingSpaces();
  Future<List<ParkingSpaceModel>> getParkingSpacesByStatus(String status);
  Future<List<ParkingSpaceModel>> getParkingSpacesBySection(String section);
  Future<List<ParkingSpaceModel>> getParkingSpacesByLevel(String level);
  Future<ParkingSpaceModel> getParkingSpaceById(String spaceId);
  Future<ParkingSpaceModel> getParkingSpaceByNumber(String spaceNumber);
  Future<ParkingSpaceModel> updateParkingSpace(ParkingSpaceModel space);
  Future<void> deleteParkingSpace(String spaceId);
  Future<ParkingSpaceModel> occupyParkingSpace(String spaceId, String vehicleId);
  Future<ParkingSpaceModel> vacateParkingSpace(String spaceId);
  Stream<List<ParkingSpaceModel>> watchParkingSpaces();
  Future<int> getAvailableSpacesCount();
  Future<ParkingSpaceModel?> getSpaceByVehicleId(String vehicleId);
}

class ParkingSpaceRemoteDataSourceImpl implements ParkingSpaceRemoteDataSource {
  final FirebaseFirestore firestore;

  ParkingSpaceRemoteDataSourceImpl({required this.firestore});

  // Collection reference
  CollectionReference get _spacesCollection => firestore.collection('parking_spaces');

  @override
  Future<ParkingSpaceModel> createParkingSpace(ParkingSpaceModel space) async {
    try {
      print("ParkingSpaceDataSource: Creating new parking space");

      // Convert the model to Firestore data
      final data = space.toFirestore();

      // Create a new document with auto-generated ID if none provided
      DocumentReference docRef;
      if (space.id != null && space.id!.isNotEmpty) {
        docRef = _spacesCollection.doc(space.id);
        await docRef.set(data);
      } else {
        docRef = await _spacesCollection.add(data);
      }

      // Get the new space with the ID
      final newSpace = await getParkingSpaceById(docRef.id);

      print("ParkingSpaceDataSource: Created new parking space with ID: ${docRef.id}");
      return newSpace;
    } catch (e) {
      print("ParkingSpaceDataSource: Error creating parking space: $e");
      throw Exception('Failed to create parking space: $e');
    }
  }

  @override
  Future<List<ParkingSpaceModel>> getAllParkingSpaces() async {
    try {
      print("ParkingSpaceDataSource: Fetching all parking spaces");

      final querySnapshot = await _spacesCollection.get();

      final spaces =
          querySnapshot.docs.map((doc) {
            return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("ParkingSpaceDataSource: Found ${spaces.length} parking spaces");
      return spaces;
    } catch (e) {
      print("ParkingSpaceDataSource: Error fetching parking spaces: $e");
      throw Exception('Failed to fetch parking spaces: $e');
    }
  }

  @override
  Future<List<ParkingSpaceModel>> getParkingSpacesByStatus(String status) async {
    try {
      print("ParkingSpaceDataSource: Fetching spaces with status: $status");

      final querySnapshot = await _spacesCollection.where('status', isEqualTo: status).get();

      final spaces =
          querySnapshot.docs.map((doc) {
            return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("ParkingSpaceDataSource: Found ${spaces.length} $status spaces");
      return spaces;
    } catch (e) {
      print("ParkingSpaceDataSource: Error fetching spaces by status: $e");
      throw Exception('Failed to fetch spaces by status: $e');
    }
  }

  @override
  Future<List<ParkingSpaceModel>> getParkingSpacesBySection(String section) async {
    try {
      print("ParkingSpaceDataSource: Fetching spaces in section: $section");

      final querySnapshot = await _spacesCollection.where('section', isEqualTo: section).get();

      final spaces =
          querySnapshot.docs.map((doc) {
            return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("ParkingSpaceDataSource: Found ${spaces.length} spaces in section $section");
      return spaces;
    } catch (e) {
      print("ParkingSpaceDataSource: Error fetching spaces by section: $e");
      throw Exception('Failed to fetch spaces by section: $e');
    }
  }

  @override
  Future<List<ParkingSpaceModel>> getParkingSpacesByLevel(String level) async {
    try {
      print("ParkingSpaceDataSource: Fetching spaces on level: $level");

      final querySnapshot = await _spacesCollection.where('level', isEqualTo: level).get();

      final spaces =
          querySnapshot.docs.map((doc) {
            return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("ParkingSpaceDataSource: Found ${spaces.length} spaces on level $level");
      return spaces;
    } catch (e) {
      print("ParkingSpaceDataSource: Error fetching spaces by level: $e");
      throw Exception('Failed to fetch spaces by level: $e');
    }
  }

  @override
  Future<ParkingSpaceModel> getParkingSpaceById(String spaceId) async {
    try {
      print("ParkingSpaceDataSource: Fetching space with ID: $spaceId");

      final doc = await _spacesCollection.doc(spaceId).get();

      if (!doc.exists) {
        throw Exception('Parking space not found');
      }

      return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("ParkingSpaceDataSource: Error fetching space: $e");
      throw Exception('Failed to fetch parking space: $e');
    }
  }

  @override
  Future<ParkingSpaceModel> getParkingSpaceByNumber(String spaceNumber) async {
    try {
      print("ParkingSpaceDataSource: Fetching space with number: $spaceNumber");

      final querySnapshot = await _spacesCollection.where('space_number', isEqualTo: spaceNumber).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Parking space not found');
      }

      final doc = querySnapshot.docs.first;
      return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("ParkingSpaceDataSource: Error fetching space by number: $e");
      throw Exception('Failed to fetch parking space by number: $e');
    }
  }

  @override
  Future<ParkingSpaceModel> updateParkingSpace(ParkingSpaceModel space) async {
    try {
      print("ParkingSpaceDataSource: Updating space: ${space.id}");

      if (space.id == null) {
        throw Exception('Space ID is required for update');
      }

      await _spacesCollection.doc(space.id).update(space.toFirestore());

      print("ParkingSpaceDataSource: Space updated successfully");
      return space;
    } catch (e) {
      print("ParkingSpaceDataSource: Error updating space: $e");
      throw Exception('Failed to update parking space: $e');
    }
  }

  @override
  Future<void> deleteParkingSpace(String spaceId) async {
    try {
      print("ParkingSpaceDataSource: Deleting parking space with ID: $spaceId");

      // Check if space exists before deleting
      final docSnapshot = await _spacesCollection.doc(spaceId).get();
      if (!docSnapshot.exists) {
        throw Exception('Parking space not found');
      }

      // Delete the document
      await _spacesCollection.doc(spaceId).delete();

      print("ParkingSpaceDataSource: Successfully deleted parking space: $spaceId");
    } catch (e) {
      print("ParkingSpaceDataSource: Error deleting parking space: $e");
      throw Exception('Failed to delete parking space: $e');
    }
  }

  @override
  Future<ParkingSpaceModel> occupyParkingSpace(String spaceId, String vehicleId) async {
    try {
      print("ParkingSpaceDataSource: Occupying space $spaceId with vehicle $vehicleId");

      await _spacesCollection.doc(spaceId).update({'status': 'occupied', 'vehicle_id': vehicleId});

      // Return the updated space
      return getParkingSpaceById(spaceId);
    } catch (e) {
      print("ParkingSpaceDataSource: Error occupying space: $e");
      throw Exception('Failed to occupy parking space: $e');
    }
  }

  @override
  Future<ParkingSpaceModel> vacateParkingSpace(String spaceId) async {
    try {
      print("ParkingSpaceDataSource: Vacating space $spaceId");

      await _spacesCollection.doc(spaceId).update({'status': 'vacant', 'vehicle_id': null});

      // Return the updated space
      return getParkingSpaceById(spaceId);
    } catch (e) {
      print("ParkingSpaceDataSource: Error vacating space: $e");
      throw Exception('Failed to vacate parking space: $e');
    }
  }

  @override
  Stream<List<ParkingSpaceModel>> watchParkingSpaces() {
    print("ParkingSpaceDataSource: Setting up parking spaces stream");

    return _spacesCollection.snapshots().map((snapshot) {
      final spaces =
          snapshot.docs.map((doc) {
            return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("ParkingSpaceDataSource: Stream emitted ${spaces.length} spaces");
      return spaces;
    });
  }

  @override
  Future<int> getAvailableSpacesCount() async {
    try {
      print("ParkingSpaceDataSource: Getting available spaces count");

      final querySnapshot = await _spacesCollection.where('status', isEqualTo: 'vacant').get();

      final count = querySnapshot.docs.length;
      print("ParkingSpaceDataSource: Found $count available spaces");

      return count;
    } catch (e) {
      print("ParkingSpaceDataSource: Error getting available count: $e");
      throw Exception('Failed to get available spaces count: $e');
    }
  }

  @override
  Future<ParkingSpaceModel?> getSpaceByVehicleId(String vehicleId) async {
    try {
      print("ParkingSpaceDataSource: Finding space occupied by vehicle: $vehicleId");

      final querySnapshot = await _spacesCollection.where('vehicle_id', isEqualTo: vehicleId).limit(1).get();

      if (querySnapshot.docs.isEmpty) {
        print("ParkingSpaceDataSource: No space found for vehicle $vehicleId");
        return null;
      }

      final doc = querySnapshot.docs.first;
      return ParkingSpaceModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("ParkingSpaceDataSource: Error finding space by vehicle: $e");
      throw Exception('Failed to find space by vehicle: $e');
    }
  }
}
