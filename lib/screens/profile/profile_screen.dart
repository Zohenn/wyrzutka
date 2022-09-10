import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/profile/profile_features_screen.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return SafeArea(
      child: ConditionalBuilder(
        condition: user != null,
        ifTrue: () => ProfileScreenContent(),
        ifFalse: () => ProfileFeaturesScreen(),
      ),
    );
  }
}

class ProfileScreenContent extends HookConsumerWidget {
  const ProfileScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Zalogowany'),
          OutlinedButton(
            onPressed: () {
              ref.read(authServiceProvider).signOut();
            },
            child: Text('Wyloguj'),
          ),
        ],
      ),
    );
  }
}
