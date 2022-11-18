import 'package:flutter/material.dart';
import 'package:flutter_dialog_manager/flutter_dialog_manager.dart';
import 'package:draga/view/constants.dart';
import 'package:draga/view/drawing_page.dart';
import 'package:draga/view/downloading_dialog.dart';

final _navigatorKey = GlobalKey<NavigatorState>();
void main() {
  runApp(const DragaApp());
}

const Color kCanvasColor = Color(0xfff2f3f7);
const String kGithubRepo = 'https://github.com/Crazelu/draga';

class DragaApp extends StatelessWidget {
  const DragaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DialogManager(
      navigatorKey: _navigatorKey,
      onGenerateDialog: (settings) {
        if (settings.name == kLoadingDialogRoute) {
          return const DownloadingDialog();
        }
        return null;
      },
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Draga',
        theme: ThemeData(primarySwatch: Colors.blue),
        debugShowCheckedModeBanner: false,
        home: const DrawingPage(),
      ),
    );
  }
}
