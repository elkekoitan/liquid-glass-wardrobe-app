import 'package:flutter/foundation.dart';

import '../features/trend_pulse/data/trend_pulse_service.dart';
import '../features/trend_pulse/domain/trend_pulse_models.dart';
import '../services/analytics_service.dart';

typedef TrendPulseLoader =
    Future<TrendPulseBundle> Function({bool forceRefresh});

enum TrendPulseStatus { initial, loading, ready, error }

class TrendPulseProvider extends ChangeNotifier {
  TrendPulseProvider({
    TrendPulseService? service,
    TrendPulseLoader? loader,
    AnalyticsService? analytics,
  }) : _service = service ?? TrendPulseService.instance,
       _loaderOverride = loader,
       _analytics = analytics ?? AnalyticsService.instance;

  final TrendPulseService _service;
  final TrendPulseLoader? _loaderOverride;
  final AnalyticsService _analytics;

  TrendPulseStatus _status = TrendPulseStatus.initial;
  TrendPulseBundle? _bundle;
  String? _error;
  DateTime? _lastLoaded;

  TrendPulseStatus get status => _status;
  TrendPulseBundle? get bundle => _bundle;
  TrendDrop? get dailyDrop => _bundle?.dailyDrop;
  List<TrendSaga> get weeklySaga => _bundle?.weeklySaga ?? const [];
  List<TrendTickerEvent> get eventTicker => _bundle?.eventTicker ?? const [];
  String? get error => _error;
  DateTime? get lastLoaded => _lastLoaded;

  bool get hasContent => _bundle != null;

  Future<void> load({bool refresh = false}) async {
    if (_status == TrendPulseStatus.loading) return;
    if (!refresh && _bundle != null) return;

    _status = TrendPulseStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final bundle = await _loadBundle(forceRefresh: refresh);
      _bundle = bundle;
      _lastLoaded = DateTime.now();
      _status = TrendPulseStatus.ready;
      notifyListeners();

      _analytics.logEvent(
        'trend_pulse_loaded',
        parameters: {
          'daily_drop_id': bundle.dailyDrop.id,
          'saga_count': bundle.weeklySaga.length,
          'ticker_count': bundle.eventTicker.length,
          'refreshed': refresh,
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Failed to load Trend Pulse: $error');
      debugPrintStack(stackTrace: stackTrace);
      _error = error.toString();
      _status = TrendPulseStatus.error;
      notifyListeners();

      _analytics.logEvent(
        'trend_pulse_load_failed',
        parameters: {'error': _error ?? 'unknown'},
      );
    }
  }

  void recordCtaTap(TrendCallToAction cta) {
    _analytics.logEvent(
      'trend_pulse_cta_tap',
      parameters: {
        'cta_label': cta.label,
        'cta_route': cta.route,
        'cta_tag': cta.analyticsTag,
        'daily_drop_id': dailyDrop?.id,
      },
    );
  }

  void recordSagaFocus(TrendSaga saga) {
    _analytics.logEvent(
      'trend_pulse_saga_focus',
      parameters: {
        'saga_id': saga.id,
        'pinterest_board_id': saga.pinterestBoardId,
      },
    );
  }

  void recordTickerInteraction(
    TrendTickerEvent event, {
    String action = 'view',
  }) {
    _analytics.logEvent(
      'trend_pulse_ticker',
      parameters: {
        'event_id': event.id,
        'action': action,
        'live': event.isLive,
      },
    );
  }

  Future<TrendPulseBundle> _loadBundle({required bool forceRefresh}) {
    final loader = _loaderOverride;
    if (loader != null) {
      return loader(forceRefresh: forceRefresh);
    }
    return _service.loadPulse(forceRefresh: forceRefresh);
  }
}
