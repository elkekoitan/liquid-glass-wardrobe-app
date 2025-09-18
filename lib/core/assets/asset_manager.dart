/// Professional Asset Management System for Fashion/AI App
/// Provides centralized asset organization and management
class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // === IMAGE ASSETS ===
  
  /// Main image assets folder
  static const String _images = 'assets/images';
  
  /// Fashion category images
  static const String _fashion = '$_images/fashion';
  
  /// Category icons and images
  static const String _categories = '$_images/categories';
  
  /// Onboarding screen assets
  static const String _onboarding = '$_images/onboarding';
  
  /// Wardrobe item images
  static const String _wardrobe = '$_images/wardrobe';
  
  /// Model photos for AI try-on
  static const String _models = '$_images/models';

  // === MAIN IMAGES ===
  static const String modelPhoto = '$_images/model.jpg';
  static const String model0 = '$_images/model_0.jpg';
  static const String model1 = '$_images/model_1.jpg';
  static const String model2 = '$_images/model_2.jpg';
  static const String model3 = '$_images/model_3.jpg';
  static const String model4 = '$_images/model_4.jpg';
  static const String model5 = '$_images/model_5.jpg';
  static const String model6 = '$_images/model_6.jpg';
  static const String model7 = '$_images/model_7.jpg';

  // Sample items for demos
  static const String item1 = '$_images/item1.jpg';
  static const String item2 = '$_images/item2.jpg';
  static const String item3 = '$_images/item3.jpg';

  // Wishlist/favorites assets
  static const String wishlist0 = '$_images/wishlist_0.jpg';
  static const String wishlist1 = '$_images/wishlist_1.jpg';
  static const String wishlist2 = '$_images/wishlist_2.jpg';

  // === FASHION CATEGORY ASSETS ===
  static const String fashionDresses = '$_fashion/dresses';
  static const String fashionTops = '$_fashion/tops';
  static const String fashionBottoms = '$_fashion/bottoms';
  static const String fashionShoes = '$_fashion/shoes';
  static const String fashionAccessories = '$_fashion/accessories';
  static const String fashionOuterwear = '$_fashion/outerwear';
  
  // === CATEGORY ICONS ===
  static const String categoryWomen = '$_categories/women.svg';
  static const String categoryMen = '$_categories/men.svg';
  static const String categoryKids = '$_categories/kids.svg';
  static const String categoryAccessories = '$_categories/accessories.svg';
  static const String categoryShoes = '$_categories/shoes.svg';
  static const String categorySale = '$_categories/sale.svg';
  
  // === ONBOARDING ASSETS ===
  static const String onboardingWelcome = '$_onboarding/welcome.svg';
  static const String onboardingTryOn = '$_onboarding/try_on.svg';
  static const String onboardingAI = '$_onboarding/ai_features.svg';
  static const String onboardingPersonalize = '$_onboarding/personalize.svg';

  // === WARDROBE ASSETS ===
  static const String wardrobePlaceholder = '$_wardrobe/placeholder.svg';
  static const String wardrobeEmpty = '$_wardrobe/empty_state.svg';
  
  // === ICONS ===
  static const String _icons = 'assets/icons';
  
  // Navigation icons
  static const String iconHome = '$_icons/home.svg';
  static const String iconWardrobe = '$_icons/wardrobe.svg';
  static const String iconCamera = '$_icons/camera.svg';
  static const String iconOutfits = '$_icons/outfits.svg';
  static const String iconProfile = '$_icons/profile.svg';
  
  // Feature icons
  static const String iconTryOn = '$_icons/try_on.svg';
  static const String iconShare = '$_icons/share.svg';
  static const String iconFavorite = '$_icons/favorite.svg';
  static const String iconSearch = '$_icons/search.svg';
  static const String iconFilter = '$_icons/filter.svg';
  static const String iconSort = '$_icons/sort.svg';
  
  // Social icons
  static const String iconLike = '$_icons/like.svg';
  static const String iconComment = '$_icons/comment.svg';
  static const String iconFollow = '$_icons/follow.svg';
  
  // === ANIMATIONS ===
  static const String _animations = 'assets/animations';
  
  static const String animationLoading = '$_animations/loading.json';
  static const String animationSuccess = '$_animations/success.json';
  static const String animationError = '$_animations/error.json';
  static const String animationEmpty = '$_animations/empty.json';
  static const String animationCamera = '$_animations/camera.json';
  static const String animationAI = '$_animations/ai_processing.json';
  static const String animationTryOn = '$_animations/try_on.json';
  static const String animationHeartbeat = '$_animations/heartbeat.json';
  static const String animationSparkle = '$_animations/sparkle.json';
  
  // === SHADER ASSETS ===
  static const String _shaders = 'shaders';
  
  static const String shaderLiquidGlass = '$_shaders/liquid_glass.frag';
  static const String shaderWaveEffect = '$_shaders/wave_effect.frag';
  static const String shaderRefraction = '$_shaders/refraction.frag';
  static const String shaderBlur = '$_shaders/blur.frag';
  static const String shaderGlow = '$_shaders/glow.frag';
  
  // === UTILITY METHODS ===
  
  /// Get all model images as a list
  static List<String> get allModelImages => [
    modelPhoto,
    model0,
    model1,
    model2,
    model3,
    model4,
    model5,
    model6,
    model7,
  ];
  
  /// Get all item images as a list
  static List<String> get allItemImages => [
    item1,
    item2,
    item3,
  ];
  
  /// Get all wishlist images as a list
  static List<String> get allWishlistImages => [
    wishlist0,
    wishlist1,
    wishlist2,
  ];
  
  /// Get category icons as a map
  static Map<String, String> get categoryIcons => {
    'women': categoryWomen,
    'men': categoryMen,
    'kids': categoryKids,
    'accessories': categoryAccessories,
    'shoes': categoryShoes,
    'sale': categorySale,
  };
  
  /// Get onboarding assets as a list
  static List<String> get onboardingAssets => [
    onboardingWelcome,
    onboardingTryOn,
    onboardingAI,
    onboardingPersonalize,
  ];
  
  /// Get navigation icons as a map
  static Map<String, String> get navigationIcons => {
    'home': iconHome,
    'wardrobe': iconWardrobe,
    'camera': iconCamera,
    'outfits': iconOutfits,
    'profile': iconProfile,
  };
  
  /// Get feature icons as a map
  static Map<String, String> get featureIcons => {
    'try_on': iconTryOn,
    'share': iconShare,
    'favorite': iconFavorite,
    'search': iconSearch,
    'filter': iconFilter,
    'sort': iconSort,
  };
  
  /// Get social icons as a map
  static Map<String, String> get socialIcons => {
    'like': iconLike,
    'comment': iconComment,
    'follow': iconFollow,
  };
  
  /// Get animation assets as a map
  static Map<String, String> get animations => {
    'loading': animationLoading,
    'success': animationSuccess,
    'error': animationError,
    'empty': animationEmpty,
    'camera': animationCamera,
    'ai': animationAI,
    'try_on': animationTryOn,
    'heartbeat': animationHeartbeat,
    'sparkle': animationSparkle,
  };
  
  /// Get shader assets as a map
  static Map<String, String> get shaders => {
    'liquid_glass': shaderLiquidGlass,
    'wave_effect': shaderWaveEffect,
    'refraction': shaderRefraction,
    'blur': shaderBlur,
    'glow': shaderGlow,
  };
  
  /// Get random model image
  static String getRandomModelImage() {
    final random = (DateTime.now().millisecondsSinceEpoch % allModelImages.length);
    return allModelImages[random];
  }
  
  /// Check if asset exists (utility method for development)
  static bool assetExists(String path) {
    try {
      // In production, this would check actual asset existence
      // For now, return true for all defined paths
      return _getAllAssets().contains(path);
    } catch (e) {
      return false;
    }
  }
  
  /// Get all defined assets (for validation)
  static List<String> _getAllAssets() {
    return [
      ...allModelImages,
      ...allItemImages,
      ...allWishlistImages,
      ...categoryIcons.values,
      ...onboardingAssets,
      ...navigationIcons.values,
      ...featureIcons.values,
      ...socialIcons.values,
      ...animations.values,
      ...shaders.values,
      wardrobePlaceholder,
      wardrobeEmpty,
    ];
  }
  
  /// Get assets by category for easy organization
  static Map<String, List<String>> get assetsByCategory => {
    'models': allModelImages,
    'items': allItemImages,
    'wishlist': allWishlistImages,
    'category_icons': categoryIcons.values.toList(),
    'onboarding': onboardingAssets,
    'navigation_icons': navigationIcons.values.toList(),
    'feature_icons': featureIcons.values.toList(),
    'social_icons': socialIcons.values.toList(),
    'animations': animations.values.toList(),
    'shaders': shaders.values.toList(),
  };
}

