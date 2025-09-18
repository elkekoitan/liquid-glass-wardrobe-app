import 'package:flutter/material.dart';
import '../../design_system/design_tokens.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const OnboardingScreen({super.key, this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Virtual\nFitting Room",
      subtitle:
          "Try on thousands of designer pieces with photorealistic precision. See exactly how clothes will fit and look before you buy.",
      iconPath: "assets/images/onboarding/fitting_room.svg",
      features: [
        "Photorealistic virtual try-on technology",
        "Accurate sizing and fit prediction",
        "Works with any clothing item",
      ],
    ),
    OnboardingData(
      title: "Curated\nCollections",
      subtitle:
          "Discover handpicked styles from leading fashion brands. Get personalized recommendations based on your taste and body type.",
      iconPath: "assets/images/onboarding/collections.svg",
      features: [
        "Designer collaborations",
        "AI-powered style matching",
        "Exclusive brand partnerships",
      ],
    ),
    OnboardingData(
      title: "Style\nCommunity",
      subtitle:
          "Connect with fashion enthusiasts worldwide. Share your looks, get styling advice, and discover emerging trends.",
      iconPath: "assets/images/onboarding/community.svg",
      features: [
        "Style sharing platform",
        "Professional stylist advice",
        "Trend forecasting insights",
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
      return Icons.view_in_ar_outlined; // Professional AR/VR icon
    } else if (data.title.contains('Curated')) {
      return Icons.auto_awesome_outlined; // Curation/AI icon
    } else if (data.title.contains('Style')) {
      return Icons.people_outline; // Community icon
    }
    return Icons.style_outlined; // Default fashion icon
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: DesignTokens.durationNormal,
        curve: DesignTokens.curveSmooth,
      );
    } else {
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, AppRouter.login);
      widget.onComplete?.call();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: DesignTokens.durationNormal,
        curve: DesignTokens.curveSmooth,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.neutralWhite,
        child: SafeArea(
          child: Column(
            children: [
              // Top Navigation
              _buildTopNavigation(),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index], index);
                  },
                ),
              ),

              // Bottom Navigation
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button (only show if not first page)
          SizedBox(
            width: 40,
            child: _currentPage > 0
                ? GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.all(DesignTokens.spaceS),
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusRound,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: AppColors.neutral700,
                        size: 18,
                      ),
                    ),
                  )
                : null,
          ),

          // Page Indicator
          Row(
            children: List.generate(_pages.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceXS,
                ),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index ? AppColors.neutral900 : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
              );
            }),
          ),

          // Skip button
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
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
              ),
              child: Text(
                'Skip',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data, int index) {
    final isVisible = _currentPage == index;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.of(context).size.height;
        final safeHeight =
            screenHeight -
            MediaQuery.of(context).padding.top -
            MediaQuery.of(context).padding.bottom;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.spaceL,
            ),
            child: SizedBox(
              height: safeHeight > 600 ? null : safeHeight * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: DesignTokens.spaceXL),

                   // Professional Fashion Icon
                   Container(
                     width: 120,
                     height: 120,
                     decoration: BoxDecoration(
                       color: AppColors.neutral200,
                       borderRadius: BorderRadius.circular(
                         DesignTokens.radiusXXL,
                       ),
                     ),
                     child: Center(
                       child: Container(
                         width: 50,
                         height: 50,
                         decoration: BoxDecoration(
                           color: AppColors.neutralWhite,
                           borderRadius: BorderRadius.circular(
                             DesignTokens.radiusL,
                           ),
                         ),
                         child: Icon(
                           _getIconForPage(data),
                           size: 24,
                           color: AppColors.neutral800,
                         ),
                       ),
                     ),
                   ),

                  const SizedBox(height: DesignTokens.spaceXL),

                   // Title
                   Text(
                     data.title,
                     style: AppTextStyles.displayLarge.copyWith(
                       color: AppColors.neutral900,
                       fontWeight: FontWeight.w800,
                       fontSize: 32,
                       height: 1.2,
                     ),
                     textAlign: TextAlign.center,
                     maxLines: 2,
                     overflow: TextOverflow.ellipsis,
                   ),

                  const SizedBox(height: DesignTokens.spaceL),

                   // Subtitle
                   Text(
                     data.subtitle,
                     style: AppTextStyles.bodyLarge.copyWith(
                       color: AppColors.neutral700,
                       fontSize: 16,
                       height: 1.5,
                     ),
                     textAlign: TextAlign.center,
                     maxLines: 3,
                     overflow: TextOverflow.ellipsis,
                   ),

                  const SizedBox(height: DesignTokens.spaceXL),

                   // Features List
                   Container(
                     padding: const EdgeInsets.all(DesignTokens.spaceL),
                     decoration: BoxDecoration(
                       color: AppColors.neutral100,
                       borderRadius: BorderRadius.circular(DesignTokens.radiusL),
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
                                       color: AppColors.neutral300,
                                       borderRadius: BorderRadius.circular(
                                         DesignTokens.radiusRound,
                                       ),
                                     ),
                                     child: Icon(
                                       Icons.check,
                                       color: AppColors.neutral700,
                                       size: 14,
                                     ),
                                   ),
                                   const SizedBox(
                                     width: DesignTokens.spaceM,
                                   ),
                                   Expanded(
                                     child: Text(
                                       feature,
                                       style: AppTextStyles.bodyMedium
                                           .copyWith(
                                             color: AppColors.neutral900,
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
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.spaceXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicator
          Container(
            width: double.infinity,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(DesignTokens.radiusS),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentPage + 1) / _pages.length,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral900,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
              ),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // Next/Get Started Button
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neutral900,
              foregroundColor: AppColors.neutralWhite,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.neutralWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: DesignTokens.spaceS),
                Icon(
                  _currentPage == _pages.length - 1
                      ? Icons.rocket_launch
                      : Icons.arrow_forward,
                  color: AppColors.neutralWhite,
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
  final String title;
  final String subtitle;
  final String iconPath;
  final List<String> features;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.features,
  });
}
