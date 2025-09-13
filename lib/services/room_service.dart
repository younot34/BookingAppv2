import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Config/api_config.dart';
import 'device_service.dart';

class RoomService {
  static Future<String> getOrRegisterRoom() async {
    final deviceId = await DeviceService.getDeviceId();

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/devices/register"), // ganti sesuai backend
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"device_id": deviceId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['room_name'] ?? "Unknown Room";
    } else {
      throw Exception("Failed to register/get room");
    }
  }
}
