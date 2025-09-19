import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../design_system/design_tokens.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/personalization_provider.dart';
import '../../providers/trend_pulse_provider.dart';
import '../../widgets/glass_button.dart';
import '../../widgets/glass_container.dart';
import '../../features/trend_pulse/domain/trend_pulse_models.dart';
import '../../widgets/trends/trend_drop_card.dart';
import '../../widgets/trends/trend_event_marquee.dart';
import '../../widgets/trends/trend_saga_tile.dart';

class TrendPulseScreen extends StatelessWidget {
  const TrendPulseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool highContrast = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.highContrast,
    );
    final bool reducedMotion = context.select<PersonalizationProvider, bool>(
      (prefs) => prefs.reducedMotion,
    );
    final TrendPulseProvider provider = context.watch<TrendPulseProvider>();

    return Scaffold(
      backgroundColor: highContrast ? Colors.black : const Color(0xFFF4F5FF),
      body: Container(
        decoration: highContrast
            ? null
            : const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF5F5FF), Color(0xFFE7E4FF)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.spaceL),
            child: AnimatedSwitcher(
              duration: reducedMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _buildState(
                context,
                provider,
                highContrast: highContrast,
                reducedMotion: reducedMotion,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildState(
    BuildContext context,
    TrendPulseProvider provider, {
    required bool highContrast,
    required bool reducedMotion,
  }) {
    switch (provider.status) {
      case TrendPulseStatus.initial:
      case TrendPulseStatus.loading:
        return _buildLoading(highContrast: highContrast);
      case TrendPulseStatus.error:
        return _buildError(context, provider, highContrast: highContrast);
      case TrendPulseStatus.ready:
        return _buildContent(
          context,
          provider,
          highContrast: highContrast,
          reducedMotion: reducedMotion,
        );
    }
  }

  Widget _buildLoading({required bool highContrast}) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        gradientColors: [
          highContrast ? Colors.black : const Color(0xFF2E1340),
          highContrast ? Colors.black : const Color(0xFF6E3AE2),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                highContrast ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              'Dialing in the drop...',
              style: TextStyle(
                color: highContrast ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    TrendPulseProvider provider, {
    required bool highContrast,
  }) {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        gradientColors: [
          highContrast ? Colors.black : const Color(0xFF2E1340),
          highContrast ? Colors.black : const Color(0xFF6E3AE2),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 36,
              color: highContrast
                  ? Colors.white
                  : Colors.black.withValues(alpha: 0.7),
            ),
            const SizedBox(height: DesignTokens.spaceM),
            Text(
              'Trend Pulse couldn\'t sync',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: highContrast ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: DesignTokens.spaceS),
            Text(
              provider.error ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: highContrast
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.black.withValues(alpha: 0.64),
              ),
            ),
            const SizedBox(height: DesignTokens.spaceL),
            GlassButton(
              onPressed: () => provider.load(refresh: true),
              child: Text(
                'Retry',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TrendPulseProvider provider, {
    required bool highContrast,
    required bool reducedMotion,
  }) {
    final drop = provider.dailyDrop;
    final navigation = context.read<NavigationProvider?>();

    if (drop == null) {
      return _buildError(context, provider, highContrast: highContrast);
    }

    final sagas = provider.weeklySaga;
    final events = provider.eventTicker;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, highContrast: highContrast),
          const SizedBox(height: DesignTokens.spaceL),
          TrendDropCard(
            drop: drop,
            highContrast: highContrast,
            reducedMotion: reducedMotion,
            onCtaTap: (cta) {
              provider.recordCtaTap(cta);
              navigation?.push(cta.route);
            },
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          _buildEnergyMeter(context, provider, highContrast: highContrast),
          const SizedBox(height: DesignTokens.spaceXL),
          _buildSagaSection(
            context,
            provider,
            sagas,
            highContrast: highContrast,
            reducedMotion: reducedMotion,
          ),
          const SizedBox(height: DesignTokens.spaceXL),
          _buildTickerSection(
            context,
            provider,
            events,
            highContrast: highContrast,
            reducedMotion: reducedMotion,
          ),
          const SizedBox(height: DesignTokens.spaceXXL),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool highContrast}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trend Pulse Arcade',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: highContrast ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: DesignTokens.spaceS),
              Text(
                'Daily drops, weekly sagas, pure hype. Curated straight from Pinterest boards you can trace.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: highContrast
                      ? Colors.white.withValues(alpha: 0.78)
                      : Colors.black.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: DesignTokens.spaceM),
        Icon(
          Icons.auto_awesome_motion,
          color: highContrast
              ? Colors.white
              : Colors.black.withValues(alpha: 0.7),
          size: 28,
        ),
      ],
    );
  }

  Widget _buildSagaSection(
    BuildContext context,
    TrendPulseProvider provider,
    List<TrendSaga> sagas, {
    required bool highContrast,
    required bool reducedMotion,
  }) {
    if (sagas.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.spaceL),
        borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        child: Text(
          'Saga threads refresh with each Pinterest playlist drop.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: highContrast
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.64),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Saga',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: highContrast ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceM),
        SizedBox(
          height: 320,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final saga = sagas[index];
              return SizedBox(
                width: 260,
                child: TrendSagaTile(
                  saga: saga,
                  highContrast: highContrast,
                  reducedMotion: reducedMotion,
                  onFocused: () => provider.recordSagaFocus(saga),
                ),
              );
            },
            separatorBuilder: (_, __) =>
                const SizedBox(width: DesignTokens.spaceL),
            itemCount: sagas.length,
          ),
        ),
      ],
    );
  }

  Widget _buildTickerSection(
    BuildContext context,
    TrendPulseProvider provider,
    List<TrendTickerEvent> events, {
    required bool highContrast,
    required bool reducedMotion,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Ticker',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: highContrast ? Colors.white : Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: DesignTokens.spaceM),
        TrendEventMarquee(
          events: events,
          highContrast: highContrast,
          reducedMotion: reducedMotion,
          onEventFocus: (event) => provider.recordTickerInteraction(event),
        ),
      ],
    );
  }

  Widget _buildEnergyMeter(
    BuildContext context,
    TrendPulseProvider provider, {
    required bool highContrast,
  }) {
    final now = DateTime.now().toUtc();
    final liveScore = provider.eventTicker
        .where((event) => event.isLive)
        .length;
    final sagaScore = provider.weeklySaga.length;
    final total = (liveScore * 2 + sagaScore).clamp(0, 10);
    final double progress = total / 10;

    return GlassContainer(
      padding: const EdgeInsets.all(DesignTokens.spaceL),
      borderRadius: BorderRadius.circular(DesignTokens.radiusL),
      gradientColors: highContrast
          ? [Colors.black, Colors.black]
          : [
              const Color(0xFF2E1340).withValues(alpha: 0.8),
              const Color(0xFF6E3AE2).withValues(alpha: 0.6),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arcade Energy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: DesignTokens.spaceS),
          Text(
            '$liveScore live events • $sagaScore saga threads',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceM),
          ClipRRect(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                highContrast ? Colors.white : const Color(0xFFFF6EC7),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.spaceS),
          Text(
            'Synced ${_relativeTime(provider.lastLoaded ?? now)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) {
      return 'just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} minutes ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    }
    return '${diff.inDays} days ago';
  }
}
