import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String? toProjectId; // nullable
  final String? toProjectName; // nullable
  final String status;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    this.toProjectId,
    this.toProjectName,
    required this.status,
    required this.createdAt,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUsername: data['fromUsername'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toProjectId: data['toProjectId'], // can be null
      toProjectName: data['toProjectName'], // can be null
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'toUserId': toUserId,
      'toProjectId': toProjectId,
      'toProjectName': toProjectName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
