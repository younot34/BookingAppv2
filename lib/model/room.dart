import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String buildingId;
  final String floor;
  final int capacity;
  final List<String> equipment;

  Room({
    required this.id,
    required this.name,
    required this.buildingId,
    required this.floor,
    required this.capacity,
    required this.equipment,
  });

  Room copyWith({
    String? id,
    String? name,
    String? buildingId,
    String? floor,
    int? capacity,
    List<String>? equipment,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      buildingId: buildingId ?? this.buildingId,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      equipment: equipment ?? this.equipment,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "buildingId": buildingId,
      "floor": floor,
      "capacity": capacity,
      "equipment": equipment,
    };
  }

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Room(
      id: doc.id,
      name: data['name'] ?? '',
      buildingId: data['buildingId'] ?? '',
      floor: data['floor'] ?? '',
      capacity: data['capacity'] ?? 0,
      equipment: List<String>.from(data['equipment'] ?? []),
    );
  }
}
