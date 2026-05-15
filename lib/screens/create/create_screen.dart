import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/skill_tag.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/request_provider.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _existingSkillController = TextEditingController();
  final _lackingSkillController = TextEditingController();

  final List<String> _existingSkills = [];
  final List<String> _lackingSkills = [];
  bool _showMatches = false;

  @override
  void dispose() {
    _projectNameController.dispose();
    _descriptionController.dispose();
    _existingSkillController.dispose();
    _lackingSkillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final createState = ref.watch(createProjectProvider);
    final matchesState = ref.watch(matchesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              if (!_showMatches) ...[
                // Project form
                _buildForm(user, createState),
              ] else ...[
                // Matches list
                _buildMatchesSection(matchesState, user),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (_showMatches)
              GestureDetector(
                onTap: () => setState(() => _showMatches = false),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showMatches ? 'Suggested matches' : 'New project',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _showMatches
                      ? 'People who complement your team'
                      : 'Find your missing pieces',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildForm(dynamic user, AsyncValue<void> createState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project name
        _buildLabel('PROJECT NAME'),
        const SizedBox(height: 8),
        TextField(
          controller: _projectNameController,
          decoration: const InputDecoration(hintText: 'e.g. MediScan AI'),
        ),
        const SizedBox(height: 20),

        // Description
        _buildLabel('DESCRIPTION'),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What you\'re building & the vision.',
          ),
        ),
        const SizedBox(height: 20),

        // Hackathon
        _buildLabel('HACKATHON'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            user?.hackathon ?? 'Not set',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Existing skills
        _buildLabel('EXISTING SKILLS IN TEAM'),
        const SizedBox(height: 8),
        _buildTagsInput(
          tags: _existingSkills,
          controller: _existingSkillController,
          hint: 'e.g. Python, React',
          onAdd: () {
            if (_existingSkillController.text.trim().isNotEmpty) {
              setState(() {
                _existingSkills.add(_existingSkillController.text.trim());
                _existingSkillController.clear();
              });
            }
          },
          onRemove: (index) => setState(() => _existingSkills.removeAt(index)),
        ),
        const SizedBox(height: 20),

        // Lacking skills
        _buildLabel('LACKING SKILLS'),
        const SizedBox(height: 8),
        _buildTagsInput(
          tags: _lackingSkills,
          controller: _lackingSkillController,
          hint: 'e.g. UI/UX, ML',
          onAdd: () {
            if (_lackingSkillController.text.trim().isNotEmpty) {
              setState(() {
                _lackingSkills.add(_lackingSkillController.text.trim());
                _lackingSkillController.clear();
              });
            }
          },
          onRemove: (index) => setState(() => _lackingSkills.removeAt(index)),
          tagColor: AppColors.tagOrange,
          tagTextColor: AppColors.tagOrangeText,
        ),
        const SizedBox(height: 32),

        // Error
        if (createState is AsyncError) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Text(
              'Failed to create project. Please try again.',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Find matches button
        createState is AsyncLoading
            ? _buildLoadingButton()
            : GradientButton(
                text: 'Find matches',
                icon: Icons.auto_awesome_rounded,
                onPressed: () => _handleFindMatches(user),
              ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMatchesSection(
    AsyncValue<List<UserModel>> matchesState,
    dynamic user,
  ) {
    return matchesState.when(
      data: (matches) {
        if (matches.isEmpty) {
          return _buildEmptyMatches();
        }
        return Column(
          children: [
            ...matches.map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMatchCard(match, user?.id ?? ''),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, _) => Center(
        child: Text(
          'Failed to load matches.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildMatchCard(UserModel match, String currentUserId) {
    // Calculate match score
    final matchingSkills = match.skills
        .where(
          (s) => _lackingSkills
              .map((l) => l.toLowerCase())
              .contains(s.toLowerCase()),
        )
        .toList();

    final matchPercent = _lackingSkills.isEmpty
        ? 0
        : ((matchingSkills.length / _lackingSkills.length) * 100).round();

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
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    match.username[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name and level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.username,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      match.experienceLevel,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Match percentage
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$matchPercent% match',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Skills
          if (match.skills.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: match.skills.map((s) {
                final isMatch = _lackingSkills
                    .map((l) => l.toLowerCase())
                    .contains(s.toLowerCase());
                return SkillTag(
                  label: s,
                  backgroundColor: isMatch
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.tagBlue,
                  textColor: isMatch ? AppColors.success : AppColors.tagBluText,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Bio
          if (match.bio.isNotEmpty) ...[
            Text(
              match.bio,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],

          // Match explanation
          if (matchingSkills.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Has ${matchingSkills.join(', ')} — exactly what you need!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Send request button
          GestureDetector(
            onTap: () => _handleSendRequest(match),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Invite to collaborate',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMatches() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No matches found yet.\nTry adding more lacking skills.',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildTagsInput({
    required List<String> tags,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    Color? tagColor,
    Color? tagTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.asMap().entries.map((entry) {
              return SkillTag(
                label: entry.value,
                removable: true,
                onRemove: () => onRemove(entry.key),
                backgroundColor: tagColor,
                textColor: tagTextColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
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

  Future<void> _handleFindMatches(dynamic user) async {
    if (user == null) return;

    if (_projectNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a project name.',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Create project in Firestore
    await ref
        .read(createProjectProvider.notifier)
        .createProject(
          name: _projectNameController.text.trim(),
          description: _descriptionController.text.trim(),
          existingSkills: _existingSkills,
          lackingSkills: _lackingSkills,
        );

    // Find matches
    await ref.read(matchesProvider.notifier).findMatches(_lackingSkills);

    if (mounted) {
      setState(() => _showMatches = true);
    }
  }

  Future<void> _handleSendRequest(UserModel match) async {
    await ref
        .read(sendRequestProvider.notifier)
        .sendRequest(
        toUserId: match.id,
        toUsername: match.username,
        toProjectName: _projectNameController.text.trim(),
        type: 'invite',
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invitation sent to ${match.username}!',
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
}
