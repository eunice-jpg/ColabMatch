import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String name;
  final String description;
  final String hackathon;
  final String ownerId;
  final String ownerName;
  final List<String> existingSkills;
  final List<String> lackingSkills; // renamed
  final DateTime createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    required this.hackathon,
    required this.ownerId,
    required this.ownerName,
    required this.existingSkills,
    required this.lackingSkills, // renamed
    required this.createdAt,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      hackathon: data['hackathon'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      existingSkills: List<String>.from(data['existingSkills'] ?? []),
      lackingSkills: List<String>.from(data['lackingSkills'] ?? []), // renamed
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'hackathon': hackathon,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'existingSkills': existingSkills,
      'lackingSkills': lackingSkills, // renamed
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
