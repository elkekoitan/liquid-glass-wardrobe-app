import 'package:flutter/material.dart';

class TrendPulseBundle {
  const TrendPulseBundle({
    required this.lastUpdated,
    required this.dailyDrop,
    required this.weeklySaga,
    required this.eventTicker,
  });

  final DateTime lastUpdated;
  final TrendDrop dailyDrop;
  final List<TrendSaga> weeklySaga;
  final List<TrendTickerEvent> eventTicker;

  factory TrendPulseBundle.fromMap(Map<String, dynamic> map) {
    return TrendPulseBundle(
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      dailyDrop: TrendDrop.fromMap(map['daily_drop'] as Map<String, dynamic>),
      weeklySaga: (map['weekly_saga'] as List<dynamic>)
          .map((item) => TrendSaga.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
      eventTicker: (map['event_ticker'] as List<dynamic>)
          .map((item) => TrendTickerEvent.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class TrendDrop {
  const TrendDrop({
    required this.id,
    required this.title,
    required this.tagline,
    required this.startUtc,
    required this.endUtc,
    required this.heroImageUrl,
    required this.pinterestBoardId,
    required this.pinterestCurator,
    required this.pinterestHeroPinId,
    required this.accentColors,
    required this.callToActions,
    required this.badges,
  });

  final String id;
  final String title;
  final String tagline;
  final DateTime startUtc;
  final DateTime endUtc;
  final String heroImageUrl;
  final String pinterestBoardId;
  final String pinterestCurator;
  final String pinterestHeroPinId;
  final List<Color> accentColors;
  final List<TrendCallToAction> callToActions;
  final List<String> badges;

  Duration get remainingWindow => endUtc.difference(DateTime.now().toUtc());

  bool get isLive {
    final now = DateTime.now().toUtc();
    return now.isAfter(startUtc) && now.isBefore(endUtc);
  }

  factory TrendDrop.fromMap(Map<String, dynamic> map) {
    return TrendDrop(
      id: map['id'] as String,
      title: map['title'] as String,
      tagline: map['tagline'] as String,
      startUtc: DateTime.parse(map['start_utc'] as String),
      endUtc: DateTime.parse(map['end_utc'] as String),
      heroImageUrl: map['hero_image_url'] as String,
      pinterestBoardId: map['pinterest_board_id'] as String,
      pinterestCurator: map['pinterest_curator'] as String,
      pinterestHeroPinId: map['pinterest_hero_pin_id'] as String,
      accentColors: (map['accent_colors'] as List<dynamic>)
          .map((hex) => _parseColor(hex as String))
          .toList(growable: false),
      callToActions: (map['call_to_actions'] as List<dynamic>)
          .map(
            (item) => TrendCallToAction.fromMap(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      badges: (map['badges'] as List<dynamic>)
          .map((badge) => badge as String)
          .toList(growable: false),
    );
  }
}

class TrendCallToAction {
  const TrendCallToAction({
    required this.label,
    required this.route,
    required this.analyticsTag,
  });

  final String label;
  final String route;
  final String analyticsTag;

  factory TrendCallToAction.fromMap(Map<String, dynamic> map) {
    return TrendCallToAction(
      label: map['label'] as String,
      route: map['route'] as String,
      analyticsTag: map['analytics_tag'] as String,
    );
  }
}

class TrendSaga {
  const TrendSaga({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pinterestBoardId,
    required this.coverImageUrl,
    required this.accentColor,
    required this.beats,
  });

  final String id;
  final String title;
  final String subtitle;
  final String pinterestBoardId;
  final String coverImageUrl;
  final Color accentColor;
  final List<TrendSagaBeat> beats;

  factory TrendSaga.fromMap(Map<String, dynamic> map) {
    return TrendSaga(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      pinterestBoardId: map['pinterest_board_id'] as String,
      coverImageUrl: map['cover_image_url'] as String,
      accentColor: _parseColor(map['accent_color'] as String),
      beats: (map['beats'] as List<dynamic>)
          .map((item) => TrendSagaBeat.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class TrendSagaBeat {
  const TrendSagaBeat({
    required this.stage,
    required this.label,
    required this.description,
    required this.windowUtc,
  });

  final int stage;
  final String label;
  final String description;
  final DateTime windowUtc;

  factory TrendSagaBeat.fromMap(Map<String, dynamic> map) {
    return TrendSagaBeat(
      stage: map['stage'] as int,
      label: map['label'] as String,
      description: map['description'] as String,
      windowUtc: DateTime.parse(map['window_utc'] as String),
    );
  }
}

class TrendTickerEvent {
  const TrendTickerEvent({
    required this.id,
    required this.message,
    required this.accentColor,
    required this.startUtc,
    required this.endUtc,
  });

  final String id;
  final String message;
  final Color accentColor;
  final DateTime startUtc;
  final DateTime endUtc;

  bool get isLive {
    final now = DateTime.now().toUtc();
    return now.isAfter(startUtc) && now.isBefore(endUtc);
  }

  factory TrendTickerEvent.fromMap(Map<String, dynamic> map) {
    return TrendTickerEvent(
      id: map['id'] as String,
      message: map['message'] as String,
      accentColor: _parseColor(map['accent_color'] as String),
      startUtc: DateTime.parse(map['start_utc'] as String),
      endUtc: DateTime.parse(map['end_utc'] as String),
    );
  }
}

Color _parseColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
