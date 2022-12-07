import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wyrzutka/models/app_user/app_user.dart';
import 'package:wyrzutka/providers/auth_provider.dart';
import 'package:wyrzutka/screens/profile/profile_actions_sheet.dart';
import 'package:wyrzutka/screens/widgets/avatar_icon.dart';
import 'package:wyrzutka/utils/show_default_bottom_sheet.dart';
import 'package:wyrzutka/widgets/conditional_builder.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ProfileUser extends HookConsumerWidget {
  const ProfileUser({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authUserProvider);

    final bool isRole = (authUser?.role != Role.user || authUser?.role == Role.admin);
    final bool isProfile = ModalRoute.of(context).runtimeType != ModalBottomSheetRoute && authUser?.id == user.id;
    final bool isUserProfile = !isProfile && authUser?.id != user.id;

    return Card(
      child: Column(
        children: [
          Material(
            color: Theme.of(context).primaryColorLight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AvatarIcon(user: user, radius: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          user.role.desc,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: user.role.descColor),
                        ),
                      ],
                    ),
                  ),
                  ConditionalBuilder(
                    condition: (isRole && isUserProfile) || isProfile,
                    ifTrue: () => IconButton(
                      tooltip: 'Ustawienia użytkownika',
                      onPressed: () {
                        showDefaultBottomSheet(
                          closeModals: false,
                          context: context,
                          builder: (context) => ProfileActionsSheet(userId: user.id),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.calendar_today),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data dołączenia', style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      '${DateFormat('dd.MM.yyyy').format(user.signUpDate)} r.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
