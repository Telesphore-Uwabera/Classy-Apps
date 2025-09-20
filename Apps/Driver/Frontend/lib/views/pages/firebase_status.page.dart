import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStatusPage extends StatefulWidget {
  const FirebaseStatusPage({Key? key}) : super(key: key);

  @override
  _FirebaseStatusPageState createState() => _FirebaseStatusPageState();
}

class _FirebaseStatusPageState extends State<FirebaseStatusPage> {
  String _status = 'Checking...';
  bool _isInitialized = false;
  String? _projectId;
  String? _appName;

  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }

  Future<void> _checkFirebaseStatus() async {
    try {
      final app = Firebase.app();
      setState(() {
        _isInitialized = true;
        _projectId = app.options.projectId;
        _appName = app.name;
        _status = 'Firebase is initialized successfully!\n\nApp Name: ${app.name}\nProject ID: ${app.options.projectId}\nAPI Key: ${app.options.apiKey.substring(0, 10)}...\nStorage Bucket: ${app.options.storageBucket}';
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _status = 'Firebase initialization failed: $e\n\nError Type: ${e.runtimeType}\n\nThis usually means:\n1. google-services.json is missing or incorrect\n2. Package name mismatch\n3. Firebase project not properly configured\n4. Network connectivity issues';
      });
    }
  }

  Future<void> _testAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      setState(() {
        _status = 'Firebase Auth is available. Current user: ${auth.currentUser?.uid ?? "None"}';
      });
    } catch (e) {
      setState(() {
        _status = 'Firebase Auth error: $e';
      });
    }
  }

  Future<void> _testRegistration() async {
    try {
      final auth = FirebaseAuth.instance;
      final testEmail = "test@classy.app";
      final testPassword = "test123456";
      
      // Try to create a test user
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      
      setState(() {
        _status = 'Test registration successful! User ID: ${userCredential.user?.uid}';
      });
      
      // Clean up - delete the test user
      await userCredential.user?.delete();
      
    } catch (e) {
      setState(() {
        _status = 'Test registration failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Status'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isInitialized ? Icons.check_circle : Icons.error,
                          color: _isInitialized ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _status,
                            style: TextStyle(
                              color: _isInitialized ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isInitialized) ...[
                      const SizedBox(height: 16),
                      Text('Project ID: $_projectId'),
                      Text('App Name: $_appName'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testAuth,
              child: const Text('Test Firebase Auth'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _testRegistration,
              child: const Text('Test Registration'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkFirebaseStatus,
              child: const Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
}
