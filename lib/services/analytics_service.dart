import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logGameScreen() async {
    await _analytics.logScreenView(screenName: 'flag_game');
  }

  Future<void> logGameStart() async {
    await _analytics.logEvent(name: 'game_start');
  }

  Future<void> logCorrectTap() async {
    await _analytics.logEvent(name: 'tap_correct');
  }

  Future<void> logWrongTap() async {
    await _analytics.logEvent(name: 'tap_wrong');
  }

  Future<void> logTimeoutNext() async {
    await _analytics.logEvent(name: 'timeout_next');
  }

  Future<void> logGameEnd({
    required int score,
    required int missCount,
    required int timeoutCount,
    required int playSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'game_end',
      parameters: {
        'score': score,
        'miss_count': missCount,
        'timeout_count': timeoutCount,
        'play_seconds': playSeconds,
      },
    );
  }
}