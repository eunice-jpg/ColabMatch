import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String? toUsername;
  final String? toProjectId;
  final String? toProjectName;
  final String status;
  final String type; 
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    this.toUsername,
    this.toProjectId,
    this.toProjectName,
    required this.status,
    required this.type,
    required this.createdAt,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      fromUsername: data['fromUsername'] ?? '',
      toUserId: data['toUserId'] ?? '',
      toUsername: data['toUsername'],
      toProjectId: data['toProjectId'],
      toProjectName: data['toProjectName'],
      status: data['status'] ?? 'pending',
      type: data['type'] ?? 'join',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'toUserId': toUserId,
      'toUsername': toUsername,
      'toProjectId': toProjectId,
      'toProjectName': toProjectName,
      'status': status,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}