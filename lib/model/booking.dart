class Booking {
  final String id;  
  final String roomName;
  final String date;
  final String time;
  final String? duration;
  final int? numberOfPeople;
  final List<String> equipment;
  final String hostName;
  final String meetingTitle;
  final bool isScanEnabled;
  final String? scanInfo;
  final String status;

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
    this.status = "In Queue",
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

  Map<String, dynamic> toJson() {
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
      "status": status,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      roomName: json["roomName"] ?? "",
      date: json["date"] ?? "",
      time: json["time"] ?? "",
      duration: json["duration"],
      numberOfPeople: json["numberOfPeople"],
      equipment: List<String>.from(json["equipment"] ?? []),
      hostName: json["hostName"] ?? "",
      meetingTitle: json["meetingTitle"] ?? "",
      isScanEnabled: json["isScanEnabled"] ?? false,
      scanInfo: json["scanInfo"],
      status: json["status"] ?? "upcoming",
    );
  }
  Booking copyWith({
    String? id,
    String? roomName,
    String? date,
    String? time,
    String? duration,
    int? numberOfPeople,
    List<String>? equipment,
    String? hostName,
    String? meetingTitle,
    bool? isScanEnabled,
    String? scanInfo,
  }) {
    return Booking(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      equipment: equipment ?? this.equipment,
      hostName: hostName ?? this.hostName,
      meetingTitle: meetingTitle ?? this.meetingTitle,
      isScanEnabled: isScanEnabled ?? this.isScanEnabled,
      scanInfo: scanInfo ?? this.scanInfo,
    );
  }
}