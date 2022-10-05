import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/providers/user_provider.dart';

final _initialAuthStateProvider = FutureProvider<User?>((ref) {
  final completer = Completer<User?>();
  final auth = ref.watch(firebaseAuthProvider);
  final authStateSubscription = auth.authStateChanges().listen((event) {
    // todo: handle sign out here as well?
    if (!completer.isCompleted) {
      completer.complete(event);
    }
  });

  // completer.future.then((_) => authStateSubscription.cancel());

  return completer.future;
});

final authUserProvider = StateProvider<AppUser?>((ref) => null);

final initialAuthUserProvider = FutureProvider<AppUser?>((ref) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final user = await ref.watch(_initialAuthStateProvider.future);

  if (user != null) {
    final _user = await userRepository.fetchId(user.uid, true);
    ref.read(authUserProvider.notifier).state = _user;
    return _user;
  }

  return null;
});

final authServiceProvider = Provider((ref) => AuthService(ref));

class UserNotFoundException extends Error {}

class AuthService {
  const AuthService(this.ref);

  final Ref ref;

  FirebaseAuth get auth => ref.watch(firebaseAuthProvider);

  UserRepository get userRepository => ref.watch(userRepositoryProvider);

  Future signUp({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    final userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user!.updateDisplayName('$name $surname');
    await _createUserDoc(userCredential: userCredential, email: email, name: name, surname: surname);
  }

  Future _createUserDoc({
    required UserCredential userCredential,
    required String email,
    required String name,
    required String surname,
  }) async {
    final user = await userRepository.create(
      AppUser(id: userCredential.user!.uid, email: email, name: name, surname: surname),
    );
    ref.read(authUserProvider.notifier).state = user;
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
    try {
      await _getUserData(userCredential);
    } on UserNotFoundException catch (e) {
      await _createUserDocFromGoogleCredential(userCredential);
    }
  }

  Future signInWithGoogle() async {
    final userCredential = await _googleSignIn();

    // This means that sign in was cancelled by user.
    if (userCredential == null) {
      return;
    }

    try {
      await _getUserData(userCredential);
    } on UserNotFoundException catch (e) {
      await _createUserDocFromGoogleCredential(userCredential);
    }
  }

  Future _getUserData(UserCredential userCredential) async {
    final user = await userRepository.fetchId(userCredential.user!.uid, true);
    if (user == null) {
      throw UserNotFoundException();
    }
    ref.read(authUserProvider.notifier).state = user;
  }

  Future<UserCredential?> _googleSignIn() async {
    final GoogleSignInAccount? googleUser = await ref.read(googleSignInProvider).signIn();

    // This means that sign in was cancelled by user.
    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await ref.read(firebaseAuthProvider).signInWithCredential(credential);
  }

  Future signOut() async {
    await auth.signOut();
    ref.read(authUserProvider.notifier).state = null;
  }
}
