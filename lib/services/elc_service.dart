import 'package:flutter/services.dart';

class ElcService {
  static const _channel = MethodChannel('com.example.testing/elcapi');

  static Future<void> ledOff() async {
    try {
      await _channel.invokeMethod('ledOff');
    } catch (e) {
      print("Error ledOff: $e");
    }
  }

  static Future<void> ledSeek() async {
    try {
      await _channel.invokeMethod('ledSeek');
    } catch (e) {
      print("Error ledSeek: $e");
    }
  }

  static Future<void> seekStart() async {
    try {
      await _channel.invokeMethod('seekStart');
    } catch (e) {
      print("Error seekStart: $e");
    }
  }

  static Future<void> seekStop() async {
    try {
      await _channel.invokeMethod('seekStop');
    } catch (e) {
      print("Error seekStop: $e");
    }
  }
}
