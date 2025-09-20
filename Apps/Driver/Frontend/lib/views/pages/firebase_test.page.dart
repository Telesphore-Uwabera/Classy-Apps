import 'package:flutter/material.dart';
import '../../services/firebase_test.service.dart';
import '../../services/firebase_backend.service.dart';
import '../../services/driver_firebase.service.dart';
import '../../services/driver_notification.service.dart';
import '../../services/driver_location.service.dart';

class FirebaseTestPage extends StatefulWidget {
  const FirebaseTestPage({Key? key}) : super(key: key);

  @override
  State<FirebaseTestPage> createState() => _FirebaseTestPageState();
}

class _FirebaseTestPageState extends State<FirebaseTestPage> {
  final FirebaseTestService _testService = FirebaseTestService();
  final FirebaseBackendService _backendService = FirebaseBackendService();
  final DriverFirebaseService _driverService = DriverFirebaseService();
  final DriverNotificationService _notificationService = DriverNotificationService();
  final DriverLocationService _locationService = DriverLocationService();

  Map<String, dynamic>? _testResults;
  bool _isRunningTests = false;
  String _statusMessage = 'Ready to run tests';

  @override
  void initState() {
    super.initState();
    _runInitialization();
  }

  Future<void> _runInitialization() async {
    setState(() {
      _statusMessage = 'Initializing Firebase services...';
    });

    try {
      await _backendService.initializeBackend();
      setState(() {
        _statusMessage = 'Firebase services initialized successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error initializing Firebase: $e';
      });
    }
  }

  Future<void> _runComprehensiveTests() async {
    setState(() {
      _isRunningTests = true;
      _statusMessage = 'Running comprehensive Firebase tests...';
    });

    try {
      final results = await _testService.runComprehensiveTests();
      setState(() {
        _testResults = results;
        _isRunningTests = false;
        _statusMessage = 'Tests completed! ${results['passed_tests']}/${results['total_tests']} passed';
      });
    } catch (e) {
      setState(() {
        _isRunningTests = false;
        _statusMessage = 'Error running tests: $e';
      });
    }
  }

  Future<void> _runQuickTest() async {
    setState(() {
      _statusMessage = 'Running quick connectivity test...';
    });

    try {
      final success = await _testService.runQuickConnectivityTest();
      setState(() {
        _statusMessage = success ? 'Quick test passed!' : 'Quick test failed';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Quick test error: $e';
      });
    }
  }

  Future<void> _testLocation() async {
    setState(() {
      _statusMessage = 'Testing location services...';
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _statusMessage = 'Location: ${position.latitude}, ${position.longitude}';
        });
      } else {
        setState(() {
          _statusMessage = 'Could not get location';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Location error: $e';
      });
    }
  }

  Future<void> _testNotification() async {
    setState(() {
      _statusMessage = 'Testing notifications...';
    });

    try {
      await _notificationService.sendTestNotification();
      setState(() {
        _statusMessage = 'Test notification sent!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Notification error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Test Dashboard'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    Text(_statusMessage),
                    SizedBox(height: 8),
                    if (_isRunningTests)
                      LinearProgressIndicator(),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Test Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _runQuickTest,
                  icon: Icon(Icons.flash_on),
                  label: Text('Quick Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isRunningTests ? null : _runComprehensiveTests,
                  icon: Icon(Icons.analytics),
                  label: Text('Full Test Suite'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _testLocation,
                  icon: Icon(Icons.location_on),
                  label: Text('Test Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _testNotification,
                  icon: Icon(Icons.notifications),
                  label: Text('Test Notification'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Test Results
            if (_testResults != null) ...[
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Results',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Overall: ${_testResults!['overall_success'] ? '✅ PASSED' : '❌ FAILED'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _testResults!['overall_success'] ? Colors.green : Colors.red,
                          ),
                        ),
                        Text('Passed: ${_testResults!['passed_tests']}/${_testResults!['total_tests']}'),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _testResults!['tests'].length,
                            itemBuilder: (context, index) {
                              final testName = _testResults!['tests'].keys.elementAt(index);
                              final testResult = _testResults!['tests'][testName];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Icon(
                                    testResult['success'] ? Icons.check_circle : Icons.error,
                                    color: testResult['success'] ? Colors.green : Colors.red,
                                  ),
                                  title: Text(testName.replaceAll('_', ' ').toUpperCase()),
                                  subtitle: Text(testResult['message']),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Backend Health Check
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend Health',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 8),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _backendService.checkBackendHealth(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (snapshot.hasData) {
                          final health = snapshot.data!;
                          return Column(
                            children: [
                              _buildHealthItem('Firestore', health['firestore']),
                              _buildHealthItem('Authentication', health['auth']),
                              _buildHealthItem('Messaging', health['messaging']),
                              _buildHealthItem('Storage', health['storage']),
                              Divider(),
                              _buildHealthItem('Overall', health['overall']),
                            ],
                          );
                        }
                        return Text('No data available');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String name, bool isHealthy) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.error,
            color: isHealthy ? Colors.green : Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(name),
          Spacer(),
          Text(
            isHealthy ? 'Healthy' : 'Unhealthy',
            style: TextStyle(
              color: isHealthy ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
