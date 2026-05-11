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
    final snap = await _db
        .collection('users')
        .where('hackathon', isEqualTo: hackathon)
        .get();

    final users = snap.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.id != currentUserId)
        .toList();

    users.sort((a, b) {
      final aScore = a.skills
          .where(
            (s) => lackingSkills
                .map((m) => m.toLowerCase())
                .contains(s.toLowerCase()),
          )
          .length;
      final bScore = b.skills
          .where(
            (s) => lackingSkills
                .map((m) => m.toLowerCase())
                .contains(s.toLowerCase()),
          )
          .length;
      return bScore.compareTo(aScore);
    });

    return users.take(10).toList();
  }
}
