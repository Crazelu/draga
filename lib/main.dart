import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/view/drawing_page.dart';

void main() {
  runApp(const DragaApp());
}

const Color kCanvasColor = Color(0xfff2f3f7);
const String kGithubRepo = 'https://github.com/Crazelu/draga';

class DragaApp extends StatelessWidget {
  const DragaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draga',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const DrawingPage(),
    );
  }
}
