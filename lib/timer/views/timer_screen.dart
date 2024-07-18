import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:camera_windows/camera_windows.dart';

class TimerScreen extends StatefulWidget {
  // final CameraDescription camera;

  const TimerScreen({
    Key? key,
  }) : super(key: key);

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;
  int _start = 0;
  bool _isRunning = false;
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  String? _capturedImagePath;
  String? _errorText;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();

    _initializeControllerFuture = _initializeCameraController();
  }

  Future<void> _initializeCameraController() async {
    try {
      // Get the list of available cameras
      cameras = await availableCameras();

      // Check if cameras are available
      if (cameras.isNotEmpty) {
        final firstCamera = cameras.first;

        _controller = CameraController(
          firstCamera,
          ResolutionPreset.high,
          enableAudio: true,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _controller?.initialize();
        // await _controller?.setFocusMode(FocusMode.auto);
      } else {
        throw CameraException('No cameras available', 'Camera error');
      }
    } on CameraException catch (e) {
      print(e.code);
      print(e.description);

      setState(() {
        _errorText = 'Error initializing camera: $e';
      });
      rethrow;
    }
  }

  void startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      setState(() {
        _start++;
      });
    });

    captureImage();
  }

  void stopTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  Future<void> captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      await image.saveTo(imagePath);

      setState(() {
        _capturedImagePath = imagePath;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Application'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Timer: $_start'),
            ElevatedButton(
              onPressed: _isRunning ? stopTimer : startTimer,
              child: Text(_isRunning ? 'Stop' : 'Start'),
            ),
            FutureBuilder(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (_controller != null) {
                    return CameraPreview(_controller!);
                  } else {
                    return const Text('Error initializing camera');
                  }
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            if (_capturedImagePath != null)
              Image.file(File(_capturedImagePath!)),
            ElevatedButton(
              onPressed: captureImage,
              child: const Text('Capture Image'),
            ),
          ],
        ),
      ),
    );
  }
}
