import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<UserModel?> authStateChanges();
  UserModel? getCurrentUser();
  Future<UserModel> updateUserProfile(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to get user data from Firestore
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    final docSnapshot = await _firestore.collection('users').doc(uid).get();
    return docSnapshot.exists ? docSnapshot.data() : null;
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

    final userData = await _getUserData(userCredential.user!.uid);
    return UserModel.fromFirebaseUserWithData(userCredential.user!, userData);
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(String email, String password) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

    // Create initial user document in Firestore
    final user = UserModel.fromFirebaseUser(userCredential.user!);
    await _firestore.collection('users').doc(user.id).set({
      'email': email,
      // Don't set name or personalNumber yet - these will be set during profile completion
    });

    return user;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      final userData = await _getUserData(firebaseUser.uid);
      return UserModel.fromFirebaseUserWithData(firebaseUser, userData);
    });
  }

  @override
  UserModel? getCurrentUser() {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    // Note: This returns only the basic user data from Firebase Auth
    // For complete profile data, use a separate method that fetches from Firestore
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    if (user.id == null) throw Exception('User ID cannot be null');

    // Update Firestore document
    await _firestore.collection('users').doc(user.id).set(user.toJson(), SetOptions(merge: true));

    // Get updated user data
    final userData = await _getUserData(user.id!);
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      throw Exception('Not authenticated');
    }

    return UserModel.fromFirebaseUserWithData(firebaseUser, userData);
  }
}
