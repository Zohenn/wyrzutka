import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/providers/user_provider.dart';
import 'package:inzynierka/screens/sign_in_screen.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    useEffect(() {
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => showDefaultBottomSheet(
            context: context,
            fullScreen: true,
            builder: (context) => SignInScreen(),
          ),
        );
      }
      return null;
    }, []);
    return ConditionalBuilder(
      condition: user != null,
      ifTrue: () => ProfileScreenContent(),
      ifFalse: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We się zaloguj najpierw'),
            OutlinedButton(
              onPressed: () => showDefaultBottomSheet(
                context: context,
                fullScreen: true,
                builder: (context) => SignInScreen(),
              ),
              child: Text('Logowanie'),
            ),
          ],
        ),
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
