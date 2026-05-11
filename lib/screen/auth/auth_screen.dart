import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUp = true;

  final _usernameController = TextEditingController();
  final _contactController = TextEditingController();
  final _hackathonController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _contactController.dispose();
    _hackathonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              _buildLogo(),
              const SizedBox(height: 32),

              // Headline
              Text(
                'Find your dream team.',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Match with hackathon collaborators who complete your skills.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Tabs
              _buildTabs(),
              const SizedBox(height: 32),

              // Form
              if (isSignUp) _buildSignUpForm() else _buildLoginForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          'ColabMatch',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTab('Sign up', isSignUp),
          _buildTab('Log in', !isSignUp),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isSignUp = label == 'Sign up'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
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
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('USERNAME'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _usernameController,
          hint: 'e.g. alex.dev',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),

        _buildLabel('CONTACT'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _contactController,
          hint: 'email or @handle',
          icon: Icons.alternate_email,
        ),
        const SizedBox(height: 20),

        _buildLabel('HACKATHON CODE OR NAME'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _hackathonController,
          hint: 'e.g. HACK2026',
          icon: Icons.code_rounded,
        ),
        const SizedBox(height: 32),

        GradientButton(text: 'Create account', onPressed: _handleSignUp),
        const SizedBox(height: 16),

        Center(
          child: Text(
            'By continuing you agree to play nice and ship fast.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('USERNAME'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _usernameController,
          hint: 'e.g. alex.dev',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),

        _buildLabel('HACKATHON CODE OR NAME'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _hackathonController,
          hint: 'e.g. HACK2026',
          icon: Icons.code_rounded,
        ),
        const SizedBox(height: 32),

        GradientButton(text: 'Log in', onPressed: _handleLogin),
      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  void _handleSignUp() {
    // We'll connect Firebase Auth here later
    debugPrint('Sign up: ${_usernameController.text}');
  }

  void _handleLogin() {
    // We'll connect Firebase Auth here later
    debugPrint('Login: ${_usernameController.text}');
  }
}
