import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testing/services/room_service.dart';
import '../model/booking.dart';

class BookingService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection("bookings");
  final CollectionReference _historyCollection =
  FirebaseFirestore.instance.collection("history");

  // CREATE
  Future<Booking> saveBooking(Booking booking) async {
    final roomName = await RoomService.getOrRegisterRoom();
    final newBooking = booking.copyWith(roomName: roomName);
    final docRef = await _collection.add(booking.toMap());
    await docRef.update({"id": docRef.id}); // simpan id di firestore juga
    return booking.copyWith(id: docRef.id); // kembalikan booking dengan id terisi
  }

  // READ (sekali ambil)
  Future<List<Booking>> getBookingsByRoom(String roomName) async {
    final snapshot = await _collection
        .where("roomName", isEqualTo: roomName)
        .get();

    return snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList();
  }

  // READ (stream realtime)
  Stream<List<Booking>> streamBookingsByRoom(String roomName) {
    return _collection
        .where("roomName", isEqualTo: roomName)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }
  Stream<List<Booking>> streamBookingsForDevice() async* {
    final roomName = await RoomService.getOrRegisterRoom();
    yield* _collection
        .where("roomName", isEqualTo: roomName)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => Booking.fromFirestore(doc)).toList());
  }

  // UPDATE
  Future<void> updateBooking(Booking booking) async {
    await _collection.doc(booking.id).update(booking.toMap());
  }

  // DELETE
  Future<void> deleteBooking(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> moveToHistory(Booking booking) async {
    try {
      if (booking.id.isEmpty) {
        print("Booking ID kosong, tidak bisa dipindah ke history.");
        return;
      }

      print("🚀 Memindahkan booking '${booking.meetingTitle}' ke history...");

      // Simpan booking ke collection history
      await _historyCollection.doc(booking.id).set(booking.toMap());
      print("✅ Booking tersimpan di history dengan ID: ${booking.id}");

      // Hapus dari collection bookings
      await _collection.doc(booking.id).delete();
      print("🗑 Booking dihapus dari bookings.");

    } catch (e) {
      print("❌ Gagal memindahkan booking ke history: $e");
    }
  }
}