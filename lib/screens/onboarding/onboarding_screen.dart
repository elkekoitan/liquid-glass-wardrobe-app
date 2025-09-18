import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../design_system/design_tokens.dart';
import '../../providers/personalization_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onComplete});

  final VoidCallback? onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Virtual\nFitting Room',
      subtitle:
          'Try on thousands of designer pieces with photorealistic precision. See exactly how clothes will fit and look before you buy.',
      iconPath: 'assets/images/onboarding/fitting_room.svg',
      features: [
        'Photorealistic virtual try-on technology',
        'Accurate sizing and fit prediction',
        'Works with any clothing item',
      ],
    ),
    OnboardingData(
      title: 'Curated\nCollections',
      subtitle:
          'Discover handpicked styles from leading fashion brands. Get personalized recommendations based on your taste and body type.',
      iconPath: 'assets/images/onboarding/collections.svg',
      features: [
        'Designer collaborations',
        'AI-powered style matching',
        'Exclusive brand partnerships',
      ],
    ),
    OnboardingData(
      title: 'Style\nCommunity',
      subtitle:
          'Connect with fashion enthusiasts worldwide. Share your looks, get styling advice, and discover emerging trends.',
      iconPath: 'assets/images/onboarding/community.svg',
      features: [
        'Style sharing platform',
        'Professional stylist advice',
        'Trend forecasting insights',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  IconData _getIconForPage(OnboardingData data) {
    if (data.title.contains('Virtual')) {
      return Icons.view_in_ar_outlined;
    } else if (data.title.contains('Curated')) {
      return Icons.auto_awesome_outlined;
    } else if (data.title.contains('Style')) {
      return Icons.people_outline;
    }
    return Icons.style_outlined;
  }

  void _nextPage() {
    final reducedMotion = context.read<PersonalizationProvider>().reducedMotion;
    final duration = reducedMotion
        ? Duration.zero
        : DesignTokens.durationNormal;
    final curve = reducedMotion ? Curves.linear : DesignTokens.curveSmooth;

    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: duration, curve: curve);
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
      widget.onComplete?.call();
    }
  }

  void _previousPage() {
    final reducedMotion = context.read<PersonalizationProvider>().reducedMotion;
    final duration = reducedMotion
        ? Duration.zero
        : DesignTokens.durationNormal;
    final curve = reducedMotion ? Curves.linear : DesignTokens.curveSmooth;

    if (_currentPage > 0) {
      _pageController.previousPage(duration: duration, curve: curve);
    }
  }

  @override
  Widget build(BuildContext context) {
    final personalization = context.watch<PersonalizationProvider>();
    final _OnboardingTheme theme = _OnboardingTheme(
      highContrast: personalization.highContrast,
    );
    final bool reducedMotion = personalization.reducedMotion;

    return Scaffold(
      body: Container(
        decoration: theme.backgroundDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopNavigation(theme),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: reducedMotion
                      ? const ClampingScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _buildPage(
                    theme: theme,
                    data: _pages[index],
                    index: index,
                    reducedMotion: reducedMotion,
                  ),
                ),
              ),
              _buildBottomNavigation(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(_OnboardingTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 40,
            child: _currentPage > 0
                ? GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceS),
                      decoration: BoxDecoration(
                        color: theme.iconSurface,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: theme.textPrimary,
                        size: 18,
                      ),
                    ),
                  )
                : null,
          ),
          Row(
            children: List.generate(_pages.length, (index) {
              final bool isActive = _currentPage == index;
              return AnimatedContainer(
                duration: DesignTokens.durationFast,
                curve: DesignTokens.curveSmooth,
                margin: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceXS,
                ),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? theme.accent : theme.indicatorInactive,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, AppRouter.login);
              widget.onComplete?.call();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.spaceM,
                vertical: DesignTokens.spaceS,
              ),
              decoration: BoxDecoration(
                color: theme.iconSurface,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.labelMedium.copyWith(
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({
    required _OnboardingTheme theme,
    required OnboardingData data,
    required int index,
    required bool reducedMotion,
  }) {
    final bool isVisible = _currentPage == index;

    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final double screenHeight = media.size.height;
        final double safeHeight =
            screenHeight - media.padding.top - media.padding.bottom;

        return SingleChildScrollView(
          physics: reducedMotion
              ? const ClampingScrollPhysics()
              : const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceL,
            ),
            child: AnimatedOpacity(
              duration: reducedMotion
                  ? Duration.zero
                  : DesignTokens.durationMedium,
              curve: DesignTokens.curveSmooth,
              opacity: isVisible ? 1 : 0.6,
              child: SizedBox(
                height: safeHeight > 600 ? null : safeHeight * 0.82,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: DesignTokens.spaceXL),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.iconSurface,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusXXL,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.surfacePrimary,
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusRound,
                            ),
                          ),
                          child: Icon(
                            _getIconForPage(data),
                            size: 28,
                            color: theme.featureIconForeground,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXL),
                    Text(
                      data.title,
                      style: AppTextStyles.displayLarge.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 32,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignTokens.spaceL),
                    Text(
                      data.subtitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: theme.textSecondary,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: DesignTokens.spaceXL),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(DesignTokens.spaceL),
                      decoration: BoxDecoration(
                        color: theme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusL,
                        ),
                      ),
                      child: Column(
                        children: data.features
                            .take(3)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              final featureIndex = entry.key;
                              final feature = entry.value;

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: featureIndex < 2
                                      ? DesignTokens.spaceM
                                      : 0,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: theme.featureIconBackground,
                                        borderRadius: BorderRadius.circular(
                                          DesignTokens.radiusRound,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: theme.featureIconForeground,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: DesignTokens.spaceM),
                                    Expanded(
                                      child: Text(
                                        feature,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: theme.textPrimary,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.spaceXL),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(_OnboardingTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: theme.progressBackground,
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentPage + 1) / _pages.length,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accent,
              foregroundColor: theme.accentForeground,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
              shadowColor: theme.accent.withValues(alpha: 0.3),
              elevation: theme.highContrast ? 0 : 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: theme.accentForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceS),
                Icon(
                  _currentPage == _pages.length - 1
                      ? Icons.rocket_launch
                      : Icons.arrow_forward,
                  color: theme.accentForeground,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.features,
  });

  final String title;
  final String subtitle;
  final String iconPath;
  final List<String> features;
}

class _OnboardingTheme {
  _OnboardingTheme({required this.highContrast})
    : backgroundGradient = highContrast
          ? const LinearGradient(
              colors: [Color(0xFF010205), Color(0xFF131826)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null,
      backgroundColor = highContrast ? Colors.black : AppColors.neutralWhite,
      surfacePrimary = highContrast
          ? Colors.white.withValues(alpha: 0.1)
          : AppColors.neutralWhite,
      surfaceSecondary = highContrast
          ? Colors.white.withValues(alpha: 0.06)
          : AppColors.neutral100,
      iconSurface = highContrast
          ? Colors.white.withValues(alpha: 0.12)
          : AppColors.neutral200,
      textPrimary = highContrast ? Colors.white : AppColors.neutral900,
      textSecondary = highContrast
          ? Colors.white.withValues(alpha: 0.8)
          : AppColors.neutral600,
      textMuted = highContrast
          ? Colors.white.withValues(alpha: 0.65)
          : AppColors.neutral500,
      accent = highContrast ? Colors.cyanAccent : AppColors.neutral900,
      accentForeground = highContrast ? Colors.black : AppColors.neutralWhite,
      indicatorInactive = highContrast
          ? Colors.white.withValues(alpha: 0.25)
          : AppColors.neutral300,
      featureIconBackground = highContrast
          ? Colors.white.withValues(alpha: 0.14)
          : AppColors.neutral200,
      featureIconForeground = highContrast
          ? Colors.cyanAccent
          : AppColors.neutral700,
      progressBackground = highContrast
          ? Colors.white.withValues(alpha: 0.25)
          : AppColors.neutral300;

  final bool highContrast;
  final LinearGradient? backgroundGradient;
  final Color backgroundColor;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color iconSurface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentForeground;
  final Color indicatorInactive;
  final Color featureIconBackground;
  final Color featureIconForeground;
  final Color progressBackground;

  BoxDecoration get backgroundDecoration => BoxDecoration(
    gradient: backgroundGradient,
    color: backgroundGradient == null ? backgroundColor : null,
  );
}
