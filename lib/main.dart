import 'dart:io';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testing/services/device_service.dart';
import 'package:testing/services/room_service.dart';
import 'View/HomePage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  final roomName = await RoomService.getOrRegisterRoom();
  await DeviceService.setDeviceStatusByRoom(roomName, true);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  if (Platform.isWindows) {
    await setupWindow();
  }
  await initializeDateFormatting('id_ID', null);
  await AndroidAlarmManager.oneShot(
    const Duration(seconds: 5),
    0, // alarm ID
    bootCallback,
    exact: true,
    wakeup: true,
  );
  runApp(MyApp(roomName: roomName));
}

void bootCallback() {
  print("Boot task executed!");
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