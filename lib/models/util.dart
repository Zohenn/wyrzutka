import 'package:cloud_firestore/cloud_firestore.dart';

DocumentSnapshot<Map<String, dynamic>>? snapshotFromJson(DocumentSnapshot<Map<String, dynamic>>? snapshot) => snapshot;

DateTime dateTimeFromJson(Timestamp timestamp) => timestamp.toDate();

DateTime dateTimeToJson(DateTime date) => date;

Null toJsonNull(_) => null;