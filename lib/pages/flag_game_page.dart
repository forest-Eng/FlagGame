import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../logic/game_logic.dart';
import '../services/analytics_service.dart';
import '../services/privacy_service.dart';
import '../widgets/game_end_dialog.dart';
import '../widgets/privacy_dialog.dart';

class FlagGamePage extends StatefulWidget {
  const FlagGamePage({super.key});

  @override
  State<FlagGamePage> createState() => _FlagGamePageState();
}

class _FlagGamePageState extends State<FlagGamePage> {
  final Random _random = Random();
  Timer? _timer;

  bool _isPrivacyDialogShownInSession = false;
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
    AnalyticsService.logScreenView();
    _checkAndShowPrivacyDialog();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkAndShowPrivacyDialog() async {
    final bool alreadyShown = await PrivacyService.isPrivacyDialogShown();

    if (alreadyShown || _isPrivacyDialogShownInSession || !mounted) {
      return;
    }

    _isPrivacyDialogShownInSession = true;

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
        return PrivacyDialog(
          onOkPressed: () async {
            await PrivacyService.setPrivacyDialogShown();
          },
        );
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
    AnalyticsService.logGameStart();
  }

  void _endGame() {
    _timer?.cancel();

    if (_isPlaying) {
      AnalyticsService.logGameEnd(
        score: _score,
        missCount: _missCount,
        timeoutCount: _timeoutCount,
        gameStartTime: _gameStartTime,
      );
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
        AnalyticsService.logTimeoutNext(timedOutInstruction);

        setState(() {
          _remainingSeconds = 10;
        });

        _setNextInstruction();
      }
    });
  }

  void _setNextInstruction() {
    final String nextInstruction = GameLogic.getNextInstruction(
      random: _random,
      previousInstruction: _previousInstruction,
    );

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

    final bool isCorrect = GameLogic.isCorrectAnswer(
      instruction: _currentInstruction,
      isRed: isRed,
      isUp: isUp,
    );

    final String instruction = _currentInstruction;

    if (isCorrect) {
      _score++;
      AnalyticsService.logCorrectTap(instruction);
    } else {
      _missCount++;
      AnalyticsService.logWrongTap(instruction);
    }

    _setNextInstruction();
  }

  void _showEndDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GameEndDialog(score: _score);
      },
    );
  }

  Color _timerColor() {
    return _remainingSeconds <= 3 ? Colors.red : Colors.black;
  }

  Widget _buildRedButton(String label, bool isUp) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _handleTap(isRed: true, isUp: isUp);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildWhiteButton(String label, bool isUp) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          _handleTap(isRed: false, isUp: isUp);
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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
            const SizedBox(height: 20),

            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildRedButton('赤 上げて', true),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWhiteButton('白 上げて', true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildRedButton('赤 下げて', false),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildWhiteButton('白 下げて', false),
                        ),
                      ],
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