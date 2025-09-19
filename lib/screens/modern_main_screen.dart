import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../design_system/design_tokens.dart';
import '../design_system/components/fashion_components.dart';

import '../widgets/modern_navigation.dart';
import '../core/router/app_router.dart';
import '../providers/navigation_provider.dart';

class ModernMainScreen extends StatefulWidget {
  const ModernMainScreen({super.key});

  @override
  State<ModernMainScreen> createState() => _ModernMainScreenState();
}

class _ModernMainScreenState extends State<ModernMainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;

  final List<ModernNavItem> _navItems = const [
    ModernNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      selectedGradient: LinearGradient(
        colors: [AppColors.neutral900, AppColors.neutral700],
      ),
    ),
    ModernNavItem(
      label: 'Wardrobe',
      icon: Icons.checkroom_outlined,
      activeIcon: Icons.checkroom,
      selectedGradient: LinearGradient(
        colors: [AppColors.neutral800, AppColors.neutral600],
      ),
    ),
    ModernNavItem(
      label: 'Try On',
      icon: Icons.camera_alt_outlined,
      activeIcon: Icons.camera_alt,
      selectedGradient: LinearGradient(
        colors: [AppColors.neutral800, AppColors.neutral600],
      ),
    ),
    ModernNavItem(
      label: 'Outfits',
      icon: Icons.style_outlined,
      activeIcon: Icons.style,
      selectedGradient: LinearGradient(
        colors: [AppColors.neutral800, AppColors.neutral600],
      ),
    ),
    ModernNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      selectedGradient: LinearGradient(
        colors: [AppColors.neutral800, AppColors.neutral600],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          IndexedStack(
            index: _currentIndex,
            children: const [
              HomeTab(),
              WardrobeTab(),
              TryOnTab(),
              OutfitsTab(),
              ProfileTab(),
            ],
          ),

          // Floating Action Button
          if (_currentIndex == 0 || _currentIndex == 1)
            Positioned(
              right: DesignTokens.spaceL,
              bottom: 100 + MediaQuery.of(context).padding.bottom,
              child: FloatingActionButton(
                heroTag: "photo_fab",
                backgroundColor: AppColors.neutral900,
                foregroundColor: AppColors.neutralWhite,
                onPressed: () {
                  context.read<NavigationProvider>().push(
                    AppRouter.photoUpload,
                  );
                },
                child: const Icon(Icons.add_a_photo),
              ),
            ),
        ],
      ),
      bottomNavigationBar: ModernBottomNavigation(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Home Tab Content
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutralWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(DesignTokens.spaceL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceS),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusRound,
                      ),
                    ),
                    child: const Icon(
                      Icons.menu,
                      color: AppColors.neutral700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover Style',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                        Text(
                          'Virtual fitting room powered by AI',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusRound,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.neutral700,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(
                color: AppColors.neutralWhite,
                child: ListView(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  children: [
                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.view_in_ar_rounded,
                            label: 'Virtual Try-On',
                            backgroundColor: AppColors.neutral900,
                            onPressed: () {
                              context.read<NavigationProvider>().push(
                                AppRouter.photoUpload,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: DesignTokens.spaceM),
                        Expanded(
                          child: QuickActionButton(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Style AI',
                            backgroundColor: AppColors.neutral700,
                            onPressed: () {
                              // AI Styling action
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: DesignTokens.spaceXL),

                    // Fashion Categories
                    Text(
                      'Featured Collections',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spaceL),

                    SizedBox(
                      height: 180,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 180,
                            child: FashionCategoryCard(
                              title: 'Evening Wear',
                              subtitle: 'Designer Gowns',
                              imagePath:
                                  'assets/images/categories/evening_wear.jpg',
                              overlayColor: AppColors.neutral800,
                              onTap: () {
                                // Navigate to evening wear
                              },
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceM),
                          SizedBox(
                            width: 180,
                            child: FashionCategoryCard(
                              title: 'Contemporary',
                              subtitle: 'Modern Essentials',
                              imagePath:
                                  'assets/images/categories/contemporary.jpg',
                              overlayColor: AppColors.neutral700,
                              onTap: () {
                                // Navigate to contemporary
                              },
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spaceM),
                          SizedBox(
                            width: 180,
                            child: FashionCategoryCard(
                              title: 'Luxury Brands',
                              subtitle: 'Premium Collection',
                              imagePath: 'assets/images/categories/luxury.jpg',
                              overlayColor: AppColors.neutral600,
                              onTap: () {
                                // Navigate to luxury
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spaceXXL),

                    // Recent Outfits
                    Text(
                      'Style Inspiration',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),

                    const SizedBox(height: DesignTokens.spaceL),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: DesignTokens.spaceM,
                            mainAxisSpacing: DesignTokens.spaceM,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final outfitNames = [
                          'Parisian Chic',
                          'Business Luxe',
                          'Weekend Casual',
                          'Evening Elegance',
                        ];
                        return OutfitCard(
                          outfitName: outfitNames[index],
                          itemImages: const [
                            'assets/images/fashion/blazer.jpg',
                            'assets/images/fashion/dress.jpg',
                            'assets/images/fashion/accessories.jpg',
                          ],
                          modelImage:
                              'assets/images/fashion/model_${index + 1}.jpg',
                          isFavorite: index == 1,
                          onTap: () {
                            // View style details
                          },
                          onFavorite: () {
                            // Save to favorites
                          },
                          onTryOn: () {
                            // Virtual try-on
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Wardrobe Tab Content
class WardrobeTab extends StatelessWidget {
  const WardrobeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(
        title: 'My Wardrobe',
        hasGlassEffect: true,
        elevation: 2,
        actions: [
          Icon(Icons.search, color: AppColors.neutral600),
          SizedBox(width: DesignTokens.spaceM),
          Icon(Icons.filter_list, color: AppColors.neutral600),
          SizedBox(width: DesignTokens.spaceS),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: DesignTokens.spaceM,
          mainAxisSpacing: DesignTokens.spaceM,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return ModelGridItem(
            imageUrl: 'assets/images/model_$index.jpg',
            modelName: 'Model ${index + 1}',
            outfitCount: '${(index + 1) * 3}',
            onTap: () {
              // View model details
            },
          );
        },
      ),
    );
  }
}

// Try On Tab Content
class TryOnTab extends StatelessWidget {
  const TryOnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.neutralWhite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: AppColors.neutral700,
            ),
            const SizedBox(height: DesignTokens.spaceXL),
            Text(
              'AI Virtual Try-On',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceL),
            Text(
              'Upload your photo to see how clothes look on you',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutral600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.spaceXXL),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NavigationProvider>().push(AppRouter.photoUpload);
              },
              icon: const Icon(Icons.upload),
              label: const Text('Upload Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neutral900,
                foregroundColor: AppColors.neutralWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.spaceXL,
                  vertical: DesignTokens.spaceL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Outfits Tab Content
class OutfitsTab extends StatelessWidget {
  const OutfitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(
        title: 'My Outfits',
        hasGlassEffect: true,
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        children: [
          // Categories
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Favorites', 'Recent', 'Casual', 'Formal']
                  .map(
                    (category) => Container(
                      margin: const EdgeInsets.only(right: DesignTokens.spaceM),
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.spaceL,
                        vertical: DesignTokens.spaceS,
                      ),
                      decoration: BoxDecoration(
                        gradient: category == 'All'
                            ? AppColors.primaryGradient
                            : null,
                        color: category == 'All' ? null : AppColors.neutral100,
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusXXL,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: AppTextStyles.buttonMedium.copyWith(
                            color: category == 'All'
                                ? AppColors.neutralWhite
                                : AppColors.neutral700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // Outfits Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: DesignTokens.spaceM,
              mainAxisSpacing: DesignTokens.spaceM,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return OutfitCard(
                outfitName: 'Summer Look ${index + 1}',
                itemImages: const [
                  'assets/images/item1.jpg',
                  'assets/images/item2.jpg',
                  'assets/images/item3.jpg',
                  'assets/images/item4.jpg',
                ],
                modelImage: 'assets/images/model.jpg',
                isFavorite: index % 3 == 0,
                onTap: () {
                  // View outfit details
                },
                onFavorite: () {
                  // Toggle favorite
                },
                onTryOn: () {
                  // Try on outfit
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// Profile Tab Content
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(
        title: 'Profile',
        hasGlassEffect: true,
        actions: [
          Icon(Icons.settings, color: AppColors.neutral600),
          SizedBox(width: DesignTokens.spaceS),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(
                      DesignTokens.radiusRound,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.neutral700,
                    size: 48,
                  ),
                ),
                const SizedBox(height: DesignTokens.spaceL),
                Text(
                  'Fashion Lover',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
                Text(
                  'AI Stylist Assistant User',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DesignTokens.spaceXXL),

          // Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '42',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        'Outfits',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: DesignTokens.spaceM),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(DesignTokens.spaceL),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusL),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '128',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        'Try-Ons',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: DesignTokens.spaceXL),

          // Settings
          Text(
            'Settings',
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceL),

          // Wishlist Items
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.spaceM),
              child: WishlistItemCard(
                itemName: 'Summer Dress ${index + 1}',
                brand: 'Fashion Brand',
                price: '\$${(index + 1) * 25}',
                imageUrl: 'assets/images/wishlist_$index.jpg',
                isAvailable: index != 1,
                onTap: () {
                  // View item details
                },
                onRemove: () {
                  // Remove from wishlist
                },
                onAddToOutfit: () {
                  // Add to outfit
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
