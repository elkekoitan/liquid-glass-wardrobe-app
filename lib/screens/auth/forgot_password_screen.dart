import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../design_system/design_tokens.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
        _showSnackBar('Password reset email sent! Please check your email.');
      } else if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(
          authProvider.errorMessage ?? 'Failed to send reset email',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('An error occurred. Please try again.', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: isError
            ? AppColors.error.withValues(alpha: 0.9)
            : AppColors.success.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.spaceM),
        ),
        margin: EdgeInsets.all(DesignTokens.spaceM),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppColors.neutralWhite,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(DesignTokens.spaceL),
              child: Container(
                padding: EdgeInsets.all(DesignTokens.spaceXL),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                  boxShadow: AppShadows.sm,
                ),
                child: _emailSent ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset,
              color: AppColors.neutral700,
              size: 40,
            ),
          ),
          SizedBox(height: DesignTokens.spaceXL),

          // Title
          Text(
            'Forgot Password?',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.neutral900,
            ),
          ),
          SizedBox(height: DesignTokens.spaceS),
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: DesignTokens.spaceXL),

          // Email field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceS),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.neutral600,
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
          ),
          SizedBox(height: DesignTokens.spaceXL),

          // Reset button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: _isLoading || authProvider.isLoading
                    ? null
                    : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neutral900,
                  foregroundColor: AppColors.neutralWhite,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                  ),
                ),
                child: _isLoading || authProvider.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: DesignTokens.spaceS),
                          const Text('Sending...'),
                        ],
                      )
                    : Text(
                        'Send Reset Link',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.neutralWhite,
                        ),
                      ),
              );
            },
          ),
          SizedBox(height: DesignTokens.spaceL),

          // Back to login
          TextButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            ),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutral600,
                ),
                children: [
                  const TextSpan(text: 'Remember your password? '),
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: AppColors.neutral900,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle_outline,
            color: AppColors.neutral700,
            size: 50,
          ),
        ),
        SizedBox(height: DesignTokens.spaceXL),

        // Title
        Text(
          'Email Sent!',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: DesignTokens.spaceS),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text.trim()}',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignTokens.spaceS),
        Text(
          'Please check your email and follow the instructions to reset your password.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignTokens.spaceXL),

        // Resend button
        ElevatedButton(
          onPressed: () {
            setState(() => _emailSent = false);
            _handleResetPassword();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neutral900,
            foregroundColor: AppColors.neutralWhite,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
          ),
          child: Text(
            'Resend Email',
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.neutralWhite,
            ),
          ),
        ),
        SizedBox(height: DesignTokens.spaceM),

        // Back to login
        TextButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ),
          child: Text(
            'Back to Sign In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
      ],
    );
  }
}
