import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user.dart';

final _initialAuthStateProvider = FutureProvider<User?>((ref) {
  final completer = Completer<User?>();
  final auth = FirebaseAuth.instance;
  final authStateSubscription = auth.authStateChanges().listen((event) {
    if (!completer.isCompleted) {
      completer.complete(event);
    }
  });

  // completer.future.then((_) => authStateSubscription.cancel());

  return completer.future;
});

final userProvider = StateProvider<AppUser?>((ref) => null);

final _usersCollection =
    FirebaseFirestore.instance.collection('users').withConverter(
          fromFirestore: AppUser.fromFirestore,
          toFirestore: AppUser.toFirestore,
        );

final initialUserProvider = FutureProvider<AppUser?>((ref) async {
  await Firebase.initializeApp();
  final user = await ref.watch(_initialAuthStateProvider.future);

  if (user != null) {
    final userSnapshot = await _usersCollection.doc(user.uid).get();
    final _user = userSnapshot.data();
    ref.read(userProvider.notifier).state = _user;
    return _user;
  }

  return null;
});
