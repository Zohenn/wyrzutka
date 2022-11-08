import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class ProfileActionsSheet extends HookConsumerWidget {
  const ProfileActionsSheet({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);

    // todo: perhaps show info if logged with google or email
    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(minLeadingWidth: 0, iconColor: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user.id == authUser?.id) ...[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edytuj dane konta'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outlined),
              title: const Text('Zmień hasło'),
              onTap: () {},
            ),
          ],
          if (user.role == Role.mod || user.role == Role.admin) ...[
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Zmień rolę'),
              onTap: () {},
            ),
          ],
          ConditionalBuilder(
            condition: user.id == authUser?.id,
            ifTrue: () => ListTile(
              title: Center(
                child: Text(
                  'Wyloguj się',
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                ),
              ),
              onTap: () {
                ref.read(authServiceProvider).signOut();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
