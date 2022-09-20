import 'package:flutter/material.dart';
import 'package:inzynierka/models/app_user.dart';
import 'package:inzynierka/screens/widgets/avatar_icon.dart';

class ProductUser extends StatelessWidget {
  const ProductUser({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            AvatarIcon(user: user),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produkt dodany przez',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  '${user.name} ${user.surname}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
