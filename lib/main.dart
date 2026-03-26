import 'dart:async';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flag Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const FlagGamePage(),
    );
  }
}

class FlagGamePage extends StatefulWidget {
  const FlagGamePage({super.key});

  @override
  State<FlagGamePage> createState() => _FlagGamePageState();
}

class _FlagGamePageState extends State<FlagGamePage> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Random _random = Random();

  Timer? _timer;
  bool _isPrivacyDialogShown = false;

  final List<String> _instructions = <String>[
    '赤上げて',
    '赤下げて',
    '白上げて',
    '白下げて',
  ];

  String _currentInstruction = 'ゲーム開始を押してください';
  String _previousInstruction = '';

  int _score = 0;
  int _missCount = 0;
  int _timeoutCount = 0;
  int _remainingSeconds = 10;

  bool _isPlaying = false;
  DateTime? _gameStartTime;

  @override
  void initState() {
    super.initState();
    _logScreenView();
    _checkAndShowPrivacyDialog();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndShowPrivacyDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool alreadyShown = prefs.getBool('privacy_dialog_shown') ?? false;

    if (alreadyShown || _isPrivacyDialogShown || !mounted) {
      return;
    }

    _isPrivacyDialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showPrivacyDialog();
    });
  }

  Future<void> _showPrivacyDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('データ利用について'),
          content: const Text(
            '本アプリでは、サービス改善のため Firebase Analytics を使用しています。\n\n'
            '利用状況や操作履歴を匿名で収集しますが、個人を特定する情報は含まれません。',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                await prefs.setBool('privacy_dialog_shown', true);

                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logScreenView() async {
    await _analytics.logScreenView(screenName: 'flag_game');
  }

  Future<void> _logGameStart() async {
    await _analytics.logEvent(name: 'game_start');
  }

  Future<void> _logCorrectTap(String instruction) async {
    await _analytics.logEvent(
      name: 'tap_correct',
      parameters: <String, Object>{
        'instruction': instruction,
      },
    );
  }

  Future<void> _logWrongTap(String instruction) async {
    await _analytics.logEvent(
      name: 'tap_wrong',
      parameters: <String, Object>{
        'instruction': instruction,
      },
    );
  }

  Future<void> _logTimeoutNext(String instruction) async {
    await _analytics.logEvent(
      name: 'timeout_next',
      parameters: <String, Object>{
        'instruction': instruction,
      },
    );
  }

  Future<void> _logGameEnd() async {
    final int playSeconds = _gameStartTime == null
        ? 0
        : DateTime.now().difference(_gameStartTime!).inSeconds;

    await _analytics.logEvent(
      name: 'game_end',
      parameters: <String, Object>{
        'score': _score,
        'miss_count': _missCount,
        'timeout_count': _timeoutCount,
        'play_seconds': playSeconds,
      },
    );
  }

  void _startGame() {
    _timer?.cancel();

    setState(() {
      _score = 0;
      _missCount = 0;
      _timeoutCount = 0;
      _remainingSeconds = 10;
      _isPlaying = true;
      _gameStartTime = DateTime.now();
    });

    _setNextInstruction();
    _startTimer();
    _logGameStart();
  }

  void _endGame() {
    _timer?.cancel();

    if (_isPlaying) {
      _logGameEnd();
    }

    setState(() {
      _isPlaying = false;
      _currentInstruction = 'ゲーム終了';
      _remainingSeconds = 10;
    });

    _showEndDialog();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        final String timedOutInstruction = _currentInstruction;

        _timeoutCount++;
        _logTimeoutNext(timedOutInstruction);

        setState(() {
          _remainingSeconds = 10;
        });

        _setNextInstruction();
      }
    });
  }

  void _setNextInstruction() {
    String nextInstruction;

    do {
      nextInstruction = _instructions[_random.nextInt(_instructions.length)];
    } while (_instructions.length > 1 && nextInstruction == _previousInstruction);

    setState(() {
      _previousInstruction = nextInstruction;
      _currentInstruction = nextInstruction;
      _remainingSeconds = 10;
    });
  }

  void _handleTap({
    required bool isRed,
    required bool isUp,
  }) {
    if (!_isPlaying) return;

    final bool isCorrect = _isCorrectAnswer(
      instruction: _currentInstruction,
      isRed: isRed,
      isUp: isUp,
    );

    final String instruction = _currentInstruction;

    if (isCorrect) {
      _score++;
      _logCorrectTap(instruction);
    } else {
      _missCount++;
      _logWrongTap(instruction);
    }

    _setNextInstruction();
  }

  bool _isCorrectAnswer({
    required String instruction,
    required bool isRed,
    required bool isUp,
  }) {
    switch (instruction) {
      case '赤上げて':
        return isRed && isUp;
      case '赤下げて':
        return isRed && !isUp;
      case '白上げて':
        return !isRed && isUp;
      case '白下げて':
        return !isRed && !isUp;
      default:
        return false;
    }
  }

  void _showEndDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ゲーム終了'),
          content: Text('スコア: $_score'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Color _timerColor() {
    return _remainingSeconds <= 3 ? Colors.red : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        title: const Text(
          'Flag Game',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.lightBlue,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              'Flag Game',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.lightBlue,
              child: Text(
                'スコア: $_score',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _currentInstruction,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '残り $_remainingSeconds 秒',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _timerColor(),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleTap(isRed: true, isUp: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '上',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _handleTap(isRed: false, isUp: false);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(
                            color: Colors.black,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '下',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPlaying ? null : _startGame,
                    child: const Text('ゲーム開始'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPlaying ? _endGame : null,
                    child: const Text('ゲーム終了'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}