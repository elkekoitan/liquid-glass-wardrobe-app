import 'dart:developer' as developer;

/// Simple analytics service placeholder
/// Logs events to console and can be expanded to integrate with real providers.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  /// Initialize analytics service. Currently no-op but kept for future expansion.
  Future<void> initialize() async {
    // Hook for future async initialization
  }

  /// Logs an analytics event with optional parameters.
  void logEvent(String name, {Map<String, Object?> parameters = const {}}) {
    developer.log('AnalyticsEvent', name: name, error: parameters.isEmpty ? null : parameters);
  }
}
