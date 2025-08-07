import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'feature/screens/home_screen.dart';
import 'feature/providers/note_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => NoteProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}
