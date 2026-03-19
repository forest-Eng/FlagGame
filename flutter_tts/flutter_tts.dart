import 'package:flutter_tts/flutter_tts.dart';

class MyTts {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.setLanguage("ja-JP");
    await _tts.speak(text);
  }
}