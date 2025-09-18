import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../design_system/design_tokens.dart';
import '../../models/capsule_model.dart';
import '../../providers/personalization_provider.dart';
import '../../services/capsule_service.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';

/// Main home screen for FitCheck app
/// Features: Welcome message, quick actions, navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.neutralWhite, // Minimalist background
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: DesignTokens.spaceXL),

                // Welcome Card
                _buildWelcomeCard(),

                const SizedBox(height: DesignTokens.spaceXL),

                // Quick Actions
                _buildQuickActions(),

                const SizedBox(height: DesignTokens.spaceXL),

                // Capsule Spotlight
                _buildCapsulePreview(),

                const SizedBox(height: DesignTokens.spaceXL),

                // Features Preview
                _buildFeaturesPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FitCheck',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.neutral900,
              ),
            ),
            Text(
              'Virtual Try-On',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: AppColors.neutral700),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        children: [
          Icon(Icons.checkroom, size: 48, color: AppColors.neutral700),

          const SizedBox(height: DesignTokens.spaceL),

          Text(
            'Welcome to FitCheck!',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.neutral900,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: DesignTokens.spaceM),

          Text(
            'Virtual try-on technology. See how clothes look on you.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutral700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.neutral900,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceL),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.camera_alt,
                title: 'Try On',
                subtitle: 'Upload & try clothes',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.photoUpload);
                },
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),
            Expanded(
              child: _buildActionCard(
                icon: Icons.auto_awesome,
                title: 'Capsules',
                subtitle: 'Browse daily moods',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.capsules);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: DesignTokens.spaceM),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.tune,
                title: 'Personalize',
                subtitle: 'Comfort & motion',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.personalization);
                },
              ),
            ),
            const SizedBox(width: DesignTokens.spaceM),
            Expanded(
              child: _buildActionCard(
                icon: Icons.lock,
                title: 'OTP Flow',
                subtitle: 'Enter secure digits',
                onTap: () {
                  Navigator.pushNamed(context, AppRouter.otpVerification);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        decoration: BoxDecoration(
          color: AppColors.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.neutral700),
            const SizedBox(height: DesignTokens.spaceS),
            Text(
              title,
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceXS),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapsulePreview() {
    final personalization = context.watch<PersonalizationProvider>();
    final reducedMotion = personalization.reducedMotion;

    if (!personalization.hasLoaded) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: DesignTokens.spaceXL),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Capsule",
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceM),
        FutureBuilder<CapsuleModel?>(
          future: CapsuleService.instance.loadCapsuleById(
            personalization.defaultCapsule,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return GlassContainer(
                padding: const EdgeInsets.all(DesignTokens.spaceXL),
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                child: const SizedBox(
                  height: 180,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData) {
              return GlassContainer(
                padding: const EdgeInsets.all(DesignTokens.spaceXL),
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capsule not found',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceS),
                    Text(
                      "Let's explore the capsule gallery to refresh your ritual.",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceL),
                    GlassButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.capsules),
                      child: const Text('Open Capsule Gallery'),
                    ),
                  ],
                ),
              );
            }

            final capsule = snapshot.data!;

            Widget card = GlassContainer(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (capsule.heroImage.isNotEmpty)
                            Image.asset(capsule.heroImage, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.black.withValues(alpha: 0.2),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            left: DesignTokens.spaceL,
                            right: DesignTokens.spaceL,
                            bottom: DesignTokens.spaceL,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  capsule.mood.toUpperCase(),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white70,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: DesignTokens.spaceXS),
                                Text(
                                  capsule.name,
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceL),
                  Text(
                    capsule.description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutral700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.spaceM),
                  Wrap(
                    spacing: DesignTokens.spaceS,
                    runSpacing: DesignTokens.spaceS,
                    children: capsule.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: AppColors.neutral200,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: DesignTokens.spaceL),
                  GlassButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.capsules),
                    child: const Text('Explore Capsules'),
                  ),
                ],
              ),
            );

            if (!reducedMotion) {
              card = card
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                  .slideY(
                    begin: 0.08,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            }

            return card;
          },
        ),
      ],
    );
  }

  Widget _buildFeaturesPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Coming Soon',
          style: AppTextStyles.headlineSmall.copyWith(
            color: AppColors.neutral900,
          ),
        ),

        const SizedBox(height: DesignTokens.spaceL),

        Container(
          padding: const EdgeInsets.all(DesignTokens.spaceL),
          decoration: BoxDecoration(
            color: AppColors.neutralWhite,
            borderRadius: BorderRadius.circular(DesignTokens.radiusL),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            children: [
              _buildFeatureItem(
                icon: Icons.auto_awesome,
                title: 'AI Style Recommendations',
                subtitle: 'Get personalized style suggestions',
              ),
              const SizedBox(height: DesignTokens.spaceM),
              _buildFeatureItem(
                icon: Icons.social_distance,
                title: 'Size Prediction',
                subtitle: 'Find your perfect fit with AI',
              ),
              const SizedBox(height: DesignTokens.spaceM),
              _buildFeatureItem(
                icon: Icons.share,
                title: 'Social Sharing',
                subtitle: 'Share your virtual try-ons',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.neutral200,
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          child: Icon(icon, color: AppColors.neutral700, size: 24),
        ),
        const SizedBox(width: DesignTokens.spaceM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceXS),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
