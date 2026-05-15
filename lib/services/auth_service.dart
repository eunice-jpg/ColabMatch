import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign up
  Future<UserModel?> signUp({
    required String username,
    required String contact,
    required String hackathon,
  }) async {
    try {
      final email = contact.contains('@') && contact.contains('.')
          ? contact
          : '$contact@colabmatch.app';

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: _generatePassword(username, contact),
      );

      final user = credential.user!;

      final userModel = UserModel(
        id: user.uid,
        username: username,
        contact: contact,
        hackathon: hackathon,
        experienceLevel: 'Beginner',
        skills: [],
        interests: [],
        bio: '',
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  // Log in
  Future<UserModel?> login({
    required String username,
    required String hackathon,
  }) async {
    try {
       print('LOGIN START: $username / $hackathon');
      final query = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .where('hackathon', isEqualTo: hackathon)
          .limit(1)
          .get();

          print('QUERY DONE: ${query.docs.length} docs');

      if (query.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userData = query.docs.first.data();
      print('USER DATA: $userData');
      final contact = userData['contact'] as String;

      final email = contact.contains('@') && contact.contains('.')
          ? contact
          : '$contact@colabmatch.app';
          print('SIGNING IN WITH: $email');

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _generatePassword(username, contact),
      );
      print('LOGIN SUCCESS');

      return UserModel.fromFirestore(query.docs.first);
    } catch (e, stack) {
       print('LOGIN ERROR: $e');
    print('STACK: $stack');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Simple deterministic password
  String _generatePassword(String username, String contact) {
    return '${username}_${contact}_colabmatch2026';
  }
}
