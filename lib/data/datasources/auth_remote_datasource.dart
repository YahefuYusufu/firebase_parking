// lib/data/datasources/auth_remote_datasource.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<UserModel?> authStateChanges();
  UserModel? getCurrentUser();
  Future<UserModel> getUserProfile(String userId);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<UserModel> updateProfilePicture(String userId, String filePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Helper method to get user data from Firestore
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      print("DataSource: Fetching user data from Firestore for UID: $uid");
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      print("DataSource: Firestore document exists: ${docSnapshot.exists}");
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print("DataSource: Firestore data: $data");

        // Check for completeness of required fields
        final hasName = data?['name'] != null && data!['name'].toString().isNotEmpty;
        final hasPersonalNumber = data?['personal_number'] != null && data!['personal_number'].toString().isNotEmpty;
        print("DataSource: Profile data check - hasName: $hasName, hasPersonalNumber: $hasPersonalNumber");

        return data;
      } else {
        print("DataSource: No Firestore document exists for this user");
        return null;
      }
    } catch (e) {
      print("DataSource: Error getting user data from Firestore: $e");
      return null;
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    print("DataSource: Signing in with email: $email");
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    print("DataSource: Firebase Auth sign-in successful for user: ${userCredential.user?.uid}");

    // Important: Always fetch the user data from Firestore after login
    final userData = await _getUserData(userCredential.user!.uid);

    if (userData == null) {
      print("DataSource: No Firestore profile exists, creating basic profile");
      // If no Firestore document exists yet, create one with basic info
      final basicUserData = {'id': userCredential.user!.uid, 'email': email, 'created_at': FieldValue.serverTimestamp()};

      await _firestore.collection('users').doc(userCredential.user!.uid).set(basicUserData, SetOptions(merge: true));
      print("DataSource: Basic profile created in Firestore");

      return UserModel.fromFirebaseUserWithData(userCredential.user!, basicUserData);
    }

    print("DataSource: Returning user model with Firestore data");
    return UserModel.fromFirebaseUserWithData(userCredential.user!, userData);
  }

  @override
  Future<UserModel> createUserWithEmailAndPassword(String email, String password) async {
    print("DataSource: Creating new user with email: $email");
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    print("DataSource: Firebase Auth account created for user: ${userCredential.user?.uid}");

    // Create initial user document in Firestore
    final initialUserData = {'id': userCredential.user!.uid, 'email': email, 'created_at': FieldValue.serverTimestamp()};

    await _firestore.collection('users').doc(userCredential.user!.uid).set(initialUserData);
    print("DataSource: Initial Firestore document created for user");

    return UserModel.fromFirebaseUserWithData(userCredential.user!, initialUserData);
  }

  @override
  Future<void> signOut() async {
    print("DataSource: Signing out current user");
    await _firebaseAuth.signOut();
    print("DataSource: User signed out successfully");
  }

  @override
  Stream<UserModel?> authStateChanges() {
    print("DataSource: Setting up auth state changes stream");
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        print("DataSource: Auth state changed - User is now signed out");
        return null;
      }

      print("DataSource: Auth state changed - User is signed in: ${firebaseUser.uid}");
      final userData = await _getUserData(firebaseUser.uid);
      final userModel = UserModel.fromFirebaseUserWithData(firebaseUser, userData);
      print("DataSource: Auth state user model: $userModel");
      return userModel;
    });
  }

  @override
  UserModel? getCurrentUser() {
    try {
      print("DataSource: Getting current user (synchronous call)");
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        print("DataSource: No current user found");
        return null;
      }

      print("DataSource: Current Firebase Auth user: ${firebaseUser.uid}");

      // Create a very basic UserModel - importantly, we need to attempt to include
      // name and personalNumber if possible

      // First check if we have custom claims with this info (faster than Firestore)
      String? name = firebaseUser.displayName;
      String? personalNumber;

      // Try to get values from token result if available
      try {
        final tokenResult = firebaseUser.getIdTokenResult(true);
        final claims = tokenResult.then((result) => result.claims);
        // ignore: unnecessary_null_comparison
        if (claims != null) {
          // This approach is async, but we're in a sync method so we can't use it properly
          // This is just for debugging purposes
          print("DataSource: Will try to get claims in future");
        }
      } catch (e) {
        print("DataSource: Failed to get token claims: $e");
      }

      // In a better world, we'd be able to use an async getCurrentUser method...
      // but to maintain compatibility with your existing code structure, we'll
      // return what we have now

      final userModel = UserModel(id: firebaseUser.uid, email: firebaseUser.email, isEmailVerified: firebaseUser.emailVerified, name: name, personalNumber: personalNumber);

      print("DataSource: Returning basic user model: $userModel");
      print("DataSource: IMPORTANT - This model may be missing profile data from Firestore");
      print("DataSource: Use getUserProfile for complete data if needed");

      return userModel;
    } catch (e) {
      print("DataSource: Error in getCurrentUser: $e");
      return null;
    }
  }

  @override
  Future<UserModel> getUserProfile(String userId) async {
    print("DataSource: Getting full user profile for ID: $userId");

    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null || firebaseUser.uid != userId) {
      print("DataSource: User not authenticated or ID mismatch");
      throw Exception('User not authenticated or ID mismatch');
    }

    final userData = await _getUserData(userId);
    print("DataSource: Got Firestore data for user profile");

    final userModel = UserModel.fromFirebaseUserWithData(firebaseUser, userData);
    print("DataSource: Created user model with complete profile: $userModel");

    return userModel;
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    if (user.id == null) {
      print("DataSource: Cannot update profile - User ID is null");
      throw Exception('User ID cannot be null');
    }

    print("DataSource: Updating user profile for ID: ${user.id}");
    print("DataSource: Profile data - name: ${user.name}, personalNumber: ${user.personalNumber}");

    // Update Firestore document
    await _firestore.collection('users').doc(user.id).set({
      'id': user.id,
      'email': user.email,
      'name': user.name,
      'personal_number': user.personalNumber,
      'vehicle_ids': user.vehicleIds,
      'profile_picture_url': user.profilePictureUrl,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("DataSource: Firestore document updated successfully");

    // Get updated user data
    final userData = await _getUserData(user.id!);
    print("DataSource: Retrieved updated user data from Firestore");

    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) {
      print("DataSource: Cannot retrieve Firebase Auth user - not authenticated");
      throw Exception('Not authenticated');
    }

    final updatedUserModel = UserModel.fromFirebaseUserWithData(firebaseUser, userData);
    print("DataSource: Returning updated user model: $updatedUserModel");

    return updatedUserModel;
  }

  @override
  Future<UserModel> updateProfilePicture(String userId, String filePath) async {
    print("DataSource: Updating profile picture for user: $userId");
    print("DataSource: Using image file at: $filePath");

    // Create a reference to the file location in Firebase Storage
    final storageRef = _storage.ref().child('profile_pictures').child('$userId.jpg');
    print("DataSource: Storage reference created");

    // Upload the file
    final File file = File(filePath);
    final uploadTask = storageRef.putFile(file);
    print("DataSource: Starting file upload");

    // Wait for the upload to complete
    final snapshot = await uploadTask;
    print("DataSource: File upload completed: ${snapshot.bytesTransferred} bytes");

    // Get the download URL
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print("DataSource: Got download URL: $downloadUrl");

    // Update user document in Firestore with the new profile picture URL
    await _firestore.collection('users').doc(userId).update({'profile_picture_url': downloadUrl, 'updated_at': FieldValue.serverTimestamp()});
    print("DataSource: Updated Firestore document with new picture URL");

    // Get updated user data
    final userData = await _getUserData(userId);
    final firebaseUser = _firebaseAuth.currentUser;

    if (firebaseUser == null) {
      print("DataSource: Cannot get current user - not authenticated");
      throw Exception('Not authenticated');
    }

    final updatedUserModel = UserModel.fromFirebaseUserWithData(firebaseUser, userData);
    print("DataSource: Returning updated user model with profile picture: $updatedUserModel");

    return updatedUserModel;
  }
}
