import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/project_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class HomeScreen extends ConsumerWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final trendingAsync = user != null
        ? ref.watch(trendingProjectsProvider(user.hackathon))
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(user?.username ?? ''),
              const SizedBox(height: 24),
              _buildMatchReadinessCard(user?.skills.length ?? 0),
              const SizedBox(height: 24),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 24),
              _buildTrendingSection(trendingAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hey, $username ',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Text('👋', style: TextStyle(fontSize: 24)),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  int _calculateReadiness(int skillsCount) {
    if (skillsCount == 0) return 20;
    if (skillsCount >= 5) return 100;
    return 20 + (skillsCount * 16);
  }

  Widget _buildMatchReadinessCard(int skillsCount) {
    final readiness = _calculateReadiness(skillsCount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your match readiness',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$readiness%',
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => onNavigate(4),
                child: Text(
                  'Boost',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            skillsCount == 0
                ? 'Add skills & interests to improve matches.'
                : 'Looking good! Keep adding skills to improve.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    // index matches bottom nav: 0=Home, 1=Browse, 2=Create, 3=Inbox, 4=Profile
    final actions = [
      {
        'label': 'Profile',
        'subtitle': 'Showcase skills',
        'icon': Icons.person_outline_rounded,
        'color': const Color(0xFF6C63FF),
        'index': 4,
      },
      {
        'label': 'Create',
        'subtitle': 'Find collaborators',
        'icon': Icons.add_box_outlined,
        'color': const Color(0xFF10B981),
        'index': 2,
      },
      {
        'label': 'Browse',
        'subtitle': 'Join a team',
        'icon': Icons.explore_outlined,
        'color': const Color(0xFFF59E0B),
        'index': 1,
      },
      {
        'label': 'Inbox',
        'subtitle': '0 pending',
        'icon': Icons.notifications_outlined,
        'color': const Color(0xFF8B5CF6),
        'index': 3,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionCard(
          label: action['label'] as String,
          subtitle: action['subtitle'] as String,
          icon: action['icon'] as IconData,
          color: action['color'] as Color,
          onTap: () => onNavigate(action['index'] as int),
        );
      },
    );
  }

  Widget _buildActionCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingSection(AsyncValue<List<ProjectModel>>? trendingAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trending projects',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => onNavigate(1),
              child: Text(
                'See all →',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (trendingAsync == null)
          _buildEmptyTrending()
        else
          trendingAsync.when(
            data: (projects) {
              if (projects.isEmpty) return _buildEmptyTrending();
              return Column(
                children: projects
                    .map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildTrendingCard(project: p),
                        ))
                    .toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (_, __) => _buildEmptyTrending(),
          ),
      ],
    );
  }

  Widget _buildEmptyTrending() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Center(
        child: Text(
          'No projects yet in your hackathon.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard({required ProjectModel project}) {
    return GestureDetector(
      onTap: () => onNavigate(1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
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
            Text(
              'by ${project.ownerName}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}