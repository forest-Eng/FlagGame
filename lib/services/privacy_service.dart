import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  PrivacyService._();

  static const String _privacyDialogShownKey = 'privacy_dialog_shown';

  static Future<bool> isPrivacyDialogShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyDialogShownKey) ?? false;
  }

  static Future<void> setPrivacyDialogShown() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyDialogShownKey, true);
  }
}