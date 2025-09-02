import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'View/HomePage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final configString = await rootBundle.loadString("assets/config.json");
  final config = jsonDecode(configString);
  final roomName = config["roomName"] ?? "Room 001";
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  if (Platform.isWindows) {
    await setupWindow();
  }
  runApp(MyApp(roomName: roomName));
}

Future<void> setupWindow() async {
  await windowManager.ensureInitialized();
  await windowManager.setFullScreen(true);
  await windowManager.setAlwaysOnTop(true);
  await windowManager.setSkipTaskbar(true);
}

class MyApp extends StatelessWidget {
  final String roomName;
  const MyApp({super.key, required this.roomName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meeting Room Booking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF168757)),
        useMaterial3: true,
      ),
      home: HomePage(roomName: roomName),
    );
  }
}