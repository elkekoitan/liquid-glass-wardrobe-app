import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/wardrobe_item.dart';
import '../outfit_stack.dart';
import '../wardrobe_panel.dart';

/// Bundles the canvas action stack and wardrobe entry points.
class TryOnActionRail extends StatelessWidget {
  const TryOnActionRail({
    super.key,
    required this.onInitiateColorChange,
    required this.onGarmentSelect,
    this.header,
    this.footer,
  });

  final void Function(int layerIndex) onInitiateColorChange;
  final Future<void> Function(File file, WardrobeItem garment) onGarmentSelect;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) header!,
        OutfitStack(onInitiateColorChange: onInitiateColorChange),
        const SizedBox(height: AppSpacing.lg),
        WardrobePanel(onGarmentSelect: onGarmentSelect),
        if (footer != null) ...[const SizedBox(height: AppSpacing.lg), footer!],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
