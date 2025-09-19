import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/fit_check_provider.dart';
import '../screens/start_screen.dart';
import '../screens/canvas_screen.dart';
import '../widgets/color_variation_panel.dart';
import '../design_system/components/personalized_scaffold.dart';
import '../widgets/layout/try_on_action_rail.dart';
import '../widgets/layout/main_section_header.dart';
import '../widgets/layout/capsule_quick_picker.dart';
import '../providers/personalization_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/capsule_provider.dart';
import '../core/theme/app_spacing.dart';

/// Main App Screen - Orchestrates the entire fit-check experience
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  AppScreen _currentScreen = AppScreen.start;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
      if (geminiApiKey != null && geminiApiKey.isNotEmpty) {
        context.read<FitCheckProvider>().initializeGeminiService(geminiApiKey);
      } else {
        debugPrint(
          'Warning: GEMINI_API_KEY not found in environment variables',
        );
      }
    });
  }

  void _navigateToCanvas() {
    setState(() {
      _currentScreen = AppScreen.canvas;
    });
  }

  void _showColorPanel(int layerIndex) {
    final provider = context.read<FitCheckProvider>();
    final layer = provider.outfitHistory[layerIndex];

    if (layer.garment == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ColorVariationPanel(
        layerIndex: layerIndex,
        garmentName: layer.garment!.name,
        onClose: () => dialogContext.read<NavigationProvider>().pop(),
      ),
    );
  }

  void _showPosePanel() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) =>
          PoseSelectionPanel(onClose: () => dialogContext.read<NavigationProvider>().pop()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FitCheckProvider>(
      builder: (context, provider, child) {
        if (_currentScreen == AppScreen.start ||
            provider.modelImageUrl == null) {
          return StartScreen(onModelFinalized: _navigateToCanvas);
        }

        return PersonalizedScaffold(
          padding: const EdgeInsets.all(AppSpacing.lg),
          useSafeArea: false,
          body: _buildTryOnInterface(provider),
        );
      },
    );
  }

  Widget _buildTryOnInterface(FitCheckProvider provider) {
    final reducedMotion = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.reducedMotion,
    );
    final highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final defaultCapsuleId = context.select<PersonalizationProvider, String>(
      (prefs) => prefs.defaultCapsule,
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MainSectionHeader(
            title: 'Your Virtual Studio',
            subtitle: provider.error ?? 'Adjust outfits, colors, and poses.',
            actions: [
              IconButton(
                tooltip: 'Change pose',
                onPressed: provider.isLoading ? null : _showPosePanel,
                icon: const Icon(Icons.accessibility_new),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Expanded(flex: 3, child: CanvasScreen()),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: TryOnActionRail(
                onInitiateColorChange: (index) => _showColorPanel(index),
                onGarmentSelect: (file, garment) =>
                    provider.applyGarment(file, garment),
                header: _CapsuleRail(
                  defaultCapsuleId: defaultCapsuleId,
                  highContrast: highContrast,
                  reducedMotion: reducedMotion,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapsuleRail extends StatefulWidget {
  const _CapsuleRail({
    required this.defaultCapsuleId,
    required this.highContrast,
    required this.reducedMotion,
  });

  final String defaultCapsuleId;
  final bool highContrast;
  final bool reducedMotion;

  @override
  State<_CapsuleRail> createState() => _CapsuleRailState();
}

class _CapsuleRailState extends State<_CapsuleRail> {
  late CapsuleProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CapsuleProvider(initialSelectionId: widget.defaultCapsuleId)
      ..load();
  }

  @override
  void didUpdateWidget(covariant _CapsuleRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultCapsuleId != widget.defaultCapsuleId) {
      _provider = CapsuleProvider(initialSelectionId: widget.defaultCapsuleId)
        ..load();
    }
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CapsuleProvider>.value(
      value: _provider,
      child: Consumer<CapsuleProvider>(
        builder: (context, capsuleProvider, _) {
          if (capsuleProvider.isLoading) {
            return const SizedBox(
              height: 160,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (capsuleProvider.capsules.isEmpty) {
            return const SizedBox.shrink();
          }

          final String selectedId =
              capsuleProvider.selected?.id ?? widget.defaultCapsuleId;

          return CapsuleQuickPicker(
            capsules: capsuleProvider.capsules,
            selectedId: selectedId,
            defaultId: widget.defaultCapsuleId,
            reducedMotion: widget.reducedMotion,
            highContrast: widget.highContrast,
            onSelect: (id) {
              capsuleProvider.selectCapsule(id);
              context.read<PersonalizationProvider>().updateDefaultCapsule(id);
            },
          );
        },
      ),
    );
  }
}

enum AppScreen { start, canvas }
