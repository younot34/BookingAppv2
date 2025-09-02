import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;  final String roomName;
  final String date;
  final String time;
  final String? duration;
  final int? numberOfPeople;
  final List<String> equipment;
  final String hostName;
  final String meetingTitle;
  final bool isScanEnabled;
  final String? scanInfo;

  Booking({
    required this.id,
    required this.roomName,
    required this.date,
    required this.time,
    this.duration,
    this.numberOfPeople,
    required this.equipment,
    required this.hostName,
    required this.meetingTitle,
    this.isScanEnabled = false,
    this.scanInfo,
  });

  factory Booking.newBooking({
    required String roomName,
    required String date,
    required String time,
    String? duration,
    int? numberOfPeople,
    required List<String> equipment,
    required String hostName,
    required String meetingTitle,
    bool isScanEnabled = false,
    String? scanInfo,
  }) {
    return Booking(
      id: "",
      roomName: roomName,
      date: date,
      time: time,
      duration: duration,
      numberOfPeople: numberOfPeople,
      equipment: equipment,
      hostName: hostName,
      meetingTitle: meetingTitle,
      isScanEnabled: isScanEnabled,
      scanInfo: scanInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "roomName": roomName,
      "date": date,
      "time": time,
      "duration": duration,
      "numberOfPeople": numberOfPeople,
      "equipment": equipment,
      "hostName": hostName,
      "meetingTitle": meetingTitle,
      "isScanEnabled": isScanEnabled,
      "scanInfo": scanInfo,
    };
  }

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      roomName: data["roomName"] ?? "",
      date: data["date"] ?? "",
      time: data["time"] ?? "",
      duration: data["duration"],
      numberOfPeople: data["numberOfPeople"],
      equipment: List<String>.from(data["equipment"] ?? []),
      hostName: data["hostName"] ?? "",
      meetingTitle: data["meetingTitle"] ?? "",
      isScanEnabled: data["isScanEnabled"] ?? false,
      scanInfo: data["scanInfo"],
    );
  }
  Booking copyWith({String? id}) {
    return Booking(
      id: id ?? this.id,
      roomName: roomName,
      date: date,
      time: time,
      duration: duration,
      numberOfPeople: numberOfPeople,
      equipment: equipment,
      hostName: hostName,
      meetingTitle: meetingTitle,
      isScanEnabled: isScanEnabled,
      scanInfo: scanInfo,
    );
  }
}

//kalau butuh history
// void _removePastBookings() {
//   bookings.removeWhere((b) {
//     final parts = b.time.split(':');
//     final hour = int.parse(parts[0]);
//     final minute = int.parse(parts[1]);
//     final start = DateTime(
//       int.parse(b.date.split('/')[2]),
//       int.parse(b.date.split('/')[1]),
//       int.parse(b.date.split('/')[0]),
//       hour,
//       minute,
//     );
//     final dur = int.tryParse(b.duration ?? '30') ?? 30;
//     final end = start.add(Duration(minutes: dur));
//     return end.isBefore(_currentTime);
//   });
// }