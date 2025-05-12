import 'package:firebase_parking/data/models/parking/parking.dart';
import 'package:firebase_parking/data/models/parking_space/parking_space.dart';
import 'package:firebase_parking/data/models/person/person.dart';
import 'package:firebase_parking/data/models/vehicles/vehicle.dart';

class MockDataService {
  // Singleton pattern
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  // Mock data collections
  final List<Person> _persons = [];
  final List<Vehicle> _vehicles = [];
  final List<ParkingSpace> _parkingSpaces = [];
  final List<Parking> _parkingSessions = [];

  // Initialize with sample data
  void init() {
    if (_persons.isNotEmpty) return; // Already initialized

    _initPersons();
    _initVehicles();
    _initParkingSpaces();
    _initParkingSessions();
  }

  // Initialize sample persons
  void _initPersons() {
    _persons.addAll([
      Person(id: '1', name: 'John Doe', personalNumber: '19850512-1234'),
      Person(id: '2', name: 'Jane Smith', personalNumber: '19900623-5678'),
      Person(id: '3', name: 'Alex Johnson', personalNumber: '19780304-9012'),
    ]);
  }

  // Initialize sample vehicles
  void _initVehicles() {
    _vehicles.addAll([
      Vehicle(id: '1', registrationNumber: 'ABC123', type: 'Sedan', ownerId: '1', owner: _persons.firstWhere((p) => p.id == '1')),
      Vehicle(id: '2', registrationNumber: 'XYZ789', type: 'SUV', ownerId: '2', owner: _persons.firstWhere((p) => p.id == '2')),
      Vehicle(id: '3', registrationNumber: 'DEF456', type: 'Hatchback', ownerId: '1', owner: _persons.firstWhere((p) => p.id == '1')),
      Vehicle(id: '4', registrationNumber: 'GHI789', type: 'Electric', ownerId: '3', owner: _persons.firstWhere((p) => p.id == '3')),
    ]);
  }

  // Initialize sample parking spaces
  void _initParkingSpaces() {
    _parkingSpaces.addAll([
      ParkingSpace(id: '1', spaceNumber: 'A12', type: 'regular', status: 'occupied', level: '1', section: 'A', hourlyRate: 15.0, occupiedBy: _vehicles[0]),
      ParkingSpace(id: '2', spaceNumber: 'B05', type: 'compact', status: 'vacant', level: '1', section: 'B', hourlyRate: 12.5),
      ParkingSpace(id: '3', spaceNumber: 'C22', type: 'handicapped', status: 'vacant', level: '2', section: 'C', hourlyRate: 10.0),
      ParkingSpace(id: '4', spaceNumber: 'A08', type: 'regular', status: 'vacant', level: '1', section: 'A', hourlyRate: 15.0),
    ]);
  }

  // Initialize sample parking sessions
  void _initParkingSessions() {
    final now = DateTime.now();

    _parkingSessions.addAll([
      Parking(id: '1', vehicle: _vehicles[0], parkingSpace: _parkingSpaces[0], startedAt: now.subtract(const Duration(hours: 2))),
      Parking(
        id: '2',
        vehicle: _vehicles[1],
        parkingSpace: _parkingSpaces[2],
        startedAt: now.subtract(const Duration(days: 1, hours: 3)),
        finishedAt: now.subtract(const Duration(days: 1, hours: 1)),
      ),
    ]);
  }

  // Getters for each collection
  List<Person> get persons => List.unmodifiable(_persons);
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<ParkingSpace> get parkingSpaces => List.unmodifiable(_parkingSpaces);
  List<Parking> get parkingSessions => List.unmodifiable(_parkingSessions);

