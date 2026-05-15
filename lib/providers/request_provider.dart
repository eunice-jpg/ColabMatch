import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'project_provider.dart';

// Sent requests stream
final sentRequestsProvider = StreamProvider<List<RequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getSentRequests(user.id);
});

// Received requests stream
final receivedRequestsProvider = StreamProvider<List<RequestModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.watch(firestoreServiceProvider).getReceivedRequests(user.id);
});

// Send request notifier
final sendRequestProvider =
    StateNotifierProvider<SendRequestNotifier, AsyncValue<void>>((ref) {
      return SendRequestNotifier(
        ref.watch(firestoreServiceProvider),
        ref.watch(currentUserProvider),
      );
    });

class SendRequestNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestoreService;
  final UserModel? _currentUser;

  SendRequestNotifier(this._firestoreService, this._currentUser)
    : super(const AsyncValue.data(null));

  Future<void> sendRequest({
    required String toUserId,
    String? toUsername,
    String? toProjectId,
    String? toProjectName,
    String type = 'join',
  }) async {
    if (_currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final request = RequestModel(
        id: '',
        fromUserId: _currentUser.id,
        fromUsername: _currentUser.username,
        toUserId: toUserId,
        toUsername: toUsername,
        toProjectId: toProjectId,
        toProjectName: toProjectName,
        status: 'pending',
        type: type,
        createdAt: DateTime.now(),
      );

      await _firestoreService.sendRequest(request);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String requestId, String status) async {
    state = const AsyncValue.loading();
    try {
      await _firestoreService.updateRequestStatus(requestId, status);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
