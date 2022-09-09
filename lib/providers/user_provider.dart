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

final authServiceProvider = Provider((ref) => AuthService(ref));

class AuthService {
  const AuthService(this.ref);

  final Ref ref;
  FirebaseAuth get auth => FirebaseAuth.instance;

  Future signUp({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    final doc = _usersCollection.doc(userCredential.user!.uid);
    final user = AppUser(id: doc.id, email: email, name: name, surname: surname);
    await doc.set(user);
    ref.read(userProvider.notifier).state = user;
  }

  Future signIn({ required String email, required String password}) async {
    final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    final doc = _usersCollection.doc(userCredential.user!.uid);
    final snapshot = await doc.get();
    ref.read(userProvider.notifier).state = snapshot.data()!;
  }

  Future signOut() async {
    await auth.signOut();
    ref.read(userProvider.notifier).state = null;
  }
}