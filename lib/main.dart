import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopee TH4',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const Scaffold(body: Center(child: Text('App Initialization'))),
    );
  }
}
