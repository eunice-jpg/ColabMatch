import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'project_provider.dart';

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
      return ProfileNotifier(
        ref.watch(firestoreServiceProvider),
        ref.read(currentUserProvider.notifier),
      );
    });

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final CurrentUserNotifier _currentUserNotifier;

  ProfileNotifier(this._firestoreService, this._currentUserNotifier)
    : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String userId,
    required String experienceLevel,
    required List<String> skills,
    required List<String> interests,
    required String bio,
  }) async {
    state = const AsyncValue.loading();
    try {
      final oldUser = await _firestoreService.getUser(userId);
    final oldSkills = oldUser?.skills ?? [];
    print('OLD SKILLS: $oldSkills');
    print('NEW SKILLS: $skills');

      await _firestoreService.updateUser(userId, {
        'experienceLevel': experienceLevel,
        'skills': skills,
        'interests': interests,
        'bio': bio,
      });
      print('USER UPDATED, now updating skills index...');

      await _firestoreService.updateSkillsIndex(
      userId: userId,
      newSkills: skills,
      oldSkills: oldSkills,
    );
    print('SKILLS INDEX UPDATED');


      // Update local state
      final updatedUser = await _firestoreService.getUser(userId);
      if (updatedUser != null) {
        _currentUserNotifier.updateState(updatedUser);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('PROFILE ERROR: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
