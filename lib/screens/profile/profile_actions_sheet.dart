import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';

class ProfileActionsSheet extends HookConsumerWidget {
  const ProfileActionsSheet({Key? key, required this.user}) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(minLeadingWidth: 0, iconColor: Colors.black),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
            child: Row(
              children: [
                AvatarIcon(user: user, radius: 25),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(user.role.desc,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: user.role.descColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edytuj dane konta'),
            onTap: () {},
          ),
          if (user.role == Role.mod || user.role == Role.admin) ...[
            ListTile(
              leading: const Icon(Icons.lock_outlined),
              title: const Text('Zmień hasło'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: const Text('Zmień rolę'),
              onTap: () {},
            ),
          ],
          ListTile(
            title: TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark),
              ),
              onPressed: () => {
                ref.read(authServiceProvider).signOut(),
                Navigator.of(context).pop(),
              },
              child: const Text('Wyloguj się'),
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
