import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDateTime extends DateTime {
  FirebaseDateTime(
    super.year, [
    super.month,
    super.day,
    super.hour,
    super.minute,
    super.second,
    super.millisecond,
    super.microsecond,
  ]) : serverTimestamp = false;

  FirebaseDateTime.serverTimestamp()
      : serverTimestamp = true,
        super.now();

  FirebaseDateTime.fromDateTime(DateTime dateTime)
      : serverTimestamp = false,
        super.fromMicrosecondsSinceEpoch(dateTime.microsecondsSinceEpoch);

  FirebaseDateTime.fromTimestamp(Timestamp timestamp)
      : serverTimestamp = false,
        super.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);

  final bool serverTimestamp;

  static FirebaseDateTime fromJson(Timestamp timestamp) => FirebaseDateTime.fromTimestamp(timestamp);

  static Object toJson(FirebaseDateTime firebaseDateTime) {
    return firebaseDateTime.serverTimestamp ? FieldValue.serverTimestamp() : Timestamp.fromDate(firebaseDateTime);
  }
}
