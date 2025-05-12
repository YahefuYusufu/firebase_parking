import 'package:firebase_parking/data/datasources/mock_data_service.dart';
import 'package:flutter/material.dart';
import '../data/models/person/person.dart';
import '../data/models/vehicles/vehicle.dart';
import '../data/models/parking_space/parking_space.dart';
import '../data/models/parking/parking.dart';

class DataProvider extends ChangeNotifier {
  final MockDataService _mockDataService = MockDataService();
  bool _initialized = false;
  bool _loading = false;

  // Cached data
  List<Person> _persons = [];
  List<Vehicle> _vehicles = [];
  List<ParkingSpace> _parkingSpaces = [];
  List<Parking> _parkingSessions = [];

  // Getters
  bool get initialized => _initialized;
  bool get loading => _loading;
  List<Person> get persons => _persons;
  List<Vehicle> get vehicles => _vehicles;

  List<ParkingSpace> get parkingSpaces => _parkingSpaces;
  List<Parking> get parkingSessions => _parkingSessions;

  // Filter getters
  List<ParkingSpace> get availableParkingSpaces => _parkingSpaces.where((space) => space.status == 'vacant').toList();

  List<Parking> get activeParkingSessions => _parkingSessions.where((session) => session.isActive).toList();

  // Check if a vehicle is currently parked
  bool isVehicleParked(String vehicleId) {
    // Look for an active parking session for this vehicle
    try {
      return _parkingSessions.any((session) => session.isActive && session.vehicle.id == vehicleId);
    } catch (e) {
      return false;
    }
  }

  // Get active parking session for a vehicle (if any)
  Parking? getActiveParking(String vehicleId) {
    try {
      return _parkingSessions.firstWhere((session) => session.isActive && session.vehicle.id == vehicleId);
    } catch (e) {
      return null;
    }
  }

  // Initialize data
  Future<void> initialize() async {
    if (_initialized) return;

    _setLoading(true);

    // Initialize mock data
    _mockDataService.init();

    // Load all data
    await _refreshAll();

    _initialized = true;
    _setLoading(false);
  }

  // Refresh all data
  Future<void> _refreshAll() async {
    await Future.wait([refreshPersons(), refreshVehicles(), refreshParkingSpaces(), refreshParkingSessions()]);
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  // Person operations
  Future<void> refreshPersons() async {
    _persons = await _mockDataService.getPersons();
    notifyListeners();
  }

  Future<Person?> getPerson(String id) async {
    return await _mockDataService.getPerson(id);
  }

  Future<Person> createPerson(Person person) async {
    _setLoading(true);
    final newPerson = await _mockDataService.createPerson(person);
    await refreshPersons();
    _setLoading(false);
    return newPerson;
  }

  Future<Person> updatePerson(Person person) async {
    _setLoading(true);
    final updatedPerson = await _mockDataService.updatePerson(person);
    await refreshPersons();
    _setLoading(false);
    return updatedPerson;
  }

  Future<void> deletePerson(String id) async {
    _setLoading(true);
    await _mockDataService.deletePerson(id);
    await refreshPersons();
    _setLoading(false);
  }

  // Vehicle operations
  Future<void> refreshVehicles() async {
    _vehicles = await _mockDataService.getVehicles();
    notifyListeners();
  }

  Future<List<Vehicle>> getVehiclesByOwner(String ownerId) async {
    return await _mockDataService.getVehiclesByOwner(ownerId);
  }

  Future<Vehicle?> getVehicle(String id) async {
    return await _mockDataService.getVehicle(id);
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    _setLoading(true);
    final newVehicle = await _mockDataService.createVehicle(vehicle);
    await refreshVehicles();
    _setLoading(false);
    return newVehicle;
  }

  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    _setLoading(true);
    final updatedVehicle = await _mockDataService.updateVehicle(vehicle);
    await refreshVehicles();
    _setLoading(false);
    return updatedVehicle;
  }

  Future<void> deleteVehicle(String id) async {
    _setLoading(true);
    await _mockDataService.deleteVehicle(id);
    await refreshVehicles();
    _setLoading(false);
  }

  // Parking Space operations
  Future<void> refreshParkingSpaces() async {
    _parkingSpaces = await _mockDataService.getParkingSpaces();
    notifyListeners();
  }

  Future<ParkingSpace?> getParkingSpace(String id) async {
    return await _mockDataService.getParkingSpace(id);
  }

  Future<ParkingSpace> createParkingSpace(ParkingSpace space) async {
    _setLoading(true);
    final newSpace = await _mockDataService.createParkingSpace(space);
    await refreshParkingSpaces();
    _setLoading(false);
    return newSpace;
  }

  Future<ParkingSpace> updateParkingSpace(ParkingSpace space) async {
    _setLoading(true);
    final updatedSpace = await _mockDataService.updateParkingSpace(space);
    await refreshParkingSpaces();
    _setLoading(false);
    return updatedSpace;
  }

  Future<void> deleteParkingSpace(String id) async {
    _setLoading(true);
    await _mockDataService.deleteParkingSpace(id);
    await refreshParkingSpaces();
    _setLoading(false);
  }

  // Parking Session operations
  Future<void> refreshParkingSessions() async {
    _parkingSessions = await _mockDataService.getParkingSessions();
    notifyListeners();
  }

  Future<Parking?> getParkingSession(String id) async {
    return await _mockDataService.getParkingSession(id);
  }

  Future<Parking> createParkingSession(Vehicle vehicle, ParkingSpace space) async {
    _setLoading(true);
    final newSession = await _mockDataService.createParkingSession(vehicle, space);

    // Refresh both parking spaces and sessions since both are affected
    await refreshParkingSpaces();
    await refreshParkingSessions();

    _setLoading(false);
    return newSession;
  }

  Future<Parking> endParkingSession(String id) async {
    _setLoading(true);
    final completedSession = await _mockDataService.endParkingSession(id);

    // Refresh both parking spaces and sessions since both are affected
    await refreshParkingSpaces();
    await refreshParkingSessions();

    _setLoading(false);
    return completedSession;
  }
}
