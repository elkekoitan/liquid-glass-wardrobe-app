import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/design_tokens.dart';
import '../../features/trend_pulse/domain/trend_pulse_models.dart';
import '../glass_container.dart';

class TrendEventMarquee extends StatefulWidget {
  const TrendEventMarquee({
    super.key,
    required this.events,
    required this.highContrast,
    required this.reducedMotion,
    required this.onEventFocus,
  });

  final List<TrendTickerEvent> events;
  final bool highContrast;
  final bool reducedMotion;
  final ValueChanged<TrendTickerEvent> onEventFocus;

  @override
  State<TrendEventMarquee> createState() => _TrendEventMarqueeState();
}

class _TrendEventMarqueeState extends State<TrendEventMarquee> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.events.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onEventFocus(widget.events[_index]);
      });
    }
    _setupTimer();
  }

  @override
  void didUpdateWidget(covariant TrendEventMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reducedMotion != oldWidget.reducedMotion ||
        widget.events.length != oldWidget.events.length) {
      _timer?.cancel();
      _setupTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupTimer() {
    if (widget.reducedMotion || widget.events.length <= 1) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      setState(() {
        _index = (_index + 1) % widget.events.length;
      });
      widget.onEventFocus(widget.events[_index]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.events.isEmpty) {
      return const SizedBox.shrink();
    }

    final TrendTickerEvent event = widget.events[_index % widget.events.length];
    final Color baseColor = widget.highContrast
        ? Colors.black
        : event.accentColor.withValues(alpha: 0.88);
    final Color textColor = widget.highContrast ? Colors.white : Colors.black;

    final Widget badge = GlassContainer.light(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceL,
        vertical: DesignTokens.spaceM,
      ),
      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      gradientColors: widget.highContrast
          ? [Colors.black, Colors.black]
          : [baseColor, baseColor.withValues(alpha: 0.72)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: DesignTokens.spaceM),
            decoration: BoxDecoration(
              color: widget.highContrast ? Colors.white : Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              event.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.spaceL),
          _LivePill(isLive: event.isLive, highContrast: widget.highContrast),
        ],
      ),
    );

    if (widget.reducedMotion) {
      return badge;
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: KeyedSubtree(key: ValueKey(event.id), child: badge),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill({required this.isLive, required this.highContrast});

  final bool isLive;
  final bool highContrast;

  @override
  Widget build(BuildContext context) {
    final Color bg = isLive
        ? (highContrast ? Colors.white : Colors.black)
        : (highContrast
              ? Colors.white.withValues(alpha: 0.24)
              : Colors.black.withValues(alpha: 0.24));
    final Color fg = isLive
        ? (highContrast ? Colors.black : Colors.white)
        : (highContrast ? Colors.white : Colors.black.withValues(alpha: 0.7));
    final String label = isLive ? 'LIVE' : 'SOON';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.spaceM,
        vertical: DesignTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.radiusRound),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
