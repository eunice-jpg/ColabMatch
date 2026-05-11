import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
              _buildMatchReadinessCard(user),
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

  Widget _buildMatchReadinessCard(user) {
    // Calculate match readiness based on profile completeness
    int score = 0;
    if (user != null) {
      if (user.skills.isNotEmpty) score += 40;
      if (user.interests.isNotEmpty) score += 30;
      if (user.bio.isNotEmpty) score += 20;
      if (user.experienceLevel != 'Beginner') score += 10;
    }

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
                '$score%',
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {},
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
            score < 100
                ? 'Add skills & interests to improve matches.'
                : 'Your profile is complete!',
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
    final actions = [
      {
        'label': 'Profile',
        'subtitle': 'Showcase skills',
        'icon': Icons.person_outline_rounded,
        'color': const Color(0xFF6C63FF),
      },
      {
        'label': 'Create',
        'subtitle': 'Find collaborators',
        'icon': Icons.add_box_outlined,
        'color': const Color(0xFF10B981),
      },
      {
        'label': 'Browse',
        'subtitle': 'Join a team',
        'icon': Icons.explore_outlined,
        'color': const Color(0xFFF59E0B),
      },
      {
        'label': 'Inbox',
        'subtitle': 'Collaboration requests',
        'icon': Icons.notifications_outlined,
        'color': const Color(0xFF8B5CF6),
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
          onTap: () {},
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

  Widget _buildTrendingSection(trendingAsync) {
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
              onTap: () {},
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
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTrendingCard(
                          name: p.name,
                          author: 'by ${p.ownerName}',
                          description: p.description,
                          openSpots: p.lackingSkills.length,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Could not load projects.'),
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
          'No projects yet in your hackathon.\nBe the first to create one!',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard({
    required String name,
    required String author,
    required String description,
    required int openSpots,
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
                  '$openSpots open',
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
            author,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
