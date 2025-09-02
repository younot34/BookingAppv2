import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/booking.dart';

class BookingService {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection("bookings");

  // CREATE
  Future<Booking> saveBooking(Booking booking) async {
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

  // UPDATE
  Future<void> updateBooking(Booking booking) async {
    await _collection.doc(booking.id).update(booking.toMap());
  }

  // DELETE
  Future<void> deleteBooking(String id) async {
    await _collection.doc(id).delete();
  }
}