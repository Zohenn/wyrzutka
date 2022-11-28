import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> useFirebaseEmulator() async {
  await Firebase.initializeApp();
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}