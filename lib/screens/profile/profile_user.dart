import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/screens/profile/profile_actions_sheet.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';

class ProfileUser extends HookConsumerWidget {
  const ProfileUser({Key? key, required this.user}) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Card(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
          ),
          color: Theme.of(context).primaryColorLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
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
                IconButton(
                  onPressed: () async {
                    final result = await showDefaultBottomSheet(
                      context: context,
                      builder: (context) => ProfileActionsSheet(user: user),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
          ),
        ),
        Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              )),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.calendar_today),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data dołączenia',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    // TODO: get date from database
                    Text(
                      '${DateFormat('dd.MM.yyyy').format(DateTime.now())} r.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}