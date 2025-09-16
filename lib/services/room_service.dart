import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Config/api_config.dart';
import 'device_service.dart';

class RoomService {
  static Future<String> getOrRegisterRoom() async {
    final deviceId = await DeviceService.getDeviceId();
    final deviceName = await DeviceService.getDeviceName(); // ✅ tambahkan

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/devices/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "device_id": deviceId,
        "device_name": deviceName, // ✅ kirim sesuai backend
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['room_name'] ?? "Unknown Room";
    } else {
      print("Register Room Failed: ${response.statusCode}");
      print("Response Body: ${response.body}");
      throw Exception("Failed to register/get room");
    }
  }
}