  // CRUD operations for Person
  Future<List<Person>> getPersons() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return _persons;
  }

  Future<Person?> getPerson(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // ignore: cast_from_null_always_fails
    return _persons.firstWhere((person) => person.id == id, orElse: () => null as Person);
  }

  Future<Person> createPerson(Person person) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = (int.parse(_persons.last.id ?? '0') + 1).toString();
    final newPerson = Person(id: id, name: person.name, personalNumber: person.personalNumber);
    _persons.add(newPerson);
    return newPerson;
  }

  Future<Person> updatePerson(Person person) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _persons.indexWhere((p) => p.id == person.id);
    if (index != -1) {
      _persons[index] = person;
      return person;
    }
    throw Exception('Person not found');
  }

  Future<void> deletePerson(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _persons.removeWhere((person) => person.id == id);
  }

  // CRUD operations for Vehicle
  Future<List<Vehicle>> getVehicles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vehicles;
  }

  Future<List<Vehicle>> getVehiclesByOwner(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _vehicles.where((vehicle) => vehicle.ownerId == ownerId).toList();
  }

  Future<Vehicle?> getVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // ignore: cast_from_null_always_fails
    return _vehicles.firstWhere((vehicle) => vehicle.id == id, orElse: () => null as Vehicle);
  }

  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = (int.parse(_vehicles.last.id ?? '0') + 1).toString();
    final newVehicle = Vehicle(
      id: id,
      registrationNumber: vehicle.registrationNumber,
      type: vehicle.type,
      ownerId: vehicle.ownerId,
      owner: vehicle.owner ?? await getPerson(vehicle.ownerId),
    );
    _vehicles.add(newVehicle);
    return newVehicle;
  }

  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      return vehicle;
    }
    throw Exception('Vehicle not found');
  }

  Future<void> deleteVehicle(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _vehicles.removeWhere((vehicle) => vehicle.id == id);
  }

  // CRUD operations for ParkingSpace
  Future<List<ParkingSpace>> getParkingSpaces() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _parkingSpaces;
  }

  Future<List<ParkingSpace>> getAvailableParkingSpaces() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _parkingSpaces.where((space) => space.status == 'vacant').toList();
  }

  Future<ParkingSpace?> getParkingSpace(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // ignore: cast_from_null_always_fails
    return _parkingSpaces.firstWhere((space) => space.id == id, orElse: () => null as ParkingSpace);
  }

  Future<ParkingSpace> createParkingSpace(ParkingSpace space) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = (int.parse(_parkingSpaces.last.id ?? '0') + 1).toString();
    final newSpace = ParkingSpace(
      id: id,
      spaceNumber: space.spaceNumber,
      type: space.type,
      status: space.status,
      level: space.level,
      section: space.section,
      hourlyRate: space.hourlyRate,
    );
    _parkingSpaces.add(newSpace);
    return newSpace;
  }

  Future<ParkingSpace> updateParkingSpace(ParkingSpace space) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _parkingSpaces.indexWhere((s) => s.id == space.id);
    if (index != -1) {
      _parkingSpaces[index] = space;
      return space;
    }
    throw Exception('Parking space not found');
  }

  Future<void> deleteParkingSpace(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _parkingSpaces.removeWhere((space) => space.id == id);
  }

  // CRUD operations for Parking
  Future<List<Parking>> getParkingSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _parkingSessions;
  }

  Future<List<Parking>> getActiveParkingSessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _parkingSessions.where((session) => session.isActive).toList();
  }

  Future<Parking?> getParkingSession(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // ignore: cast_from_null_always_fails
    return _parkingSessions.firstWhere((session) => session.id == id, orElse: () => null as Parking);
  }

  Future<Parking> createParkingSession(Vehicle vehicle, ParkingSpace space) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Update parking space status
    final spaceIndex = _parkingSpaces.indexWhere((s) => s.id == space.id);
    if (spaceIndex != -1) {
      _parkingSpaces[spaceIndex] = ParkingSpace(
        id: space.id,
        spaceNumber: space.spaceNumber,
        type: space.type,
        status: 'occupied',
        level: space.level,
        section: space.section,
        hourlyRate: space.hourlyRate,
        occupiedBy: vehicle,
      );
    }

    final id = (int.parse(_parkingSessions.last.id ?? '0') + 1).toString();
    final newSession = Parking(id: id, vehicle: vehicle, parkingSpace: _parkingSpaces[spaceIndex], startedAt: DateTime.now());

    _parkingSessions.add(newSession);
    return newSession;
  }

  Future<Parking> endParkingSession(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _parkingSessions.indexWhere((session) => session.id == id);
    if (index != -1) {
      final session = _parkingSessions[index];

      // Create completed session
      final completedSession = Parking(id: session.id, vehicle: session.vehicle, parkingSpace: session.parkingSpace, startedAt: session.startedAt, finishedAt: DateTime.now());

      // Update the session
      _parkingSessions[index] = completedSession;

      // Update parking space status
      final spaceIndex = _parkingSpaces.indexWhere((s) => s.id == session.parkingSpace.id);
      if (spaceIndex != -1) {
        _parkingSpaces[spaceIndex] = ParkingSpace(
          id: session.parkingSpace.id,
          spaceNumber: session.parkingSpace.spaceNumber,
          type: session.parkingSpace.type,
          status: 'vacant',
          level: session.parkingSpace.level,
          section: session.parkingSpace.section,
          hourlyRate: session.parkingSpace.hourlyRate,
        );
      }

      return completedSession;
    }

    throw Exception('Parking session not found');
  }
}
