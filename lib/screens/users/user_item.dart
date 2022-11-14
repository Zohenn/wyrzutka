import 'package:flutter/material.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';

class UserItem extends StatelessWidget {
  const UserItem({
    Key? key,
    required this.user,
    this.onTap,
  }) : super(key: key);

  final AppUser user;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              AvatarIcon(user: user),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    user.role.desc,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: user.role.descColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
