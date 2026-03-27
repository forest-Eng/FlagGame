import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logScreenView() async {
    await _analytics.logScreenView(screenName: 'flag_game');
  }

  static Future<void> logGameStart() async {
    await _analytics.logEvent(name: 'game_start');
  }

  static Future<void> logCorrectTap(String instruction) async {
    await _analytics.logEvent(
      name: 'tap_correct',
      parameters: <String, Object>{
        'instruction': instruction,
      },
    );
  }

  static Future<void> logWrongTap(String instruction) async {
    await _analytics.logEvent(
      name: 'tap_wrong',
      parameters: <String, Object>{
        'instruction': instruction,
      },
    );
  }

  static Future<void> logTimeoutNext(String instruction) async {
    await _analytics.logEvent(
      name: 'timeout_next',
      parameters: <String, Object>{
        'instruction': instruction,
      },
    );
  }

  static Future<void> logGameEnd({
    required int score,
    required int missCount,
    required int timeoutCount,
    required DateTime? gameStartTime,
  }) async {
    final int playSeconds = gameStartTime == null
        ? 0
        : DateTime.now().difference(gameStartTime).inSeconds;

    await _analytics.logEvent(
      name: 'game_end',
      parameters: <String, Object>{
        'score': score,
        'miss_count': missCount,
        'timeout_count': timeoutCount,
        'play_seconds': playSeconds,
      },
    );
  }
}