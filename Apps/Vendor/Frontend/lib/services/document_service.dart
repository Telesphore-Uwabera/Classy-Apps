import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/document.dart';
import 'firebase_service.dart';

class DocumentService {
  static DocumentService? _instance;
  static DocumentService get instance => _instance ??= DocumentService._();
  DocumentService._();

  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;
  final FirebaseStorage _storage = FirebaseService.instance.storage;
  
  String? get _vendorId => FirebaseService.instance.auth.currentUser?.uid;

  // Fetch all documents for the current vendor
  Stream<List<Document>> getDocuments() {
    if (_vendorId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('documents')
        .where('vendorId', isEqualTo: _vendorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Document.fromMap(data);
            })
            .toList())
        .handleError((error) {
          print('Error fetching documents: $error');
          return <Document>[];
        });
  }

  // Upload document file to Firebase Storage
  Future<String> uploadDocument(File file, String fileName) async {
    if (_vendorId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      final ref = _storage
          .ref()
          .child('documents')
          .child(_vendorId!)
          .child(fileName);
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading document: $e');
      throw Exception('Failed to upload document');
    }
  }

  // Add a new document
  Future<bool> addDocument(Document document, File? file) async {
    if (_vendorId == null) {
      print('Error: User not authenticated');
      return false;
    }
    
    try {
      String fileUrl = document.fileUrl;
      
      if (file != null) {
        fileUrl = await uploadDocument(file, document.fileName);
      }

      final docRef = _firestore.collection('documents').doc();
      final newDocument = document.copyWith(
        id: docRef.id,
        vendorId: _vendorId!,
        fileUrl: fileUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await docRef.set(newDocument.toMap());
      return true;
    } catch (e) {
      print('Error adding document: $e');
      return false;
    }
  }

  // Update an existing document
  Future<bool> updateDocument(Document document, File? file) async {
    try {
      String fileUrl = document.fileUrl;
      
      if (file != null) {
        fileUrl = await uploadDocument(file, document.fileName);
      }

      await _firestore
          .collection('documents')
          .doc(document.id)
          .update(document.copyWith(
            fileUrl: fileUrl,
            updatedAt: DateTime.now(),
          ).toMap());
      return true;
    } catch (e) {
      print('Error updating document: $e');
      return false;
    }
  }

  // Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      // Get document to delete file from storage
      final doc = await _firestore.collection('documents').doc(documentId).get();
      if (doc.exists) {
        final document = Document.fromMap(doc.data()!);
        if (document.fileUrl.isNotEmpty) {
          try {
            await _storage.refFromURL(document.fileUrl).delete();
          } catch (e) {
            print('Error deleting file from storage: $e');
          }
        }
      }
      
      await _firestore.collection('documents').doc(documentId).delete();
      return true;
    } catch (e) {
      print('Error deleting document: $e');
      return false;
    }
  }

  // Get document types
  List<String> getDocumentTypes() {
    return [
      'Business License',
      'Health Permit',
      'Tax Certificate',
      'Insurance Certificate',
      'Food Safety Certificate',
      'Other',
    ];
  }

  // Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
