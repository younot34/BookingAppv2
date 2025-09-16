import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../Config/api_config.dart';
import '../model/device.dart';

class DeviceService {
  final String url = "${ApiConfig.baseUrl}/devices";
  static const _deviceIdKey = "deviceId";

  Future<List<Device>> getDevices() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Device.fromJson(e)).toList();
    }
    throw Exception("Failed to fetch devices");
  }

  Stream<List<Device>> getDevicesStream({Duration interval = const Duration(seconds: 2)}) {
    return Stream.periodic(interval).asyncMap((_) => getDevices());
  }

  /// Ambil deviceId unik (disimpan di local storage)
  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId != null) return deviceId;

    deviceId = const Uuid().v4();
    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  /// Ambil nama device (misal: Samsung A7, iPhone 12)
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

  /// Register device ke MySQL Laravel, atau ambil kalau sudah ada
  static Future<String> registerOrGetRoom() async {
    final deviceId = await getDeviceId();
    final deviceName = await getDeviceName();

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/devices/register"),
      headers: ApiConfig.headers,
      body: jsonEncode({
        "device_id": deviceId,
        "device_name": deviceName,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['room_name'] ?? "Unknown Room";
    } else {
      throw Exception("Failed to register/get device");
    }
  }

  /// Ambil lokasi device (dari MySQL)
  static Future<String> getLocation(String roomName) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/devices?room_name=$roomName"),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List devices = jsonDecode(response.body);
      if (devices.isNotEmpty) {
        return devices.first['location'] ?? "Unknown Location";
      }
    }
    return "Unknown Location";
  }

  /// Update status device (isOn)
  static Future<void> setDeviceStatusByRoom(String roomName, bool isOn) async {
    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/devices/$roomName/status"),
      headers: ApiConfig.headers,
      body: jsonEncode({"is_on": isOn}),
    );

    if (response.statusCode != 200) {
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception("Failed to update device status");
    }
  }

  /// Ambil device berdasarkan room
  static Future<Device?> getDeviceByRoom(String roomName) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/devices?room_name=$roomName"),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      final List devices = jsonDecode(response.body);
      if (devices.isNotEmpty) {
        return Device.fromJson(devices.first);
      }
    }
    return null;
  }
}
