import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../core/router/app_router.dart';
import '../../models/user_model.dart';
import '../../design_system/design_tokens.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  String? _selectedAvatar;
  String _selectedGender = 'not_specified';
  DateTime? _selectedBirthDate;

  // Predefined avatar options
  final List<String> _avatarOptions = [
    '👤',
    '👨',
    '👩',
    '🧑',
    '👶',
    '🧒',
    '👦',
    '👧',
    '🧑‍💼',
    '👨‍💼',
    '👩‍💼',
    '🧑‍🎓',
    '👨‍🎓',
    '👩‍🎓',
    '🧑‍💻',
    '👨‍💻',
    '👩‍💻',
    '🧑‍🎨',
    '👨‍🎨',
    '👩‍🎨',
  ];

  @override
  void initState() {
    super.initState();
    _preloadUserData();
  }

  void _preloadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
      _bioController.text = user.profile?.bio ?? '';
      _selectedGender = user.profile?.gender ?? 'not_specified';
      _selectedBirthDate = user.profile?.birthDate;
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Create profile data
      final profile = UserProfile(
        firstName: authProvider.currentUser?.profile?.firstName,
        lastName: authProvider.currentUser?.profile?.lastName,
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        avatar: _selectedAvatar,
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
        location: null,
        occupation: null,
        interests: [],
        measurements: null,
      );

      final success = await authProvider.updateProfile(
        displayName: _displayNameController.text.trim(),
        profile: profile,
      );

      if (success && mounted) {
        _showSnackBar('Profile setup completed successfully!');
        // Navigate to main app
        context.read<NavigationProvider>().replace(AppRouter.main);
      } else if (mounted) {
        _showSnackBar(
          authProvider.errorMessage ?? 'Failed to update profile',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 25);

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryMain,
              onPrimary: Colors.white,
              surface: Colors.grey[900]!,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedBirthDate = date);
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        'Complete Your Profile',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.neutral900,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: DesignTokens.spaceS),
                      Text(
                        'Help us personalize your FitCheck experience',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: DesignTokens.spaceXL),

                      // Avatar Selection
                      _buildAvatarSelection(),
                      SizedBox(height: DesignTokens.spaceL),

                      // Display Name
                      _buildDisplayNameField(),
                      SizedBox(height: DesignTokens.spaceL),

                      // Bio
                      _buildBioField(),
                      SizedBox(height: DesignTokens.spaceL),

                      // Gender Selection
                      _buildGenderSelection(),
                      SizedBox(height: DesignTokens.spaceL),

                      // Birth Date
                      _buildBirthDateSelector(),
                      SizedBox(height: DesignTokens.spaceXL),

                      // Save Profile Button
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return ElevatedButton(
                            onPressed: _isLoading || authProvider.isLoading
                                ? null
                                : _handleSaveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMain,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusM,
                                ),
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: DesignTokens.spaceS),
                                      const Text('Saving...'),
                                    ],
                                  )
                                : Text(
                                    'Complete Setup',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                      SizedBox(height: DesignTokens.spaceM),

                      // Skip button
                      TextButton(
                        onPressed: () => context
                            .read<NavigationProvider>()
                            .replace(AppRouter.main),
                        child: Text(
                          'Skip for now',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Avatar',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: DesignTokens.spaceS),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _avatarOptions.length,
            itemBuilder: (context, index) {
              final avatar = _avatarOptions[index];
              final isSelected = _selectedAvatar == avatar;

              return GestureDetector(
                onTap: () => setState(() => _selectedAvatar = avatar),
                child: Container(
                  width: 60,
                  height: 60,
                  margin: EdgeInsets.only(right: DesignTokens.spaceS),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryMain.withValues(alpha: 0.1)
                        : AppColors.neutral100,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryMain
                          : AppColors.neutral300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender (optional)',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: DesignTokens.spaceS),
        Row(
          children: [
            _buildGenderOption('Male', 'male'),
            SizedBox(width: DesignTokens.spaceS),
            _buildGenderOption('Female', 'female'),
            SizedBox(width: DesignTokens.spaceS),
            _buildGenderOption('Other', 'other'),
            SizedBox(width: DesignTokens.spaceS),
            _buildGenderOption('Prefer not to say', 'not_specified'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _selectedGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: DesignTokens.spaceS,
            horizontal: DesignTokens.spaceXS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryMain.withValues(alpha: 0.1)
                : AppColors.neutral100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            border: Border.all(
              color: isSelected ? AppColors.primaryMain : AppColors.neutral300,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutral900,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildBirthDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date (optional)',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: DesignTokens.spaceS),
        GestureDetector(
          onTap: _selectBirthDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: AppColors.neutralWhite,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              border: Border.all(color: AppColors.neutral300, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.neutral600,
                ),
                SizedBox(width: DesignTokens.spaceS),
                Text(
                  _selectedBirthDate != null
                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                      : 'Select your birth date',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _selectedBirthDate != null
                        ? AppColors.neutral900
                        : AppColors.neutral600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_drop_down, color: AppColors.neutral600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Name',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: DesignTokens.spaceS),
        TextFormField(
          controller: _displayNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Display name is required';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter your display name',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.neutral600),
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

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bio',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: DesignTokens.spaceS),
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          maxLength: 150,
          decoration: InputDecoration(
            hintText: 'Tell us about yourself (optional)',
            prefixIcon: Icon(Icons.edit_outlined, color: AppColors.neutral600),
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
}
