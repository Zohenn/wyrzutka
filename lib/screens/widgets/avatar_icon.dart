import 'package:flutter/material.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.black,
      child: Center(
        child: ConditionalBuilder(
          condition: user != null,
          ifTrue: () => Text(
            user!.name[0].toUpperCase() + user!.surname[0].toUpperCase(),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          ifFalse: () => const Icon(
            Icons.question_mark,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
