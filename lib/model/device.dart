class Device {
  final String id;
  final String deviceName;
  final String roomName;
  final String location;
  final DateTime? installDate;
  final int capacity;
  final List<String> equipment;
  final bool isOn;

  Device({
    required this.id,
    required this.deviceName,
    required this.roomName,
    required this.location,
    required this.installDate,
    required this.capacity,
    required this.equipment,
    required this.isOn,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceName: json['deviceName'] ?? '',
      roomName: json['roomName'] ?? 'Unknown Room',
      location: json['location'] ?? '',
      installDate: json['install_date'] != null && json['install_date'] != ''
          ? DateTime.tryParse(json['install_date'])
          : null,
      capacity: json['capacity'] ?? 0,
      equipment: List<String>.from(json['equipment'] ?? []),// fallback default
      isOn: json['isOn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceName': deviceName,
    'roomName': roomName,
    'location': location,
    'installDate': installDate,
    'capacity': capacity,
    'equipment': equipment,
    'isOn': isOn,
  };
}
