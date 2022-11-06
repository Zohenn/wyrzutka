import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/firebase_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';

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