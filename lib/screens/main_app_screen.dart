
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fit_check_provider.dart';
import '../screens/start_screen.dart';
import '../screens/canvas_screen.dart';
import '../widgets/wardrobe_panel.dart';
import '../widgets/outfit_stack.dart';
import '../widgets/color_variation_panel.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Main App Screen - Orchestrates the entire fit-check experience
class MainAppScreen extends StatefulWidget {
  final String geminiApiKey;

  const MainAppScreen({super.key, required this.geminiApiKey});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  AppScreen _currentScreen = AppScreen.start;

  @override
  void initState() {
    super.initState();
    // Initialize Gemini service with API key
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitCheckProvider>().initializeGeminiService(
        widget.geminiApiKey,
      );
    });
  }

  void _navigateToCanvas() {
    setState(() {
      _currentScreen = AppScreen.canvas;
    });
  }

  void _navigateToStart() {
    setState(() {
      _currentScreen = AppScreen.start;
    });
  }

  void _showColorPanel(int layerIndex) {
    final provider = context.read<FitCheckProvider>();
    final layer = provider.outfitHistory[layerIndex];

    if (layer.garment == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ColorVariationPanel(
        layerIndex: layerIndex,
        garmentName: layer.garment!.name,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showPosePanel() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          PoseSelectionPanel(onClose: () => Navigator.of(context).pop()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FitCheckProvider>(
        builder: (context, provider, child) {
          // Show start screen if no model image
          if (_currentScreen == AppScreen.start ||
              provider.modelImageUrl == null) {
            return StartScreen(onModelFinalized: _navigateToCanvas);
          }

          // Main try-on interface
          return _buildTryOnInterface(provider);
        },
      ),
    );
  }

  Widget _buildTryOnInterface(FitCheckProvider provider) {
    return Column(
      children: [
        // Main canvas area
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Canvas screen
              const CanvasScreen(),

              // Pose selection button (floating)
              Positioned(
                top: AppSpacing.lg,
                right: AppSpacing.lg,
                child: FloatingActionButton.small(
                  onPressed: provider.isLoading ? null : _showPosePanel,
                  backgroundColor: AppColors.primary,
                  tooltip: 'Change Pose',
                  child: Icon(Icons.accessibility_new, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Bottom panels (scrollable)
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.surfaceVariant.withOpacity(0.3),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  // Outfit Stack
                  OutfitStack(onInitiateColorChange: _showColorPanel),

                  const SizedBox(height: AppSpacing.lg),

                  // Wardrobe Panel
                  WardrobePanel(
                    onGarmentSelect: (file, garmentInfo) async {
                      // Apply garment through provider
                      await provider.applyGarment(file, garmentInfo);
                    },
                  ),

                  // Bottom padding for safe area
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum AppScreen { start, canvas }
