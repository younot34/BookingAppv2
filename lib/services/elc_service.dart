import 'package:flutter/services.dart';

class ElcService {
  static const _channel = MethodChannel('com.example.testing/elcapi');

  static Future<void> setLedGreen() async {
    try {
      await _channel.invokeMethod('ledGreen');
    } catch (e) {
      print("Error setLedGreen: $e");
    }
  }

  static Future<void> setLedRed() async {
    try {
      await _channel.invokeMethod('ledRed');
    } catch (e) {
      print("Error setLedRed: $e");
    }
  }

  static Future<void> setLedYellow() async {
    try {
      await _channel.invokeMethod('ledYellow');
    } catch (e) {
      print("Error setLedYellow: $e");
    }
  }
}