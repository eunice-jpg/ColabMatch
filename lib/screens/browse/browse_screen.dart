import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/skill_tag.dart';
import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/request_provider.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final projectsAsync = user != null
        ? ref.watch(projectsProvider(user.hackathon))
        : null;

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
                    'Browse projects',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user != null
                        ? 'Teams looking for collaborators in ${user.hackathon}'
                        : 'Teams looking for collaborators',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search projects or skills',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Projects list
            Expanded(
              child: projectsAsync == null
                  ? _buildEmpty(
                      'No projects found. Be the first to create one!',
                    )
                  : projectsAsync.when(
                      data: (projects) {
                        final filtered = _searchQuery.isEmpty
                            ? projects
                            : projects.where((p) {
                                return p.name.toLowerCase().contains(
                                      _searchQuery,
                                    ) ||
                                    p.description.toLowerCase().contains(
                                      _searchQuery,
                                    ) ||
                                    p.existingSkills.any(
                                      (s) => s.toLowerCase().contains(
                                        _searchQuery,
                                      ),
                                    ) ||
                                    p.lackingSkills.any(
                                      (s) => s.toLowerCase().contains(
                                        _searchQuery,
                                      ),
                                    );
                              }).toList();

                        if (filtered.isEmpty) {
                          return _buildEmpty('No projects found. ');
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _buildProjectCard(
                              context,
                              filtered[index],
                              user?.id ?? '',
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => _buildEmpty(
                        'Something went wrong. Please try again.',
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    ProjectModel project,
    String currentUserId,
  ) {
    final isOwner = project.ownerId == currentUserId;

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
          // Project name and open spots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tagOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${project.lackingSkills.length} open',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.tagOrangeText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Owner
          Text(
            'by ${project.ownerName}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            project.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Team has
          if (project.existingSkills.isNotEmpty) ...[
            Text(
              'TEAM HAS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.existingSkills
                  .map((s) => SkillTag(label: s))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Looking for
          if (project.lackingSkills.isNotEmpty) ...[
            Text(
              'LOOKING FOR',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.lackingSkills
                  .map(
                    (s) => SkillTag(
                      label: s,
                      backgroundColor: AppColors.tagOrange,
                      textColor: AppColors.tagOrangeText,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Request to join button
          if (!isOwner) _buildRequestButton(context, project, currentUserId),
          if (isOwner)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Your project',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestButton(
    BuildContext context,
    ProjectModel project,
    String currentUserId,
  ) {
    return GestureDetector(
      onTap: () => _handleRequestToJoin(context, project, currentUserId),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Request to join',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRequestToJoin(
    BuildContext context,
    ProjectModel project,
    String currentUserId,
  ) async {
    if (currentUserId.isEmpty) return;

    await ref
        .read(sendRequestProvider.notifier)
        .sendRequest(
          toUserId: project.ownerId,
          toProjectId: project.id,
          toProjectName: project.name,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Request sent to ${project.ownerName}!',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.success,
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
            Icon(Icons.explore_outlined, size: 48, color: Colors.grey.shade300),
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
