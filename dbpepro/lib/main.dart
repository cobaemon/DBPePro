import 'package:flutter/material.dart';

// 接続画面
import './Connection/ConnectionScreen.dart';


void main() {
  runApp(
    const MyApp()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'DB PePro',
      home: SafeArea(
        child: ConnectionScreen(),
      ),
    );
  }
}
