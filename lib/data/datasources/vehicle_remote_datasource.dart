// lib/data/datasources/vehicle_remote_datasource.dart
// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_parking/data/models/vehicles/vehicle_model.dart';

abstract class VehicleRemoteDataSource {
  Future<VehicleModel> addVehicle(VehicleModel vehicle);
  Future<List<VehicleModel>> getUserVehicles(String userId);
  Future<VehicleModel> getVehicleById(String vehicleId);
  Future<VehicleModel> updateVehicle(VehicleModel vehicle);
  Future<void> deleteVehicle(String vehicleId);
  Future<bool> checkRegistrationExists(String registrationNumber);
  Future<List<VehicleModel>> searchVehiclesByRegistration(String query);
  Stream<List<VehicleModel>> watchUserVehicles(String userId);
}

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final FirebaseFirestore firestore;

  VehicleRemoteDataSourceImpl({required this.firestore});

  // Collection reference
  CollectionReference get _vehiclesCollection => firestore.collection('vehicles');

  @override
  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    try {
      print("VehicleDataSource: Adding new vehicle: ${vehicle.registrationNumber}");

      // Add to Firestore
      final docRef = await _vehiclesCollection.add(vehicle.toFirestore());

      // Return the vehicle with the generated ID
      final newVehicle = vehicle.copyWith(id: docRef.id);
      print("VehicleDataSource: Vehicle added with ID: ${docRef.id}");

      return newVehicle;
    } catch (e) {
      print("VehicleDataSource: Error adding vehicle: $e");
      throw Exception('Failed to add vehicle: $e');
    }
  }

  @override
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    try {
      print("VehicleDataSource: Fetching vehicles for user: $userId");

      final querySnapshot = await _vehiclesCollection.where('owner_id', isEqualTo: userId).get();

      final vehicles =
          querySnapshot.docs.map((doc) {
            return VehicleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("VehicleDataSource: Found ${vehicles.length} vehicles");
      return vehicles;
    } catch (e) {
      print("VehicleDataSource: Error fetching user vehicles: $e");
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  @override
  Future<VehicleModel> getVehicleById(String vehicleId) async {
    try {
      print("VehicleDataSource: Fetching vehicle with ID: $vehicleId");

      final doc = await _vehiclesCollection.doc(vehicleId).get();

      if (!doc.exists) {
        throw Exception('Vehicle not found');
      }

      return VehicleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print("VehicleDataSource: Error fetching vehicle: $e");
      throw Exception('Failed to fetch vehicle: $e');
    }
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    try {
      print("VehicleDataSource: Updating vehicle: ${vehicle.id}");

      if (vehicle.id == null) {
        throw Exception('Vehicle ID is required for update');
      }

      await _vehiclesCollection.doc(vehicle.id).update(vehicle.toFirestore());

      print("VehicleDataSource: Vehicle updated successfully");
      return vehicle;
    } catch (e) {
      print("VehicleDataSource: Error updating vehicle: $e");
      throw Exception('Failed to update vehicle: $e');
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      print("VehicleDataSource: Deleting vehicle: $vehicleId");

      await _vehiclesCollection.doc(vehicleId).delete();

      print("VehicleDataSource: Vehicle deleted successfully");
    } catch (e) {
      print("VehicleDataSource: Error deleting vehicle: $e");
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  @override
  Future<bool> checkRegistrationExists(String registrationNumber) async {
    try {
      print("VehicleDataSource: Checking if registration exists: $registrationNumber");

      final querySnapshot = await _vehiclesCollection.where('registration_number', isEqualTo: registrationNumber.toUpperCase()).limit(1).get();

      final exists = querySnapshot.docs.isNotEmpty;
      print("VehicleDataSource: Registration exists: $exists");

      return exists;
    } catch (e) {
      print("VehicleDataSource: Error checking registration: $e");
      throw Exception('Failed to check registration: $e');
    }
  }

  @override
  Future<List<VehicleModel>> searchVehiclesByRegistration(String query) async {
    try {
      print("VehicleDataSource: Searching vehicles with query: $query");

      // For simple prefix matching
      final queryUpper = query.toUpperCase();
      // ignore: unused_local_variable
      final queryLower = query.toLowerCase();

      final querySnapshot =
          // ignore: prefer_interpolation_to_compose_strings
          await _vehiclesCollection.where('registration_number', isGreaterThanOrEqualTo: queryUpper).where('registration_number', isLessThan: queryUpper + 'z').get();

      final vehicles =
          querySnapshot.docs.map((doc) {
            return VehicleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("VehicleDataSource: Found ${vehicles.length} vehicles matching search");
      return vehicles;
    } catch (e) {
      print("VehicleDataSource: Error searching vehicles: $e");
      throw Exception('Failed to search vehicles: $e');
    }
  }

  @override
  Stream<List<VehicleModel>> watchUserVehicles(String userId) {
    print("VehicleDataSource: Setting up vehicle stream for user: $userId");

    return _vehiclesCollection.where('owner_id', isEqualTo: userId).snapshots().map((snapshot) {
      final vehicles =
          snapshot.docs.map((doc) {
            return VehicleModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

      print("VehicleDataSource: Stream emitted ${vehicles.length} vehicles");
      return vehicles;
    });
  }
}
