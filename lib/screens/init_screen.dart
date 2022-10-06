import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';

final _initFutureProvider = FutureProvider((ref) async {
  await Firebase.initializeApp();
  await ref.read(initialAuthUserProvider.future);
});

class InitScreen extends HookConsumerWidget {
  const InitScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initFuture = ref.watch(_initFutureProvider);
    initFuture.whenData(
      (value) => WidgetsBinding.instance.addPostFrameCallback((timeStamp) => context.beamToReplacementNamed('/')),
    );
    return Scaffold(
      body: Center(
        child: initFuture.when(
          data: (data) => const CircularProgressIndicator(),
          // todo: handle error
          error: (error, stack) => const CircularProgressIndicator(),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
