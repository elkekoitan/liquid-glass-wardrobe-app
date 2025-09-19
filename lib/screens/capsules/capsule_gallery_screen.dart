import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/capsule_model.dart';
import '../../providers/capsule_provider.dart';
import '../../providers/personalization_provider.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/layout/capsule_quick_picker.dart';

class CapsuleGalleryScreen extends StatelessWidget {
  const CapsuleGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final defaultCapsuleId = context
        .watch<PersonalizationProvider>()
        .defaultCapsule;

    return ChangeNotifierProvider(
      key: ValueKey(defaultCapsuleId),
      create: (_) =>
          CapsuleProvider(initialSelectionId: defaultCapsuleId)..load(),
      child: const _CapsuleGalleryView(),
    );
  }
}

class _CapsuleGalleryView extends StatelessWidget {
  const _CapsuleGalleryView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CapsuleProvider>();
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final LinearGradient backgroundGradient = highContrast
        ? const LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF1C1C1C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : const LinearGradient(
            colors: [Color(0xFF05060B), Color(0xFF101524)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
              ? _ErrorState(message: provider.error!)
              : _GalleryContent(provider: provider),
        ),
      ),
    );
  }
}

class _GalleryContent extends StatelessWidget {
  const _GalleryContent({required this.provider});

  final CapsuleProvider provider;

  @override
  Widget build(BuildContext context) {
    final personalization = context.watch<PersonalizationProvider>();
    final selected = provider.selected;
    final bool highContrast = personalization.highContrast;
    final bool reducedMotion = personalization.reducedMotion;
    final isDefault =
        selected != null && personalization.defaultCapsule == selected.id;

    if (selected == null) {
      return const Center(
        child: Text(
          'No capsules available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final Color refreshIndicatorColor = highContrast
        ? Colors.white
        : Colors.white;
    final Color refreshBackgroundColor = highContrast
        ? Colors.black
        : const Color(0xFF05060B);

    return RefreshIndicator(
      color: refreshIndicatorColor,
      backgroundColor: refreshBackgroundColor,
      onRefresh: () => provider.load(refresh: true),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMarginHorizontal,
          vertical: AppSpacing.screenMarginVertical,
        ),
        children: [
          _Header(selected: selected),
          const SizedBox(height: AppSpacing.xxl),
          _SelectedCapsuleCard(
            capsule: selected,
            isDefault: isDefault,
            onActivate: () async {
              if (isDefault) return;
              final messenger = ScaffoldMessenger.of(context);
              await personalization.updateDefaultCapsule(selected.id);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    '${selected.name} set as your default capsule.',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Weekly Capsules',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CapsuleQuickPicker(
            capsules: provider.capsules,
            onSelect: provider.selectCapsule,
            selectedId: selected.id,
            defaultId: personalization.defaultCapsule,
            reducedMotion: reducedMotion,
            highContrast: highContrast,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _MicrocopyPanel(microcopy: selected.microcopy),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.selected});

  final CapsuleModel selected;

  @override
  Widget build(BuildContext context) {
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final Color labelColor = highContrast
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.white70;
    final Color titleColor = Colors.white;
    final Color iconColor = highContrast ? Colors.white : Colors.white70;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selected.mood.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: labelColor,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Capsule Gallery',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: iconColor),
          onPressed: () {
            Navigator.of(context).pushNamed(AppRouter.personalization);
          },
        ),
      ],
    );
  }
}

class _SelectedCapsuleCard extends StatelessWidget {
  const _SelectedCapsuleCard({
    required this.capsule,
    required this.isDefault,
    required this.onActivate,
  });

  final CapsuleModel capsule;
  final bool isDefault;
  final Future<void> Function()? onActivate;

  @override
  Widget build(BuildContext context) {
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final gradient = _buildGradient(capsule.colorway);
    final Color descriptionColor = highContrast
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white70;
    final Color chipBackground = highContrast
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.12);
    final Color chipText = highContrast ? Colors.black : Colors.white70;
    final Color statusBackground = highContrast
        ? Colors.white.withValues(alpha: 0.28)
        : Colors.white.withValues(alpha: 0.2);
    final Color statusText = highContrast ? Colors.black : Colors.white;
    final Color accentColor = highContrast
        ? Colors.cyanAccent
        : Colors.pinkAccent;
    final Color secondaryIconColor = highContrast
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.white70;
    final List<Color>? glassGradient = highContrast
        ? [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ]
        : null;
    final Color glassBorderColor = highContrast
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.white.withValues(alpha: 0.15);
    final bool canActivate = !isDefault && onActivate != null;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      gradientColors: glassGradient,
      borderColor: glassBorderColor,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: gradient,
              image: capsule.heroImage.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(capsule.heroImage),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.35),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: const SizedBox(),
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: statusBackground,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Default Capsule',
                            style: TextStyle(
                              color: statusText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isDefault) const SizedBox(height: AppSpacing.sm),
                      Text(
                        capsule.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        capsule.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: descriptionColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: capsule.tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                backgroundColor: chipBackground,
                                labelStyle: TextStyle(color: chipText),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  onPressed: canActivate ? () => onActivate!() : null,
                  color: highContrast ? Colors.white : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      isDefault ? 'Active Capsule' : 'Make Default',
                      style: TextStyle(
                        color: highContrast ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              IconButton(
                onPressed: canActivate ? () => onActivate!() : null,
                icon: Icon(
                  isDefault ? Icons.favorite : Icons.favorite_border,
                  color: isDefault ? accentColor : secondaryIconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  LinearGradient _buildGradient(List<String> colors) {
    if (colors.length < 2) {
      return const LinearGradient(
        colors: [Color(0xFF1C1F2B), Color(0xFF0D0F16)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    final parsedColors = colors
        .map((hex) => Color(int.parse(hex.replaceFirst('#', '0xff'))))
        .toList();

    return LinearGradient(
      colors: parsedColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class _MicrocopyPanel extends StatelessWidget {
  const _MicrocopyPanel({required this.microcopy});

  final CapsuleMicrocopy microcopy;

  @override
  Widget build(BuildContext context) {
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final List<Color>? glassGradient = highContrast
        ? [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.05),
          ]
        : null;
    final Color borderColor = highContrast
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.12);
    final Color headingColor = Colors.white;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      borderRadius: BorderRadius.circular(24),
      gradientColors: glassGradient,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Microcopy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: headingColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _MicrocopyRow(label: 'Prompt', value: microcopy.prompt),
          _MicrocopyRow(label: 'Success', value: microcopy.success),
          _MicrocopyRow(label: 'Error', value: microcopy.error),
        ],
      ),
    );
  }
}

class _MicrocopyRow extends StatelessWidget {
  const _MicrocopyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final Color labelColor = highContrast
        ? Colors.white.withValues(alpha: 0.85)
        : Colors.white54;
    final Color valueColor = highContrast
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white70;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: labelColor,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: valueColor, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 40),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load capsules',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
