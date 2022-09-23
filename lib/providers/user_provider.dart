import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

final _usersCollection = FirebaseFirestore.instance.collection('users').withConverter(
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

final userRepositoryProvider = Provider((ref) => UserRepository());

class UserRepository {
  final Map<String, AppUser> cache = {};

  Future<AppUser?> fetchId(String id, [bool skipCache = false]) async {
    if (!skipCache && cache[id] != null) {
      return cache[id];
    }
    final snapshot = await _usersCollection.doc(id).get();
    final user = snapshot.data();
    _addToCache(user);
    return user;
  }

  void _addToCache(AppUser? user) {
    if (user != null) {
      cache[user.id] = user;
    }
  }
}

final authServiceProvider = Provider((ref) => AuthService(ref));

class UserNotFoundException extends Error {}

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
    await _createUserDoc(userCredential: userCredential, email: email, name: name, surname: surname);
  }

  Future _createUserDoc({
    required UserCredential userCredential,
    required String email,
    required String name,
    required String surname,
  }) async {
    final doc = _usersCollection.doc(userCredential.user!.uid);
    final user = AppUser(id: doc.id, email: email, name: name, surname: surname);
    await doc.set(user);
    ref.read(userProvider.notifier).state = user;
  }

  Future _createUserDocFromGoogleCredential(UserCredential userCredential) {
    // todo: perhaps there's a better way, since displayName can contain anything
    final user = userCredential.user!;
    final nameParts = user.displayName!.split(' ');
    final name = nameParts.first;
    final surname = nameParts.skip(1).join(' ');
    return _createUserDoc(userCredential: userCredential, email: user.email!, name: name, surname: surname);
  }

  Future signIn({required String email, required String password}) async {
    final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
    await _getUserData(userCredential);
  }

  Future signInWithGoogle() async {
    final userCredential = await _googleSignIn();
    try {
      await _getUserData(userCredential);
    } on UserNotFoundException catch (e) {
      await _createUserDocFromGoogleCredential(userCredential);
    }
  }

  Future _getUserData(UserCredential userCredential) async {
    final doc = _usersCollection.doc(userCredential.user!.uid);
    final snapshot = await doc.get();
    if(!snapshot.exists){
      throw UserNotFoundException();
    }
    ref.read(userProvider.notifier).state = snapshot.data()!;
  }

  Future<UserCredential> _googleSignIn() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future signOut() async {
    await auth.signOut();
    ref.read(userProvider.notifier).state = null;
  }
}
