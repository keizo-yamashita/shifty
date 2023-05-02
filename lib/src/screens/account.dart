import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('アカウント画面', style: TextStyle(fontSize: 32.0))),
    );
  }
}
