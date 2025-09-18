import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../design_system/design_tokens.dart';

/// Modern Bottom Navigation Bar with Pinterest-style design
class ModernBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<ModernNavItem> items;

  const ModernBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: DesignTokens.durationMedium,
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0.9, end: 1.1).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          ),
        )
        .toList();

    // Animate current selection on init
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(ModernBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset all animations
    for (var controller in _controllers) {
      controller.reset();
    }

    // Animate new selection
    if (widget.currentIndex < _controllers.length) {
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(DesignTokens.radiusXXL),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralBlack.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.items.asMap().entries.map((entry) {
            final int index = entry.key;
            final ModernNavItem item = entry.value;
            final bool isSelected = index == widget.currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => widget.onTap(index),
                child: AnimatedBuilder(
                  animation: _scaleAnimations[index],
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimations[index].value : 1.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: DesignTokens.spaceS,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icon Container
                            Container(
                              padding: const EdgeInsets.all(
                                DesignTokens.spaceS,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? item.selectedGradient ??
                                          AppColors.primaryGradient
                                    : null,
                                color: isSelected ? null : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  DesignTokens.radiusL,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary500
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected
                                    ? AppColors.neutralWhite
                                    : AppColors.neutral600,
                                size: 24,
                              ),
                            ),

                            const SizedBox(height: DesignTokens.spaceXS),

                            // Label
                            Text(
                              item.label,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: isSelected
                                    ? AppColors.primary500
                                    : AppColors.neutral600,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),

                            // Active Indicator
                            if (isSelected)
                              Container(
                                    width: 4,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                      top: DesignTokens.spaceXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary500,
                                      borderRadius: BorderRadius.circular(
                                        DesignTokens.radiusRound,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 100.ms)
                                  .scale(
                                    delay: 100.ms,
                                    curve: Curves.elasticOut,
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Navigation Item Model
class ModernNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Gradient? selectedGradient;

  const ModernNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.selectedGradient,
  });
}

/// Floating Action Button with Modern Design
class ModernFloatingActionButton extends StatefulWidget {
  final IconData icon;
  final String? heroTag;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color? backgroundColor;

  const ModernFloatingActionButton({
    super.key,
    required this.icon,
    this.heroTag,
    this.onPressed,
    this.gradient,
    this.backgroundColor,
  });

  @override
  State<ModernFloatingActionButton> createState() =>
      _ModernFloatingActionButtonState();
}

class _ModernFloatingActionButtonState extends State<ModernFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: widget.gradient ?? AppColors.primaryGradient,
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXL),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: AppColors.neutralWhite, size: 24),
            ),
          ),
        );
      },
    );
  }
}

/// Modern App Bar with Glass Effect
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool hasGlassEffect;
  final Color? backgroundColor;
  final double elevation;

  const ModernAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.hasGlassEffect = true,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: hasGlassEffect
            ? AppColors.neutralWhite.withOpacity(0.95)
            : backgroundColor ?? AppColors.neutralWhite,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(DesignTokens.radiusXXL),
        ),
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: AppColors.neutralBlack.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceL,
            vertical: DesignTokens.spaceM,
          ),
          child: Row(
            children: [
              // Leading
              if (leading != null)
                leading!
              else
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(DesignTokens.spaceS),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: AppColors.neutral900,
                      size: 18,
                    ),
                  ),
                ),

              const SizedBox(width: DesignTokens.spaceM),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Actions
              if (actions != null)
                Row(mainAxisSize: MainAxisSize.min, children: actions!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gesture-based Page Transition
class ModernPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final String routeName;

  ModernPageRoute({required this.page, required this.routeName})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: DesignTokens.durationMedium,
        reverseTransitionDuration: DesignTokens.durationMedium,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Slide and fade transition
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          var fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: curve));

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        settings: RouteSettings(name: routeName),
      );
}

/// Swipe-to-go-back gesture detector
class SwipeBackDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwipeBack;

  const SwipeBackDetector({super.key, required this.child, this.onSwipeBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          if (onSwipeBack != null) {
            onSwipeBack!.call();
          } else {
            Navigator.pop(context);
          }
        }
      },
      child: child,
    );
  }
}

/// Navigation Helper Functions
class ModernNavigation {
  static void pushPage(BuildContext context, Widget page, {String? routeName}) {
    Navigator.push(
      context,
      ModernPageRoute(
        page: page,
        routeName: routeName ?? page.runtimeType.toString(),
      ),
    );
  }

  static void pushReplacementPage(
    BuildContext context,
    Widget page, {
    String? routeName,
  }) {
    Navigator.pushReplacement(
      context,
      ModernPageRoute(
        page: page,
        routeName: routeName ?? page.runtimeType.toString(),
      ),
    );
  }

  static void popToRoot(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}
