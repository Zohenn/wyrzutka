import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:patrol/patrol.dart';

Future<void> setupIntegrationTest(PatrolTester $, [String permissionAction = 'grant']) async {
  await useFirebaseEmulator();
  await $.host.runProcess('adb', arguments: ['shell', 'pm', permissionAction, 'com.example.inzynierka', 'android.permission.CAMERA']);
}

Future<void> useFirebaseEmulator() async {
  await Firebase.initializeApp();
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}