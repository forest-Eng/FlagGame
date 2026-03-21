import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flag Game',
      debugShowCheckedModeBanner: false,
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
  Timer? gameTimer;
  final Random random = Random();

  final List<String> commands = [
    "赤あげて",
    "赤さげて",
    "白あげて",
    "白さげて",
  ];

  int score = 0;
  int timeLeft = 10;
  String currentCommand = "";
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentCommand = "ゲーム開始を押してください";
    });
  }

  void startGame() {
    gameTimer?.cancel();

    setState(() {
      score = 0;
      timeLeft = 10;
      isPlaying = true;
    });

    nextCommand();
    startTimer();
  }

  void endGame() {
    gameTimer?.cancel();

    setState(() {
      isPlaying = false;
      timeLeft = 10;
      currentCommand = "ゲーム終了";
    });

    showScoreDialog();
  }

  void showScoreDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "ゲーム終了",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "今回のスコアは $score 点です",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void startTimer() {
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        nextTurn();
      }
    });
  }

  void nextCommand() {
    String newCommand;

    do {
      newCommand = commands[random.nextInt(commands.length)];
    } while (newCommand == currentCommand);

    setState(() {
      currentCommand = newCommand;
      timeLeft = 10;
    });
  }

  void checkAnswer(String answer) {
    if (!isPlaying) return;

    if (answer == currentCommand) {
      setState(() {
        score++;
      });
    }

    nextTurn();
  }

  void nextTurn() {
    if (!isPlaying) return;

    gameTimer?.cancel();
    nextCommand();
    startTimer();
  }

  ButtonStyle redButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      minimumSize: const Size(160, 56),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  ButtonStyle whiteButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black, width: 2),
      minimumSize: const Size(160, 56),
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color timerColor = timeLeft <= 3 ? Colors.red : Colors.black;

    const Color skyColor = Color(0xFF87CEEB);
    const Color bodyColor = Color(0xFFF5F5F5);
    const Color scoreColor = Color(0xFF87CEEB);

    return Scaffold(
      backgroundColor: bodyColor,
      appBar: AppBar(
        title: const Text("旗揚げゲーム"),
        centerTitle: true,
        backgroundColor: skyColor,
      ),

      body: Center(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  currentCommand,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "残り時間: $timeLeft 秒",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: timerColor,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "スコア: $score",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),

                const SizedBox(height: 36),

                // 赤ボタン（上段）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isPlaying ? () => checkAnswer("赤あげて") : null,
                      style: redButtonStyle(),
                      child: const Text("赤あげて"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: isPlaying ? () => checkAnswer("赤さげて") : null,
                      style: redButtonStyle(),
                      child: const Text("赤さげて"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 白ボタン（下段）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: isPlaying ? () => checkAnswer("白あげて") : null,
                      style: whiteButtonStyle(),
                      child: const Text("白あげて"),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: isPlaying ? () => checkAnswer("白さげて") : null,
                      style: whiteButtonStyle(),
                      child: const Text("白さげて"),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: startGame,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("ゲーム開始"),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isPlaying ? endGame : null,
                      icon: const Icon(Icons.stop),
                      label: const Text("ゲーム終了"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: 56,
        child: Container(
          color: skyColor,
          alignment: Alignment.center,
          child: const Text(
            "Flag Game",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
   );
  }
}