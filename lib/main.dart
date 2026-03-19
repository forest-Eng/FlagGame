import 'dart:math';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_tts/flutter_tts.dart';
// ignore: unused_import
// import 'package:flutter/flutter_local_notifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '旗揚げゲーム',
      home: FlagGame(),
    );
  }
}

class FlagGame extends StatefulWidget {
  const FlagGame({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FlagGameState createState() => _FlagGameState();
}

class _FlagGameState extends State<FlagGame> {
  final List<String> commands = [
    "赤あげて",
    "赤さげて",
    "白あげて",
    "白さげて"
  ];

  String currentCommand = "";
  int score = 0;
  Random random = Random();

  @override

  void initState() {
    super.initState();
    nextCommand();
  }

  void nextCommand() {
    setState(() {
      currentCommand = commands[random.nextInt(commands.length)];
    });
  }

  void checkAnswer(String answer) {
    if (answer == currentCommand) {
      score++;
    }
    nextCommand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("旗揚げゲーム")),
      body: newMethod(),
    );
  }

// final tts = MyTts();
// tts.speak("赤あげて、白さげて");

Column newMethod() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        currentCommand,
        style: TextStyle(fontSize: 40,color: Colors.black,),
      ),
      SizedBox(height: 40),
      Center(
        child: SizedBox(
          width: 300, // 全体幅を固定して中央寄せ
          child: GridView.count(
            shrinkWrap: true, // Column内で使うため必須
            crossAxisCount: 2, // 列数
            mainAxisSpacing: 10, // 縦間隔
            crossAxisSpacing: 10, // 横間隔
            childAspectRatio: 2.5, // ボタンの横長比率
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // 背景色
              foregroundColor: Colors.white, // 文字色
            ),
              onPressed: () => checkAnswer("赤あげて"),
              child: Text("赤あげて",style: TextStyle(fontSize: 24),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // 背景色
              foregroundColor: Colors.white, // 文字色
            ),
             onPressed: () => checkAnswer("赤さげて"),
              child: Text("赤さげて",style: TextStyle(fontSize: 24),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.black, width: 2),
            ),
              onPressed: () => checkAnswer("白あげて"),
              child: Text("白あげて",style: TextStyle(fontSize: 24),),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.black, width: 2),
            ),
              onPressed: () => checkAnswer("白さげて"),
              child: Text("白さげて",style: TextStyle(fontSize: 24),),
            ),
          ],
        ),
        ),
      ),
      SizedBox(height: 20),
      Text(
        "スコア: $score",
        style: TextStyle(fontSize: 32,color: Colors.blue,),
      ),
        //再生したいところで以下を実行
        // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        // FlutterLocalNotificationsPlugin();
    ],
  );
  }
}