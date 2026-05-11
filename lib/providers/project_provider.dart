import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Projects stream by hackathon
final projectsProvider = StreamProvider.family<List<ProjectModel>, String>((
  ref,
  hackathon,
) {
  return ref.watch(firestoreServiceProvider).getProjectsByHackathon(hackathon);
});

// Trending projects
final trendingProjectsProvider =
    FutureProvider.family<List<ProjectModel>, String>((ref, hackathon) {
      return ref.watch(firestoreServiceProvider).getTrendingProjects(hackathon);
    });

// Create project notifier
final createProjectProvider =
    StateNotifierProvider<CreateProjectNotifier, AsyncValue<void>>((ref) {
      return CreateProjectNotifier(
        ref.watch(firestoreServiceProvider),
        ref.watch(currentUserProvider),
      );
    });

class CreateProjectNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final UserModel? _currentUser;

  CreateProjectNotifier(this._firestoreService, this._currentUser)
    : super(const AsyncValue.data(null));

  Future<String?> createProject({
    required String name,
    required String description,
    required List<String> existingSkills,
    required List<String> lackingSkills,
  }) async {
    if (_currentUser == null) return null;

    state = const AsyncValue.loading();
    try {
      final project = ProjectModel(
        id: '',
        name: name,
        description: description,
        hackathon: _currentUser.hackathon,
        ownerId: _currentUser.id,
        ownerName: _currentUser.username,
        existingSkills: existingSkills,
        lackingSkills: lackingSkills,
        createdAt: DateTime.now(),
      );

      final projectId = await _firestoreService.createProject(project);
      state = const AsyncValue.data(null);
      return projectId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

// Matches provider
final matchesProvider =
    StateNotifierProvider<MatchesNotifier, AsyncValue<List<UserModel>>>((ref) {
      return MatchesNotifier(
        ref.watch(firestoreServiceProvider),
        ref.watch(currentUserProvider),
      );
    });

class MatchesNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final FirestoreService _firestoreService;
  final UserModel? _currentUser;

  MatchesNotifier(this._firestoreService, this._currentUser)
    : super(const AsyncValue.data([]));

  Future<void> findMatches(List<String> lackingSkills) async {
    if (_currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final matches = await _firestoreService.findMatches(
        lackingSkills: lackingSkills,
        hackathon: _currentUser.hackathon,
        currentUserId: _currentUser.id,
      );
      state = AsyncValue.data(matches);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
