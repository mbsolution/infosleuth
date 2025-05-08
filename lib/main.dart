// lib/main.dart

import 'package:flutter/material.dart';
// ← adjust this to match your pubspec.yaml `name:` field:
import 'package:infosleuth/screens/search_screen.dart';

void main() {
  runApp(const InfoSleuthApp());
}

class InfoSleuthApp extends StatelessWidget {
  const InfoSleuthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InfoSleuth',
      debugShowCheckedModeBanner: false,              // hide the DEBUG banner
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const SearchScreen(),                     // Make sure this class lives in
      // lib/screens/search_screen.dart
    );
  }
}
