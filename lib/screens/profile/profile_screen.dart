import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/skill_tag.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _experienceLevel = 'Beginner';
  List<String> _skills = [];
  List<String> _interests = [];
  final _skillController = TextEditingController();
  final _interestController = TextEditingController();
  final _bioController = TextEditingController();
  bool _initialized = false;

  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  void dispose() {
    _skillController.dispose();
    _interestController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Load existing user data into fields
  void _initializeFromUser() {
    final user = ref.read(currentUserProvider);
    if (user != null && !_initialized) {
      setState(() {
        _experienceLevel = user.experienceLevel;
        _skills = List.from(user.skills);
        _interests = List.from(user.interests);
        _bioController.text = user.bio;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileProvider);

    // Initialize fields once user data is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromUser();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(ref),
              const SizedBox(height: 24),

              // User card
              _buildUserCard(
                username: user?.username ?? '',
                contact: user?.contact ?? '',
                hackathon: user?.hackathon ?? '',
              ),
              const SizedBox(height: 24),

              // Experience level
              _buildSectionTitle('Experience level'),
              const SizedBox(height: 12),
              _buildExperienceSelector(),
              const SizedBox(height: 24),

              // Skills
              _buildSectionTitle('Skills'),
              const SizedBox(height: 12),
              _buildTagsInput(
                tags: _skills,
                controller: _skillController,
                hint: 'e.g. React, ML, Figma',
                onAdd: () {
                  if (_skillController.text.trim().isNotEmpty) {
                    setState(() {
                      _skills.add(_skillController.text.trim());
                      _skillController.clear();
                    });
                  }
                },
                onRemove: (index) {
                  setState(() => _skills.removeAt(index));
                },
              ),
              const SizedBox(height: 24),

              // Interests
              _buildSectionTitle('Interests'),
              const SizedBox(height: 12),
              _buildTagsInput(
                tags: _interests,
                controller: _interestController,
                hint: 'e.g. AI, Climate, Web3',
                onAdd: () {
                  if (_interestController.text.trim().isNotEmpty) {
                    setState(() {
                      _interests.add(_interestController.text.trim());
                      _interestController.clear();
                    });
                  }
                },
                onRemove: (index) {
                  setState(() => _interests.removeAt(index));
                },
              ),
              const SizedBox(height: 24),

              // Short bio
              _buildSectionTitle('Short bio'),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'One sentence about you & what you want to build.',
                ),
              ),
              const SizedBox(height: 32),

              // Error message
              if (profileState is AsyncError) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Failed to save profile. Please try again.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Save button
              profileState is AsyncLoading
                  ? _buildLoadingButton()
                  : GradientButton(
                      text: 'Save profile',
                      onPressed: () => _handleSave(user?.id ?? ''),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your profile',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Show off what you bring',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _handleSignOut(ref),
          icon: const Icon(
            Icons.logout_rounded,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard({
    required String username,
    required String contact,
    required String hackathon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '?',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                contact,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                hackathon,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildExperienceSelector() {
    return Row(
      children: _experienceLevels.map((level) {
        final isSelected = _experienceLevel == level;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _experienceLevel = level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                ),
              ),
              child: Text(
                level,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTagsInput({
    required List<String> tags,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
    required Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.asMap().entries.map((entry) {
              return SkillTag(
                label: entry.value,
                removable: true,
                onRemove: () => onRemove(entry.key),
              );
            }).toList(),
          ),
        if (tags.isNotEmpty) const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: hint),
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      ),
    );
  }

  Future<void> _handleSave(String userId) async {
    if (userId.isEmpty) return;

    await ref
        .read(profileProvider.notifier)
        .updateProfile(
          userId: userId,
          experienceLevel: _experienceLevel,
          skills: _skills,
          interests: _interests,
          bio: _bioController.text.trim(),
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Profile saved!',
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

  Future<void> _handleSignOut(WidgetRef ref) async {
    await ref.read(currentUserProvider.notifier).signOut();
  }
}
