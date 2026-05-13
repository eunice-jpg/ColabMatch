import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/request_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Users ──────────────────────────────────────────

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).update(data);
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  // ── Skills Index ───────────────────────────────────

  Future<void> updateSkillsIndex({
    required String userId,
    required List<String> newSkills,
    required List<String> oldSkills,
  }) async {
    final batch = _db.batch();

    // Remove user from skills they no longer have
    for (final skill in oldSkills) {
      if (!newSkills
          .map((s) => s.toLowerCase())
          .contains(skill.toLowerCase())) {
        final skillRef = _db
            .collection('skills')
            .doc(skill.toLowerCase().trim());
        batch.update(skillRef, {
          'userIds': FieldValue.arrayRemove([userId]),
        });
      }
    }

    // Add user to new skills
    for (final skill in newSkills) {
      final skillId = skill.toLowerCase().trim();
      final skillRef = _db.collection('skills').doc(skillId);

      batch.set(skillRef, {
        'skillName': skillId,
        'userIds': FieldValue.arrayUnion([userId]),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  // Get all skill names for autocomplete
  Future<List<String>> getAllSkillNames() async {
    final snap = await _db.collection('skills').get();
    return snap.docs.map((doc) => doc.data()['skillName'] as String).toList();
  }

  // ── Projects ───────────────────────────────────────

  Future<String> createProject(ProjectModel project) async {
    final doc = await _db.collection('projects').add(project.toMap());
    return doc.id;
  }

  Stream<List<ProjectModel>> getProjectsByHackathon(String hackathon) {
    return _db
        .collection('projects')
        .where('hackathon', isEqualTo: hackathon)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList(),
        );
  }

  Future<List<ProjectModel>> getTrendingProjects(String hackathon) async {
    final snap = await _db
        .collection('projects')
        .where('hackathon', isEqualTo: hackathon)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    return snap.docs.map((doc) => ProjectModel.fromFirestore(doc)).toList();
  }

  // ── Requests ───────────────────────────────────────

  Future<void> sendRequest(RequestModel request) async {
    await _db.collection('requests').add(request.toMap());
  }

  Stream<List<RequestModel>> getSentRequests(String userId) {
    return _db
        .collection('requests')
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RequestModel.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<RequestModel>> getReceivedRequests(String userId) {
    return _db
        .collection('requests')
        .where('toUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RequestModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _db.collection('requests').doc(requestId).update({'status': status});
  }

  // ── Matching ───────────────────────────────────────

  Future<List<UserModel>> findMatches({
    required List<String> lackingSkills,
    required String hackathon,
    required String currentUserId,
  }) async {
    if (lackingSkills.isEmpty) return [];

    // Step 1: For each lacking skill fetch userIds from skills index
    final Map<String, int> userScores = {};

    for (final skill in lackingSkills) {
      final skillDoc = await _db
          .collection('skills')
          .doc(skill.toLowerCase().trim())
          .get();

      if (skillDoc.exists) {
        final data = skillDoc.data() as Map<String, dynamic>;
        final userIds = List<String>.from(data['userIds'] ?? []);

        for (final uid in userIds) {
          if (uid != currentUserId) {
            userScores[uid] = (userScores[uid] ?? 0) + 1;
          }
        }
      }
    }

    if (userScores.isEmpty) return [];

    // Step 2: Sort by score descending
    final sortedUserIds = userScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Step 3: Fetch only top 10 user documents
    final topUserIds = sortedUserIds.take(10).map((e) => e.key).toList();

    final userDocs = await Future.wait(
      topUserIds.map((uid) => _db.collection('users').doc(uid).get()),
    );

    // Step 4: Filter by same hackathon and return
    return userDocs
        .where((doc) => doc.exists)
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.hackathon == hackathon)
        .toList();
  }
}
