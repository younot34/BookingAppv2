import 'package:cloud_firestore/cloud_firestore.dart';
import 'device_service.dart';

class RoomService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _devicesCollection = _firestore.collection("devices");
  static Future<String> getOrRegisterRoom() async {
    final deviceId = await DeviceService.getDeviceId();
    final deviceName = await DeviceService.getDeviceName();
    final docRef = FirebaseFirestore.instance.collection("devices").doc(deviceId);
    final doc = await docRef.get();

    if (doc.exists) {
      return doc["roomName"] ?? "Unknown Room";
    } else {
      final snapshot = await FirebaseFirestore.instance.collection("devices").get();
      final roomNumber = snapshot.docs.length + 1;
      final roomName = "Room $roomNumber";

      await docRef.set({
        "deviceName": deviceName,
        "roomName": roomName,
      });
      return roomName;
    }
  }
}
