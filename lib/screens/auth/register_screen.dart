import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../core/router/app_router.dart';
import '../../services/login_preferences_service.dart';
import '../../utils/validators.dart';
import '../../design_system/design_tokens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _loadSavedEmail() async {
    final saved = await LoginPreferencesService.instance.load(
      context: LoginContext.register,
    );
    if (!mounted) return;

    setState(() {
      _rememberMe = saved.remember;
      if (saved.remember && saved.email != null && saved.email!.isNotEmpty) {
        _emailController.text = saved.email!;
      }
    });
  }

  Future<void> _persistEmail(String email) async {
    if (_rememberMe && email.isNotEmpty) {
      await LoginPreferencesService.instance.save(
        remember: true,
        email: email,
        context: LoginContext.register,
      );
    } else {
      await LoginPreferencesService.instance.clear(
        context: LoginContext.register,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      _showSnackBar('Please accept the terms and conditions', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        email: email,
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (success && mounted) {
        await _persistEmail(email);
        if (!mounted) return;

        _showSnackBar(
          'Account created successfully! Please check your email for verification.',
        );
        context.read<NavigationProvider>().replace(AppRouter.profileSetup);
      } else if (mounted) {
        _showSnackBar(
          authProvider.errorMessage ?? 'Registration failed',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.neutralWhite,
          ),
        ),
        backgroundColor: isError
            ? AppColors.error.withValues(alpha: 0.9)
            : AppColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
        margin: EdgeInsets.all(DesignTokens.spaceM),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.neutralWhite,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                SizedBox(height: size.height * 0.08),

                // Register Form
                _buildRegisterForm(),

                const SizedBox(height: DesignTokens.spaceL),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Brand
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.checkroom,
            size: 40,
            color: AppColors.neutral700,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceL),

        // Welcome Text
        Text(
          'Create Account',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceS),

        Text(
          'Join FitCheck and start your virtual try-on journey',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        boxShadow: AppShadows.sm,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'Enter first name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceM),
                Expanded(
                  child: _buildTextField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Enter last name',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceL),

            // Email field
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
            ),
            const SizedBox(height: DesignTokens.spaceL),

            // Password field
            _buildPasswordField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              obscureText: _obscurePassword,
              onToggle: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: Validators.password,
            ),
            const SizedBox(height: DesignTokens.spaceL),

            // Confirm Password field
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              obscureText: _obscureConfirmPassword,
              onToggle: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: DesignTokens.spaceL),

            // Terms and conditions
            Row(
              children: [
                Checkbox(
                  value: _acceptTerms,
                  onChanged: (value) =>
                      setState(() => _acceptTerms = value ?? false),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.neutral900;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: AppColors.neutralWhite,
                  side: BorderSide(color: AppColors.neutral400, width: 1.5),
                ),
                const SizedBox(width: DesignTokens.spaceS),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutral700,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: AppColors.neutral900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: AppColors.neutral900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceS),
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.neutral900;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: AppColors.neutralWhite,
                  side: const BorderSide(
                    color: AppColors.neutral400,
                    width: 1.5,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceS),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    child: Text(
                      'Remember my email for next time',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.spaceXL),

            // Register button
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return ElevatedButton(
                  onPressed: _isLoading || authProvider.isLoading
                      ? null
                      : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neutral900,
                    foregroundColor: AppColors.neutralWhite,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                  child: _isLoading || authProvider.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Create Account',
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: AppColors.neutralWhite,
                          ),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.neutral600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              borderSide: BorderSide(color: AppColors.neutral500),
            ),
            filled: true,
            fillColor: AppColors.neutralWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.neutral600),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.neutral600,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              borderSide: BorderSide(color: AppColors.neutral500),
            ),
            filled: true,
            fillColor: AppColors.neutralWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
        ),
        GestureDetector(
          onTap: () =>
              context.read<NavigationProvider>().replace(AppRouter.login),
          child: Text(
            'Sign In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
