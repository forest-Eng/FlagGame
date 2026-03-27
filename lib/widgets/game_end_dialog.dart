import 'package:flutter/material.dart';

class GameEndDialog extends StatelessWidget {
  const GameEndDialog({
    super.key,
    required this.score,
  });

  final int score;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ゲーム終了'),
      content: Text('スコア: $score'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}