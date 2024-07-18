import 'package:camera/camera.dart';
import 'package:desktop_timer_app/timer/views/timer_screen.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DesktopWindow.setWindowSize(const Size(800, 600));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // final CameraDescription camera;

  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TimerScreen(),
    );
  }
}
