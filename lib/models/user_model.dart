import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String username;
  final String contact;
  final String hackathon;
  final String experienceLevel;
  final List<String> skills;
  final List<String> interests;
  final String bio;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.contact,
    required this.hackathon,
    required this.experienceLevel,
    required this.skills,
    required this.interests,
    required this.bio,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      username: data['username'] ?? '',
      contact: data['contact'] ?? '',
      hackathon: data['hackathon'] ?? '',
      experienceLevel: data['experienceLevel'] ?? 'Beginner',
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      bio: data['bio'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'contact': contact,
      'hackathon': hackathon,
      'experienceLevel': experienceLevel,
      'skills': skills,
      'interests': interests,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? username,
    String? contact,
    String? hackathon,
    String? experienceLevel,
    List<String>? skills,
    List<String>? interests,
    String? bio,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      contact: contact ?? this.contact,
      hackathon: hackathon ?? this.hackathon,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      createdAt: createdAt,
    );
  }
}
