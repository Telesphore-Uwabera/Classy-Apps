import 'package:flutter/material.dart';
import 'package:Classy/services/firestore_init.service.dart';

class FirestoreDebugPage extends StatefulWidget {
  const FirestoreDebugPage({Key? key}) : super(key: key);

  @override
  State<FirestoreDebugPage> createState() => _FirestoreDebugPageState();
}

class _FirestoreDebugPageState extends State<FirestoreDebugPage> {
  List<String> collections = [];
  Map<String, int> collectionCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get available collections
      final availableCollections = await FirestoreInitService.getAvailableCollections();
      
      // Get counts for each collection
      final counts = <String, int>{};
      for (final collection in availableCollections) {
        final count = await FirestoreInitService.getCollectionCount(collection);
        counts[collection] = count;
      }

      setState(() {
        collections = availableCollections;
        collectionCounts = counts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading collections: $e')),
      );
    }
  }

  Future<void> _initializeCollections() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirestoreInitService.initializeCollections();
      await _loadCollections();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collections initialized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing collections: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCollections,
          ),
        ],
      ),
      body: Column(
        children: [
          // Initialize Collections Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _initializeCollections,
                icon: const Icon(Icons.add),
                label: const Text('Initialize Collections'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ),
          
          // Collections List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : collections.isEmpty
                    ? const Center(
                        child: Text(
                          'No collections found.\nTap "Initialize Collections" to create them.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final collection = collections[index];
                          final count = collectionCounts[collection] ?? 0;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCollectionColor(collection),
                                child: Text(
                                  collection[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                collection,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('$count documents'),
                              trailing: Icon(
                                _getCollectionIcon(collection),
                                color: _getCollectionColor(collection),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getCollectionColor(String collection) {
    switch (collection) {
      case 'users':
        return Colors.blue;
      case 'restaurants':
        return Colors.orange;
      case 'drivers':
        return Colors.green;
      case 'vendors':
        return Colors.purple;
      case 'orders':
        return Colors.red;
      case 'categories':
        return Colors.teal;
      case 'app_settings':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCollectionIcon(String collection) {
    switch (collection) {
      case 'users':
        return Icons.people;
      case 'restaurants':
        return Icons.restaurant;
      case 'drivers':
        return Icons.delivery_dining;
      case 'vendors':
        return Icons.store;
      case 'orders':
        return Icons.shopping_bag;
      case 'categories':
        return Icons.category;
      case 'app_settings':
        return Icons.settings;
      default:
        return Icons.folder;
    }
  }
}
