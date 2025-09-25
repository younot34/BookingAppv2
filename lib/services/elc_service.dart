import 'package:flutter/services.dart';

class ElcService {
  static const platform = MethodChannel('com.example.elcapi');

  // Sesuai native method
  static Future<int?> ledSeek(int i, int i2) async {
    return await platform.invokeMethod('ledSeek', {"i": i, "i2": i2});
  }

  static Future<int?> seekStart() async {
    return await platform.invokeMethod('seekStart');
  }

  static Future<int?> seekStop() async {
    return await platform.invokeMethod('seekStop');
  }

  // Kalau mau ada "ledOff", kamu bisa bikin shortcut sendiri
  static Future<int?> ledOff() async {
    // Misal kita asumsikan ledOff = seekStop()
    return await seekStop();
  }
}
