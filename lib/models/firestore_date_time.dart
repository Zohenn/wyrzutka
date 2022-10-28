import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDateTime extends DateTime {
  FirestoreDateTime(
    super.year, [
    super.month,
    super.day,
    super.hour,
    super.minute,
    super.second,
    super.millisecond,
    super.microsecond,
  ]) : serverTimestamp = false;

  FirestoreDateTime.serverTimestamp()
      : serverTimestamp = true,
        super.now();

  FirestoreDateTime.fromDateTime(DateTime dateTime)
      : serverTimestamp = false,
        super.fromMicrosecondsSinceEpoch(dateTime.microsecondsSinceEpoch);

  FirestoreDateTime.fromTimestamp(Timestamp timestamp)
      : serverTimestamp = false,
        super.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);

  final bool serverTimestamp;

  static FirestoreDateTime fromFirestore(Timestamp timestamp) => FirestoreDateTime.fromTimestamp(timestamp);

  static Object toFirestore(FirestoreDateTime firebaseDateTime) {
    return firebaseDateTime.serverTimestamp ? FieldValue.serverTimestamp() : Timestamp.fromDate(firebaseDateTime);
  }
}
