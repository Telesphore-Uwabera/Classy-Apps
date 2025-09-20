import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String vendorId;
  final String name;
  final String type; // e.g., 'business_license', 'permit', 'certificate'
  final String description;
  final String fileUrl;
  final String fileName;
  final int fileSize;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.type,
    required this.description,
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.status,
    this.rejectionReason,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] ?? '',
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      fileName: map['fileName'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      expiryDate: map['expiryDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'name': name,
      'type': type,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'status': status,
      'rejectionReason': rejectionReason,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  Document copyWith({
    String? id,
    String? vendorId,
    String? name,
    String? type,
    String? description,
    String? fileUrl,
    String? fileName,
    int? fileSize,
    String? status,
    String? rejectionReason,
    DateTime? expiryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
