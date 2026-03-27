import 'package:flutter/material.dart';

class PrivacyDialog extends StatelessWidget {
  const PrivacyDialog({
    super.key,
    required this.onOkPressed,
  });

  final Future<void> Function() onOkPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('データ利用について'),
      content: const Text(
        '本アプリでは、サービス改善のため Firebase Analytics を使用しています。\n\n'
        '利用状況や操作履歴を匿名で収集しますが、個人を特定する情報は含まれません。',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await onOkPressed();
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}