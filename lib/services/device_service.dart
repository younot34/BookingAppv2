import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection("devices");
  static const _deviceIdKey = "deviceId";

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    String? deviceId = prefs.getString(_deviceIdKey);
    if (deviceId != null) return deviceId;

    deviceId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }
  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return "${info.manufacturer} ${info.model}";
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return "${info.name} ${info.model}";
    } else {
      return "Unknown Device";
    }
  }
  Future<String> getLocation(String deviceName) async {
    try {
      final snapshot = await _collection
          .where("name", isEqualTo: deviceName) // pastikan field "name" sama dengan nama device
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data["location"] ?? "Unknown Location";
      } else {
        return "Unknown Location";
      }
    } catch (e) {
      print("Failed to get location: $e");
      return "Unknown Location";
    }
  }

  Stream<String> streamDeviceLocation(String deviceName) {
    return _collection
        .where("name", isEqualTo: deviceName)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        return data["location"] ?? "Unknown Location";
      } else {
        return "Unknown Location";
      }
    });
  }
}