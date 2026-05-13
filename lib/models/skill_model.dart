import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String skillId;
  final String skillName;
  final List<String> userIds;

  SkillModel({
    required this.skillId,
    required this.skillName,
    required this.userIds,
  });

  factory SkillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SkillModel(
      skillId: doc.id,
      skillName: data['skillName'] ?? '',
      userIds: List<String>.from(data['userIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'skillName': skillName,
      'userIds': userIds,
    };
  }
}