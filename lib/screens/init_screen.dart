import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/auth_provider.dart';

class InitScreen extends HookConsumerWidget {
  const InitScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialUser = ref.watch(initialAuthUserProvider);
    initialUser.whenData((value) => WidgetsBinding.instance
        .addPostFrameCallback(
            (timeStamp) => context.beamToReplacementNamed('/')));
    return Scaffold(
      body: Center(
        child: initialUser.when(
          data: (data) => CircularProgressIndicator(),
          error: (error, stack) => CircularProgressIndicator(),
          loading: () => CircularProgressIndicator(),
        ),
      ),
    );
  }
}
