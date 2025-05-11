import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseTest extends StatefulWidget {
  const FirebaseTest({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FirebaseTestState createState() => _FirebaseTestState();
}

class _FirebaseTestState extends State<FirebaseTest> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = 'Firebase Test';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _testAuthentication, child: Text('Test Authentication')),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _testFirestore, child: Text('Test Firestore')),
            SizedBox(height: 20),
            _isLoading ? CircularProgressIndicator() : Text(_message, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Test Firebase Authentication
  Future<void> _testAuthentication() async {
    setState(() {
      _isLoading = true;
      _message = 'Testing Authentication...';
    });

    try {
      // Test sign up
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);

      setState(() {
        _message = 'Authentication succeeded! User ID: ${credential.user?.uid}';
      });
    } catch (e) {
      // If user already exists, try to sign in
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);

        setState(() {
          _message = 'Sign in succeeded! User ID: ${credential.user?.uid}';
        });
      } catch (e) {
        setState(() {
          _message = 'Authentication error: ${e.toString()}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Test Firestore using your models
  Future<void> _testFirestore() async {
    setState(() {
      _isLoading = true;
      _message = 'Testing Firestore...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _message = 'Please sign in first';
          _isLoading = false;
        });
        return;
      }

      // Create a test person
      final personData = {'name': 'Test User', 'personal_number': '12345678', 'email': user.email, 'vehicle_ids': []};

      // Save to Firestore
      final personRef = await FirebaseFirestore.instance.collection('persons').add(personData);

      // Create a test vehicle
      final vehicleData = {'registration_number': 'TEST123', 'make': 'Test Make', 'model': 'Test Model', 'owner_id': personRef.id};

      // Save to Firestore
      final vehicleRef = await FirebaseFirestore.instance.collection('vehicles').add(vehicleData);

      // Update person with vehicle ID
      await personRef.update({
        'vehicle_ids': FieldValue.arrayUnion([vehicleRef.id]),
      });

      setState(() {
        _message = 'Firestore test succeeded!\nCreated Person ID: ${personRef.id}\nCreated Vehicle ID: ${vehicleRef.id}';
      });
    } catch (e) {
      setState(() {
        _message = 'Firestore error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
