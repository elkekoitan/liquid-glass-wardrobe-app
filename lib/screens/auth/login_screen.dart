import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_tokens.dart';

import '../../services/login_preferences_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/error_service.dart';

import 'package:flutter/foundation.dart';

/// Professional Login Screen with Glass Morphism UI
/// Features: Email/Password, Social Login, Validation, Animations
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  Future<void> _loadSavedCredentials() async {
    final saved = await LoginPreferencesService.instance.load();
    if (!mounted) return;

    setState(() {
      _rememberMe = saved.remember;
      if (saved.remember && saved.email != null && saved.email!.isNotEmpty) {
        _emailController.text = saved.email!;
      } else if (_emailController.text.isEmpty && kDebugMode) {
        _fillTestCredentials();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _fillTestCredentials() {
    _emailController.text = 'turhanhamza@gmail.com';
    _passwordController.text = 'Test123!';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Form validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Login logic
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.otpVerification);
      } else {
        final message = authProvider.errorMessage ?? 'Login failed';
        ErrorService.showError(message);
      }
    } catch (e) {
      ErrorService.showError('An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Social login handlers - handles both sign-in and sign-up
  Future<void> _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithGoogle(
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        final isNewUser = authProvider.user?.profile == null;

        if (isNewUser) {
          ErrorService.showInfo('Hoşgeldin! Hesabın başarıyla oluşturuldu.');
        } else {
          ErrorService.showInfo('Tekrar hoşgeldin!');
        }

        Navigator.pushReplacementNamed(context, AppRouter.otpVerification);
      } else if (mounted) {
        final message =
            authProvider.errorMessage ?? 'Google ile giriş başarısız oldu';
        ErrorService.showError(message);
      }
    } catch (e) {
      debugPrint('Google Sign-In unexpected error: $e');
      ErrorService.showError(
        'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInWithApple(
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        final isNewUser = authProvider.user?.profile == null;

        if (isNewUser) {
          ErrorService.showInfo('Hoşgeldin! Hesabın başarıyla oluşturuldu.');
        } else {
          ErrorService.showInfo('Tekrar hoşgeldin!');
        }

        Navigator.pushReplacementNamed(context, AppRouter.otpVerification);
      } else if (mounted) {
        final message =
            authProvider.errorMessage ?? 'Apple ile giriş başarısız oldu';
        ErrorService.showError(message);
      }
    } catch (e) {
      debugPrint('Apple Sign-In unexpected error: $e');
      ErrorService.showError(
        'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Navigation helpers
  void _navigateToRegister() {
    Navigator.pushNamed(context, AppRouter.register);
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, AppRouter.forgotPassword);
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

                // Login Form
                _buildLoginForm(),

                const SizedBox(height: DesignTokens.spaceXL),

                // Social Login Section
                _buildSocialLogin(),

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
          'Welcome Back',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceS),

        Text(
          'Sign in to continue your fashion journey',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
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
            // Email Field
            _buildEmailField(),

            const SizedBox(height: DesignTokens.spaceL),

            // Password Field
            _buildPasswordField(),

            const SizedBox(height: DesignTokens.spaceM),

            // Remember Me & Forgot Password
            _buildRememberMeRow(),

            const SizedBox(height: DesignTokens.spaceXL),

            // Login Button
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          decoration: InputDecoration(
            hintText: 'Enter your email',
            prefixIcon: Icon(Icons.email_outlined, color: AppColors.neutral600),
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceS),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: _validatePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Icon(Icons.lock_outline, color: AppColors.neutral600),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.neutral600,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
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

  Widget _buildRememberMeRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _rememberMe = !_rememberMe;
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.neutral400, width: 1.5),
                  color: _rememberMe
                      ? AppColors.neutral700
                      : Colors.transparent,
                ),
                child: _rememberMe
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.neutralWhite,
                      )
                    : null,
              ),
              const SizedBox(width: DesignTokens.spaceS),
              Text(
                'Remember me',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _navigateToForgotPassword,
          child: Text(
            'Forgot Password?',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neutral900,
        foregroundColor: AppColors.neutralWhite,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              'Sign In',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.neutralWhite,
              ),
            ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.neutral300)),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceM,
              ),
              child: Text(
                'Or continue with',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: AppColors.neutral300)),
          ],
        ),

        const SizedBox(height: DesignTokens.spaceXL),

        // Social Login Buttons
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                icon: Icons.g_mobiledata,
                label: 'Google ile Devam Et',
                onTap: _handleGoogleLogin,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),
            Expanded(
              child: _buildSocialButton(
                icon: Icons.apple,
                label: 'Apple',
                onTap: _handleAppleLogin,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.spaceM),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.neutral700, size: 20),
            const SizedBox(width: DesignTokens.spaceS),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.neutral900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
        ),
        GestureDetector(
          onTap: _navigateToRegister,
          child: Text(
            'Sign Up',
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
