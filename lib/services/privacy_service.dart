import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  PrivacyService._();

  static const String _consentAnsweredKey = 'privacy_consent_answered';
  static const String _privacyAcceptedKey = 'privacy_accepted';

  static Future<bool> isConsentAnswered() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentAnsweredKey) ?? false;
  }

  static Future<bool> isPrivacyAccepted() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyAcceptedKey) ?? false;
  }

  static Future<void> acceptPrivacy() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentAnsweredKey, true);
    await prefs.setBool(_privacyAcceptedKey, true);

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  static Future<void> declinePrivacy() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentAnsweredKey, true);
    await prefs.setBool(_privacyAcceptedKey, false);

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }

  static Future<void> applySavedConsentToAnalytics() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool accepted = prefs.getBool(_privacyAcceptedKey) ?? false;

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(accepted);
  }

  static Future<void> resetPrivacyConsent() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_consentAnsweredKey);
    await prefs.remove(_privacyAcceptedKey);

    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }
}