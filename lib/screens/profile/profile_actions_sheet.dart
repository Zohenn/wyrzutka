import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/providers/auth_provider.dart';
import 'package:inzynierka/repositories/user_repository.dart';
import 'package:inzynierka/screens/profile/dialog/profile_password_dialog.dart';
import 'package:inzynierka/screens/profile/dialog/profile_role_dialog.dart';
import 'package:inzynierka/screens/profile/dialog/profile_user_info_dialog.dart';
import 'package:inzynierka/services/auth_service.dart';
import 'package:inzynierka/theme/colors.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class ProfileActionsSheet extends HookConsumerWidget {
  const ProfileActionsSheet({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final authUser = ref.watch(authUserProvider);

    final user = ref.watch(userProvider(userId))!;

    // todo: perhaps show info if logged with google or email
    return ListTileTheme(
      data: Theme.of(context).listTileTheme.copyWith(minLeadingWidth: 0, iconColor: Colors.black),
      child: Semantics(
        container: true,
        label: 'Akcje użytkownika',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (user.id == authUser?.id) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edytuj dane konta'),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => ProfileUserInfoDialog(user: user),
                ),
              ),
              if(authService.usedPasswordProvider)...[
                ListTile(
                  leading: const Icon(Icons.lock_outlined),
                  title: const Text('Zmień hasło'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => ProfilePasswordDialog(user: user),
                  ),
                ),
              ],
            ],
            if (authUser?.id != user.id && (authUser?.role == Role.mod || authUser?.role == Role.admin)) ...[
              ListTile(
                leading: const Icon(Icons.verified_outlined),
                title: const Text('Zmień rolę'),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => ProfileRoleDialog(user: user),
                ),
              ),
            ],
            ConditionalBuilder(
              condition: user.id == authUser?.id,
              ifTrue: () => ListTile(
                title: const Center(
                  child: Text(
                    'Wyloguj się',
                    style: TextStyle(color: AppColors.primaryDarker),
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
      ),
    );
  }
}
