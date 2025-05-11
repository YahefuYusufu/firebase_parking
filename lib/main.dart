// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import
import 'package:firebase_parking/firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print("Firebase initialized successfully");
  } catch (e) {
    print("Failed to initialize Firebase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Firebase Auth Test', theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true), home: const AuthTestPage());
  }
}

class AuthTestPage extends StatefulWidget {
  const AuthTestPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthTestPageState createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add Firestore instance
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _noteController = TextEditingController(); // For Firestore test

  String _statusMessage = '';
  bool _isLoading = false;
  User? _currentUser;
  List<String> _userNotes = []; // For storing notes from Firestore

  @override
  void initState() {
    super.initState();

    // Add debug info
    print("Firebase Auth instance: ${FirebaseAuth.instance}");
    print("Firebase app name: ${Firebase.app().name}");

    // Check if user is already signed in
    _currentUser = _auth.currentUser;
    print("Current user: $_currentUser");

    // Listen for auth state changes
    try {
      _auth.authStateChanges().listen(
        (User? user) {
          print("Auth state changed: $user");
          setState(() {
            _currentUser = user;
          });

          // If user is signed in, fetch their notes
          if (user != null) {
            _fetchUserNotes();
          } else {
            // Clear notes when signed out
            setState(() {
              _userNotes = [];
            });
          }
        },
        onError: (error) {
          print("Auth state listener error: $error");
        },
      );
    } catch (e) {
      print("Failed to set up auth state listener: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Test Firebase connection
  Future<void> _testFirebase() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Firebase connection...';
    });

    try {
      // Test Firebase Core
      final apps = Firebase.apps;
      print("Firebase apps: $apps");

      // Test Auth
      // ignore: unnecessary_null_comparison
      final authTest = FirebaseAuth.instance != null;
      print("Auth available: $authTest");

      // Test Firestore
      // ignore: unnecessary_null_comparison
      final firestoreTest = FirebaseFirestore.instance != null;
      print("Firestore available: $firestoreTest");

      // Try to read a simple document to verify Firestore connection
      try {
        final testDoc = await FirebaseFirestore.instance.collection('test').doc('connection_test').get();
        print("Firestore test read: ${testDoc.exists ? 'success' : 'document not found, but connection works'}");
      } catch (e) {
        print("Firestore read test error: $e");
      }

      setState(() {
        _statusMessage = 'Firebase connection test successful!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Firebase test failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign up with email and password
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);

      setState(() {
        _statusMessage = 'Sign up successful! User ID: ${userCredential.user?.uid}';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = 'Sign up failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign up failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign in with email and password
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);

      setState(() {
        _statusMessage = 'Sign in successful! User ID: ${userCredential.user?.uid}';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _statusMessage = 'Sign in failed: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign in failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sign out
  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
      _statusMessage = '';
    });

    try {
      await _auth.signOut();
      setState(() {
        _statusMessage = 'Signed out successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Sign out failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // FIRESTORE FUNCTIONS

  // Fetch user notes from Firestore
  Future<void> _fetchUserNotes() async {
    if (_currentUser == null) return;

    try {
      final snapshot = await _firestore.collection('users').doc(_currentUser!.uid).collection('notes').orderBy('timestamp', descending: true).get();

      setState(() {
        _userNotes = snapshot.docs.map((doc) => doc.data()['content'] as String).toList();
      });
    } catch (e) {
      print("Error fetching notes: $e");
    }
  }

  // Add a note to Firestore
  Future<void> _addNote() async {
    if (_currentUser == null || _noteController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Adding note...';
    });

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).collection('notes').add({'content': _noteController.text.trim(), 'timestamp': FieldValue.serverTimestamp()});

      // Clear the note input
      _noteController.clear();

      // Refresh notes
      await _fetchUserNotes();

      setState(() {
        _statusMessage = 'Note added successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to add note: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Auth & Firestore Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Test Firebase button
              ElevatedButton(
                onPressed: _isLoading ? null : _testFirebase,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: const Text('Test Firebase Connection'),
              ),
              const SizedBox(height: 16),

              // Current user status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('User Status', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(_currentUser != null ? 'Signed in as: ${_currentUser!.email}' : 'Not signed in', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Authentication form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Authentication', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()), obscureText: true),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _signUp, child: const Text('Sign Up'))),
                          const SizedBox(width: 8),
                          Expanded(child: ElevatedButton(onPressed: _isLoading ? null : _signIn, child: const Text('Sign In'))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _isLoading || _currentUser == null ? null : _signOut,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade300),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Firestore (Note-taking) section - only shown when user is logged in
              if (_currentUser != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Firestore Test: Notes', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Add a new note', border: OutlineInputBorder()), maxLines: 3),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _isLoading ? null : _addNote, child: const Text('Save Note')),
                        const SizedBox(height: 16),
                        const Text('Your Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _userNotes.isEmpty
                            ? const Text('No notes yet. Add your first note above.')
                            : Column(
                              children:
                                  _userNotes
                                      .map((note) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12.0), child: Text(note))))
                                      .toList(),
                            ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Status message
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_statusMessage.isNotEmpty)
                Card(
                  color: _statusMessage.contains('failed') || _statusMessage.contains('Failed') ? Colors.red.shade100 : Colors.green.shade100,
                  child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_statusMessage, style: Theme.of(context).textTheme.bodyMedium)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