/// Asset path validator and helper utilities
class AssetHelper {
  AssetHelper._();
  
  /// Validate if an asset path is properly formatted
  static bool isValidAssetPath(String path) {
    return path.startsWith('assets/') && path.contains('.');
  }
  
  /// Get file extension from asset path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
  
  /// Check if asset is an image
  static bool isImageAsset(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'svg', 'webp'].contains(extension);
  }
  
  /// Check if asset is an animation (Lottie)
  static bool isAnimationAsset(String path) {
    return getFileExtension(path) == 'json' && path.contains('animations');
  }
  
  /// Check if asset is a shader
  static bool isShaderAsset(String path) {
    return getFileExtension(path) == 'frag' && path.contains('shaders');
  }
  
  /// Get asset category from path
  static String getAssetCategory(String path) {
    if (path.contains('/images/')) {
      if (path.contains('/fashion/')) return 'fashion';
      if (path.contains('/categories/')) return 'categories';
      if (path.contains('/onboarding/')) return 'onboarding';
      if (path.contains('/wardrobe/')) return 'wardrobe';
      return 'images';
    }
    
    if (path.contains('/icons/')) return 'icons';
    if (path.contains('/animations/')) return 'animations';
    if (path.contains('shaders/')) return 'shaders';
    
    return 'unknown';
  }
}