import 'package:flutter/material.dart';
import 'package:inzynierka/colors.dart';
import 'package:inzynierka/models/app_user/app_user.dart';
import 'package:inzynierka/screens/profile/profile_screen.dart';
import 'package:inzynierka/utils/show_default_bottom_sheet.dart';
import 'package:inzynierka/widgets/conditional_builder.dart';
import 'package:inzynierka/widgets/default_bottom_sheet.dart';

class AvatarIcon extends StatelessWidget {
  const AvatarIcon({
    Key? key,
    required this.user,
    this.radius = 20.0,
    this.profileLoading = false,
  }) : super(key: key);

  final AppUser? user;
  final double radius;
  final bool profileLoading;

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
      condition: user != null,
      ifTrue: () => CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          color: Colors.transparent,
          child: InkWell(
            onTap: profileLoading
                ? () {
                    if (profileLoading) {
                      Navigator.of(context).pop();
                      showDefaultBottomSheet(
                        context: context,
                        builder: (context) => DefaultBottomSheet(
                          child: ProfileScreen(user: user),
                        ),
                      );
                    }
                  }
                : null,
            child: Center(
              child: Text(
                user!.name[0].toUpperCase() + user!.surname[0].toUpperCase(),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ),
      ),
      ifFalse: () => Tooltip(
        message: "Nie udało się załadować użytkownika",
        child: CircleAvatar(
          radius: radius,
          backgroundColor: Colors.white,
          child: const Icon(Icons.warning_amber, color: AppColors.warning),
        ),
      ),
    );
  }
}
