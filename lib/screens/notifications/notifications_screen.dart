import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/request_model.dart';
import '../../providers/request_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showReceived = true;

  @override
  Widget build(BuildContext context) {
    final sentAsync = ref.watch(sentRequestsProvider);
    final receivedAsync = ref.watch(receivedRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inbox',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Collaboration requests',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tabs
                  _buildTabs(sentAsync, receivedAsync),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _showReceived
                  ? _buildRequestsList(receivedAsync, isReceived: true)
                  : _buildRequestsList(sentAsync, isReceived: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
    AsyncValue<List<RequestModel>> sentAsync,
    AsyncValue<List<RequestModel>> receivedAsync,
  ) {
    final receivedCount = receivedAsync.maybeWhen(
      data: (list) => list.where((r) => r.status == 'pending').length,
      orElse: () => 0,
    );
    final sentCount = sentAsync.maybeWhen(
      data: (list) => list.length,
      orElse: () => 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab('Received ($receivedCount)', _showReceived),
          _buildTab('Sent ($sentCount)', !_showReceived),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _showReceived = label.startsWith('R')),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    AsyncValue<List<RequestModel>> requestsAsync, {
    required bool isReceived,
  }) {
    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return _buildEmpty(
            isReceived
                ? 'No requests received yet.'
                : 'You haven\'t sent any requests yet.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          itemCount: requests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildRequestCard(requests[index], isReceived);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => _buildEmpty('Something went wrong.'),
    );
  }

  Widget _buildRequestCard(RequestModel request, bool isReceived) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From / To info
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    isReceived
                        ? request.fromUsername[0].toUpperCase()
                        : (request.toProjectName ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReceived
                          ? request.fromUsername
                          : request.toProjectName ?? 'Unknown project',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isReceived
                          ? 'wants to join ${request.toProjectName ?? 'your project'}'
                          : 'Request to join',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(request.status),
            ],
          ),

          // Accept / Decline buttons for received pending requests
          if (isReceived && request.status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleUpdateStatus(request.id, 'declined'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Decline',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleUpdateStatus(request.id, 'accepted'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Accept',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color textColor;
    String label;

    switch (status) {
      case 'accepted':
        color = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        label = 'Accepted';
        break;
      case 'declined':
        color = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        label = 'Declined';
        break;
      default:
        color = AppColors.tagOrange;
        textColor = AppColors.tagOrangeText;
        label = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Future<void> _handleUpdateStatus(String requestId, String status) async {
    await ref
        .read(sendRequestProvider.notifier)
        .updateStatus(requestId, status);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'accepted' ? 'Request accepted!' : 'Request declined.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: status == 'accepted'
              ? AppColors.success
              : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
