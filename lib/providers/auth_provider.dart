import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream of Firebase auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Current logged in user data
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
      return CurrentUserNotifier(ref.watch(authServiceProvider));
    });

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null);

  Future<void> signUp({
    required String username,
    required String contact,
    required String hackathon,
  }) async {
    final user = await _authService.signUp(
      username: username,
      contact: contact,
      hackathon: hackathon,
    );
    state = user;
  }

  Future<void> login({
    required String username,
    required String hackathon,
  }) async {
    final user = await _authService.login(
      username: username,
      hackathon: hackathon,
    );
    state = user;
  }

  Future<void> loadUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      final user = await _authService.getUserData(firebaseUser.uid);
      state = user;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = null;
  }

  void updateState(UserModel user) {
    state = user;
  }
}
