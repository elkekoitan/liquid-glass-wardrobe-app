import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/capsule_model.dart';
import '../../providers/personalization_provider.dart';
import '../../services/capsule_service.dart';

class PersonalizationSettingsScreen extends StatelessWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PersonalizationSettingsView();
  }
}

class _PersonalizationSettingsView extends StatelessWidget {
  const _PersonalizationSettingsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PersonalizationProvider>();

    if (!provider.hasLoaded && !provider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PersonalizationProvider>().load();
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Personalization & Comfort'),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF06070F), Color(0xFF13192B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenMarginHorizontal,
                    vertical: AppSpacing.screenMarginVertical,
                  ),
                  children: [
                    _SectionHeader(
                      title: 'Comfort',
                      subtitle:
                          'Adjust motion, contrast, haptics, and sound to match your ritual.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _SwitchTile(
                      title: 'Reduced Motion',
                      subtitle:
                          'Calmer transitions and fewer parallax effects.',
                      value: provider.reducedMotion,
                      onChanged: provider.toggleReducedMotion,
                    ),
                    _SwitchTile(
                      title: 'High Contrast Mode',
                      subtitle:
                          'Strong contrast and solid backgrounds for legibility.',
                      value: provider.highContrast,
                      onChanged: provider.toggleHighContrast,
                    ),
                    _SwitchTile(
                      title: 'Sound Effects',
                      subtitle:
                          'Soft chimes for success and gentle cues for errors.',
                      value: provider.soundEffects,
                      onChanged: provider.toggleSoundEffects,
                    ),
                    _SwitchTile(
                      title: 'Haptics',
                      subtitle:
                          'Tactile feedback for digits, success, and alerts.',
                      value: provider.haptics,
                      onChanged: provider.toggleHaptics,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionHeader(
                      title: 'Default Capsule',
                      subtitle:
                          'Pick the mood that greets you for daily verification.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FutureBuilder<List<CapsuleModel>>(
                      future: CapsuleService.instance.loadCapsules(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xl),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final capsules = snapshot.data!;
                        return Column(
                          children: capsules
                              .map(
                                (capsule) => RadioListTile<String>(
                                  value: capsule.id,
                                  groupValue: provider.defaultCapsule,
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.updateDefaultCapsule(value);
                                    }
                                  },
                                  activeColor: Colors.white,
                                  title: Text(
                                    capsule.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    capsule.microcopy.prompt,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  secondary: CircleAvatar(
                                    backgroundImage: AssetImage(
                                      capsule.heroImage,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
        ),
      ],
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      activeColor: Colors.white,
      activeTrackColor: Colors.white24,
      contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: Colors.white60),
      ),
    );
  }
}
